// Test capteur d'humidité du sol AB054 avec ESP32

const int moisturePin = 34;  // Entrée analogique ESP32 branchée au capteur
int sensorValue = 0;         // Valeur brute lue
float moisturePercent = 0.0; // Valeur convertie en pourcentage

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("🌱 Test Capteur d'Humidité du Sol AB054 - Démarrage...");
}

void loop() {
  sensorValue = analogRead(moisturePin); // Lire la valeur analogique (0 à 4095)
  
  // Conversion simple en pourcentage (%)
  // Attention : Inversé ! Plus c'est sec, plus la tension est faible.
  moisturePercent = (1.0 - (float(sensorValue) / 4095.0)) * 100.0;

  // Afficher les résultats
  Serial.print("Valeur brute : ");
  Serial.print(sensorValue);
  Serial.print("  ->  Humidité : ");
  Serial.print(moisturePercent, 1);
  Serial.println(" %");

  delay(1000); // 1 seconde entre chaque lecture
}
