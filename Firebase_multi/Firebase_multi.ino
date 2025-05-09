#include <WiFi.h>
#include <WiFiClient.h>
#include <WebServer.h>
#include <ESPmDNS.h>
#include <Adafruit_Sensor.h> 
#include <DHT.h>
#include <Firebase_ESP_Client.h>
#include "addons/RTDBHelper.h"
#include "addons/TokenHelper.h"

#define DHTPIN 32
#define DHTTYPE DHT11
#define MOISTURE_THRESHOLD 500  // Seuil de sécheresse du sol
#define API_KEY "AIzaSyAbLUjK5ZobAXCO-l0gu9w4YhbHUgglPeQ"
#define DATABASE_URL "https://smart-pot-81cad-default-rtdb.firebaseio.com/"
#define SEND_INTERVAL 15000  // Intervalle d'envoi des données en ms

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
unsigned long sendDataPrevMillis = 0;
bool signupOK = false;

WebServer server(80);
DHT dht(DHTPIN, DHTTYPE); 
const int moisturePin = 26;
const char *ssid = "OPPO A54";
const char *password = "19191919";
float tempC;
float humidity;

void handleRoot() {
  char msg[1500];
  float t = readDHTTemperature();
  float h = readDHTHumidity();

  snprintf(msg, 1500,
           "<html>\
  <head>\
    <meta http-equiv='refresh' content='120'/>\
    <meta name='viewport' content='width=device-width, initial-scale=1'>\
    <link rel='stylesheet' href='https://use.fontawesome.com/releases/v5.7.2/css/all.css' integrity='sha384-fnmOCqbTlWIlj8LyTjo7mOUStjsKC4pOpQbqyi7RrhN7udi9RwhKkMHpvLbHG9Sr' crossorigin='anonymous'>\
    <title>Pot Intelligent</title>\
    <style>\
    html { font-family: Arial; display: inline-block; margin: 0px auto; text-align: center;}\
    h2 { font-size: 3.0rem; }\
    p { font-size: 3.0rem; }\
    .units { font-size: 1.2rem; }\
    .dht-labels{ font-size: 1.5rem; vertical-align:middle; padding-bottom: 15px;}\
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
    
    config.api_key = API_KEY;
    config.database_url = DATABASE_URL;
    if(Firebase.signUp(&config, &auth, "", "")) {
      Serial.println("signUp OK");
      signupOK = true;
    } else {
      Serial.printf("%s\n", config.signer.signupError.message.c_str());
    }
    config.token_status_callback = tokenStatusCallback;
    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);
}

void sendSensorDataToFirebase(float temperature, float airHumidity, int soilMoisture, float moisturePercentage) {
  if (Firebase.ready() && signupOK) {
    // Créer un nœud avec timestamp comme clé
    String timestampPath = "/SensorData/" + String(millis());
    
    // Créer un objet JSON pour stocker toutes les données
    FirebaseJson json;
    json.set("timestamp", millis());
    json.set("temperature", temperature);
    json.set("airHumidity", airHumidity);
    json.set("soilMoisture", soilMoisture);
    json.set("moisturePercentage", moisturePercentage);
    
    // Envoyer les données
    if(Firebase.RTDB.setJSON(&fbdo, timestampPath.c_str(), &json)) {
      Serial.println("- Données envoyées avec succès à: " + fbdo.dataPath());
    } else {
      Serial.println("Échec de l'envoi: " + fbdo.errorReason());
    }
    
    // Garder également les dernières valeurs disponibles séparément
    if(Firebase.RTDB.setFloat(&fbdo, "LastValues/temperature", temperature) &&
       Firebase.RTDB.setFloat(&fbdo, "LastValues/airHumidity", airHumidity) &&
       Firebase.RTDB.setInt(&fbdo, "LastValues/soilMoisture", soilMoisture) &&
       Firebase.RTDB.setFloat(&fbdo, "LastValues/moisturePercentage", moisturePercentage)) {
      Serial.println("- Dernières valeurs mises à jour");
    } else {
      Serial.println("Échec de la mise à jour des dernières valeurs: " + fbdo.errorReason());
    }
  }
}

void loop() {
    server.handleClient();
    delay(2);  // allow the cpu to switch to other tasks
    
    // Lecture des capteurs
    int soilMoisture = analogRead(moisturePin);
    float moisturePercentage = ((float)soilMoisture / 4095.0) * 100.0;
    tempC = readDHTTemperature();
    humidity = readDHTHumidity();
    
    // Envoyer les données à Firebase à intervalle régulier
    if(millis() - sendDataPrevMillis > SEND_INTERVAL || sendDataPrevMillis == 0) {
      sendDataPrevMillis = millis();
      sendSensorDataToFirebase(tempC, humidity, soilMoisture, moisturePercentage);
    }

    // Affichage des données
    Serial.print("🌡 Température : "); Serial.print(tempC); Serial.println(" °C");
    Serial.print("💧 Humidité de l'air : "); Serial.print(humidity); Serial.println(" %");
    Serial.print("🌿 Humidité du sol : "); Serial.print(soilMoisture); Serial.print(" ("); 
    Serial.print(moisturePercentage); Serial.println(" %)");

    // Vérification de l'humidité du sol
    if (moisturePercentage < (MOISTURE_THRESHOLD / 40.95)) {  
        Serial.println("🚨 BESOIN D'ARROSAGE ! 🚨");
    } else {
        Serial.println("✅ Humidité du sol OK.");
    }

    Serial.println("----------------------------------");
    delay(2000);
}

float readDHTTemperature() {
  float t = dht.readTemperature();
  if (isnan(t)) {    
    Serial.println("Failed to read from DHT sensor!");
    return -1;
  }
  else {
    return t;
  }
}

float readDHTHumidity() {
  float h = dht.readHumidity();
  if (isnan(h)) {
    Serial.println("Failed to read from DHT sensor!");
    return -1;
  }
  else {
    return h;
  }
}