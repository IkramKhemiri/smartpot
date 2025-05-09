#include <WiFi.h>
#include <WiFiClient.h>
#include <WebServer.h>
#include <ESPmDNS.h>
#include <Adafruit_Sensor.h> 
#include <DHT.h>
#include <Firebase_ESP_Client.h>
#include <FirebaseFS.h>
#include "addons/TokenHelper.h"

#define DHTPIN 32
#define DHTTYPE DHT11
#define FAN_PIN 25
#define RelayPin 27
#define MOISTURE_THRESHOLD 500  // Seuil de sécheresse du sol
#define API_KEY "mon_api_key"
#define FIREBASE_PROJECT_ID "mon_id_projet"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;
bool signupOK = false;

WebServer server(80);
DHT dht(DHTPIN, DHTTYPE); 

const int moisturePin = 34;
const int waterlevPin = 35;
const char *ssid = "OPPO A54";
const char *password = "19191919";

float tempC;
float humidity;
float moisturePercentage;
int moistPerLow = 20;
int moistPerHigh = 60;

bool toggleRelay = LOW;
bool prevMode = true;

void handleRoot() {
  char msg[1500];
  float t = readDHTTemperature();
  float h = readDHTHumidity();

  snprintf(msg, 1500,
           "<html>\
  <head>\
    <meta http-equiv='refresh' content='120'/>\
    <meta name='viewport' content='width=device-width, initial-scale=1'>\
    <link rel='stylesheet' href='https://use.fontawesome.com/releases/v5.7.2/css/all.css' crossorigin='anonymous'>\
    <title>Pot Intelligent</title>\
    <style>\
    html { font-family: Arial; text-align: center;}\ 
    h2 { font-size: 3.0rem; }\
    p { font-size: 3.0rem; }\
    .units { font-size: 1.2rem; }\
    .dht-labels{ font-size: 1.5rem; padding-bottom: 15px;}\ 
    </style>\
  </head>\
  <body>\
      <h2>** Pot Intelligent **</h2>\
      <p>\
        <i class='fas fa-thermometer-half' style='color:#ca3517;'></i>\
        <span class='dht-labels'>Temperature</span>\
        <span>%.2f</span>\
        <sup class='units'>&deg;C</sup>\
      </p>\
      <p>\
        <i class='fas fa-tint' style='color:#00add6;'></i>\
        <span class='dht-labels'>Air Humidity</span>\
        <span>%.2f</span>\
        <sup class='units'>&percnt;</sup>\
      </p>\
  </body>\
</html>", t, h);
  server.send(200, "text/html", msg);
}

void setup() {
  Serial.begin(115200);
  dht.begin();

  pinMode(FAN_PIN, OUTPUT); 
  digitalWrite(FAN_PIN, HIGH);
  pinMode(RelayPin, OUTPUT);
  digitalWrite(RelayPin, HIGH); 

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.println("");

  unsigned long startAttemptTime = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - startAttemptTime < 20000) { 
    delay(500);
    Serial.print(".");
  }

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("\n⚠️ Échec de connexion au WiFi !");
    return;
  }

  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  if (MDNS.begin("esp32")) {
    Serial.println("MDNS responder started");
  }
  server.on("/", handleRoot);
  server.begin();
  Serial.println("HTTP server started");
  Serial.println("🌱 Initialisation du système Smart Plot...");

  // ✅ Configuration Firebase
  config.api_key = API_KEY;

  // Authentification par Email/Password
  auth.user.email = "dhia.rezgui@ensi-uma.tn";
  auth.user.password = "dhia12345";

  config.token_status_callback = tokenStatusCallback;
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  signupOK = true;
}

void loop() {
  server.handleClient();

  int soilMoisture = analogRead(moisturePin);
  moisturePercentage = (1.0 - ((float)soilMoisture / 4095.0)) * 100.0;
  int waterLevel = analogRead(waterlevPin);
  float waterLevelPercent = ((float)waterLevel / 4095.0) * 100.0;

  tempC = readDHTTemperature();
  humidity = readDHTHumidity();

  if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 15000 || sendDataPrevMillis == 0)) {
    sendDataPrevMillis = millis();
    time_t now = Firebase.getCurrentTime();
    struct tm *timeinfo = gmtime(&now);
    char timestampISO[25];
    strftime(timestampISO, sizeof(timestampISO), "%Y-%m-%dT%H:%M:%SZ", timeinfo);
    
    FirebaseJson content;
    content.set("fields/humidity/doubleValue", humidity);
    content.set("fields/tempC/doubleValue", tempC);
    content.set("fields/soilMoisture/doubleValue", moisturePercentage);
    content.set("fields/waterLevel/doubleValue", waterLevelPercent);
    content.set("fields/timestamp/timestampValue", String(timestampISO));
    String documentPath = "sensor_readings/" + String(millis());

    if (Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), content.raw())) {
      Serial.println("✅ Document envoyé à Firestore !");
    } else {
      Serial.println("❌ Échec : " + fbdo.errorReason());
    }
  }

  // Ventilateur en fonction de la température
  if (tempC >= 25) {
    digitalWrite(FAN_PIN, HIGH); 
  } else {
    digitalWrite(FAN_PIN, LOW); 
  }

  // Affichage
  Serial.print("🌡 Température : "); Serial.print(tempC); Serial.println(" °C");
  Serial.print("💧 Humidité de l'air : "); Serial.print(humidity); Serial.println(" %");
  Serial.print("🌿 Humidité du sol : "); Serial.print(moisturePercentage); Serial.println(" %");
  Serial.print("🚰 Niveau d'eau : "); Serial.print(waterLevelPercent); Serial.println(" %");

  if (moisturePercentage < (MOISTURE_THRESHOLD / 40.95)) {  
    Serial.println("🚨 BESOIN D'ARROSAGE !");
  } else {
    Serial.println("✅ Humidité du sol OK.");
  }

  Serial.println("----------------------------------");
  

  delay(2000);
}

float readDHTTemperature() {
  float t = dht.readTemperature();
  if (isnan(t)) {    
    Serial.println("❌ Failed to read from DHT sensor!");
    return -1;
  } else {
    return t;
  }
}

float readDHTHumidity() {
  float h = dht.readHumidity();
  if (isnan(h)) {
    Serial.println("❌ Failed to read from DHT sensor!");
    return -1;
  } else {
    return h;
  }
}

void controlPump() {
  if (prevMode) {
    if (moisturePercentage < moistPerLow) {
      digitalWrite(RelayPin, HIGH);
      toggleRelay = LOW;
    } else if (moisturePercentage > moistPerHigh) {
      digitalWrite(RelayPin, LOW);
      toggleRelay = HIGH;
    }
  }
}

void handleToggle() {
  if (!prevMode) {
    digitalWrite(RelayPin, !digitalRead(RelayPin));
    toggleRelay = !toggleRelay;
  }
  server.send(200, "text/plain", "Pump toggled");
}

void handleMode() {
  prevMode = !prevMode;
  server.send(200, "text/plain", "Mode toggled");
}
