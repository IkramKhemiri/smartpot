const int RELAY_PIN = 27;  // Broche connectée au relais (adaptez-la)
const int TEST_DURATION = 3000; // Durée du test en ms (3 secondes)

void setup() {
  Serial.begin(115200);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, HIGH); // Désactive la pompe au démarrage (relais normalement ouvert)
  Serial.println("Test de la pompe à eau");
  Serial.println("---------------------");
}

void loop() {
  // Active la pompe
  Serial.println("🔵 Activation de la pompe...");
  digitalWrite(RELAY_PIN, LOW); // RELAY ON (si votre relais est actif à LOW)
  delay(TEST_DURATION);

  // Désactive la pompe
  Serial.println("🔴 Désactivation de la pompe...");
  digitalWrite(RELAY_PIN, HIGH); // RELAY OFF
  delay(3000); // Pause de 3 secondes avant le prochain cycle
}