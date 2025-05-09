#include <WiFi.h>
#include <WiFiClient.h>
#include <WebServer.h>
#include <ESPmDNS.h>
#include <Adafruit_Sensor.h> 
#include <DHT.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <BH1750.h>
#include <AceButton.h>

#define DHTPIN 32
#define DHTTYPE DHT11
#define MOISTURE_THRESHOLD 500  // Seuil de sécheresse du sol
#define FAN_PIN 27
#define RelayPin 25
#define RelayButtonPin 34
#define ModeSwitchPin 33
#define ModeLed 15
using namespace ace_button;

WebServer server(80);
DHT dht(DHTPIN, DHTTYPE); 
const int moisturePin = 26;
const char *ssid = "TOPNET_EC88";
const char *password = "bqfvt4h9wr";
float tempC;
float humidity;
LiquidCrystal_I2C lcd(0x27, 16, 2);
int SDA_PIN = 21;
int SCL_PIN = 22;

byte smileyContent[8] = {0b00000,0b00000,0b01010,0b00000,0b10001,0b01110,0b00000,0b00000};
byte smileyNeutre[8] = {0b00000,0b00000,0b01010,0b00000,0b11111,0b00000,0b00000,0b00000};
byte smileyTriste[8] = {0b00000,0b00000,0b01010,0b00000,0b01110,0b10001,0b00000,0b00000};

ButtonConfig config1;
AceButton button1(&config1);
ButtonConfig config2;
AceButton button2(&config2);
int moistPerLow =   20 ;  //min moisture %
int moistPerHigh =   80 ;  //max moisture %

void handleEvent1(AceButton*, uint8_t, uint8_t);
void handleEvent2(AceButton*, uint8_t, uint8_t);
bool toggleRelay = LOW;
bool prevMode = true;
String currMode = "A";

void handleRoot() {
  char msg[1500];
  float t = readDHTTemperature();
  float h = readDHTHumidity();

  // Vérifier si la lecture est valide
  /*if (t == -1 || h == -1) {
        server.send(500, "text/plain", "Erreur de lecture des capteurs");
        return;
  }*/



  snprintf(msg, 1500,
           "<html>\
  <head>\
    <meta http-equiv='refresh' content='120'/>\
    <meta name='viewport' content='width=device-width, initial-scale=1'>\
    <link rel='stylesheet' href='https://use.fontawesome.com/releases/v5.7.2/css/all.css' integrity='sha384-fnmOCqbTlWIlj8LyTjo7mOUStjsKC4pOpQbqyi7RrhN7udi9RwhKkMHpvLbHG9Sr' crossorigin='anonymous'>\
    <script src='https://kit.fontawesome.com/0dba0dae4a.js' crossorigin='anonymous'></script>\
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
      <h2>Pot  Intelligent !</h2>\
      <p>\
        <i class='fas fa-thermometer-half' style='color:#ca3517;'></i>\
        <span class='dht-labels'>Temperature</span>\
        <span>%.2f</span>\
        <sup class='units'>&deg;C</sup>\
      </p>\
      <p>\
        <i class='fa-solid fa-leaf' style='color: #50b43c;'></i>\
        <span class='dht-labels'>Air Humidity</span>\
        <span>%.2f</span>\
        <sup class='units'>&percnt;</sup>\
      </p>\
      <p>\
        <i class='fas fa-tint' style='color:#00add6;'></i>\
        <span class='dht-labels'> Moisture</span>\
        <span>%.2f</span>\
        <sup class='units'>&percnt;</sup>\
      </p>\
      <div class='box'>\
        <h2>Mode: ' + String(prevMode ? 'Auto' : 'Manual') + '</h2>\
      </div>\
      <div class='box'>\
        <h2>Pump: ' + String(toggleRelay ? 'ON' : 'OFF') + '</h2>\
      </div>\
      <button id='pumpBtn' class='button' onclick='togglePump()'>Toggle Pump</button>\
      <button id='modeBtn' class='button' onclick='toggleMode()'>Toggle Mode</button>\
      <script>function togglePump(){ fetch('/toggle'); } function toggleMode(){ fetch('/mode'); }</script>\
  </body>\
</html>",t,h);
  server.send(200, "text/html", msg);
}



void setup() {
    Serial.begin(115200);
    dht.begin();
    pinMode(FAN_PIN, OUTPUT); 
    digitalWrite(FAN_PIN, LOW);
    pinMode(RelayPin, OUTPUT);
    pinMode(ModeLed, OUTPUT);
    pinMode(RelayButtonPin, INPUT_PULLUP);
    pinMode(ModeSwitchPin, INPUT_PULLUP);
    digitalWrite(RelayPin, LOW);
    digitalWrite(ModeLed, LOW);
    config1.setEventHandler(button1Handler);
    config2.setEventHandler(button2Handler);
  
    button1.init(RelayButtonPin);
    button2.init(ModeSwitchPin);


    
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
    server.on("/toggle", handleToggle);
    server.on("/mode", handleMode);


    server.begin();
    digitalWrite(ModeLed, prevMode);
    Serial.println("HTTP server started");
    Serial.println("🌱 Initialisation du système Smart Plot...");
    Wire.begin(SDA_PIN, SCL_PIN);
    if (lightSensor.begin()) {
        Serial.println("BH1750 détecté avec succès !");
    } else {
        Serial.println("Erreur de communication avec BH1750 !");
    while (1);
  }

    lcd.begin(16, 2);
    lcd.backlight();
    lcd.createChar(1, smileyContent);
    lcd.createChar(2, smileyNeutre);
    lcd.createChar(3, smileyTriste);
    lcd.clear();
}


void loop() {
    server.handleClient();
    delay(2);//allow the cpu to switch to other tasks
    

    // Lecture humidité du sol
    float lux = lightSensor.readLightLevel();
    int soilMoisture = analogRead(moisturePin);
    float moisturePercentage = ((float)soilMoisture / 4095.0) * 100.0;

    float tempC = readDHTTemperature();
    float humidity = readDHTHumidity();

    // Déterminer quel emoji afficher
    bool tempOK = (tempC >= 20 && tempC <= 30);
    bool humOK = (humidity >= 40 && humidity <= 70);
    bool solOK = (moisturePercentage > moistPerLow);
    bool solTooWet = (moisturePercentage >= moistPerHigh); 

    if (solTooWet) {
      digitalWrite(FAN_PIN, HIGH); 
    } else {
      digitalWrite(FAN_PIN, LOW); 
    }
    bool luxOK = (lux >= 100 && lux <= 1000);

    byte emoji = 0;

    if (luxOK && tempOK && humOK && solOK) {
    emoji = 1; // 😊
    } else if ((!luxOK && tempOK && humOK && solOK) || (luxOK && !tempOK && humOK && solOK) || (luxOK && tempOK && !humOK && solOK) || (luxOK && tempOK && humOK && !solOK)) {
      emoji = 2; // 😐
    } else {
      emoji = 3; // 😢
    }

    // 🔹 1. Affichage de l'emoji seul pendant 4 secondes
    lcd.clear();
    lcd.setCursor(7, 0);  // Centré
    lcd.write(byte(emoji));
    delay(4000);

    // 🔹 2. Affichage des valeurs pendant 4 secondes
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("T:");
    lcd.print(tempC, 1);
    lcd.print("C H:");
    lcd.print(humidity, 0);
    lcd.print("%");

    lcd.setCursor(0, 1);
    lcd.print("Sol:");
    lcd.print(moisturePercentage, 0);
    lcd.print("%");
    lcd.print("% Lux:");
    lcd.print(lux, 0);
    delay(4000);

    controlPump();
    button1.check();
    button2.check();
}
}

float readDHTTemperature() {
  // Sensor readings may also be up to 2 seconds
  // Read temperature as Celsius (the default)
  float t = dht.readTemperature();
  if (isnan(t)) {    
    Serial.println("Failed to read from DHT sensor!");
    return -1;
  }
  else {
    Serial.println(t);
    return t;
  }
}

float readDHTHumidity() {
  // Sensor readings may also be up to 2 seconds
  float h = dht.readHumidity();
  if (isnan(h)) {
    Serial.println("Failed to read from DHT sensor!");
    return -1;
  }
  else {
    Serial.println(h);
    return h;
  }
}

void controlPump() {
    if (prevMode) {
        if (moisturePercentage < moistPerLow) {
            digitalWrite(RelayPin, HIGH);
            toggleRelay = HIGH;
        }
        if (moisturePercentage > moistPerHigh) {
            digitalWrite(RelayPin, LOW);
            toggleRelay = LOW;
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
    digitalWrite(ModeLed, prevMode);
    server.send(200, "text/plain", "Mode toggled");
}

void button1Handler(AceButton* button, uint8_t eventType, uint8_t buttonState) {
  Serial.println("EVENT1");
  switch (eventType) {
    case AceButton::kEventReleased:
      //Serial.println("kEventReleased");
      if (!prevMode) {
            handleToggle();
        }
    break;
  }
}

void button2Handler(AceButton* button, uint8_t eventType, uint8_t buttonState) {
  Serial.println("EVENT2");
  switch (eventType) {
    case AceButton::kEventReleased:
      //Serial.println("kEventReleased");
      handleMode();
      break;
  }
}