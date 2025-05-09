const int RELAY_PIN = 25;  // Broche connectée au relais (adaptez-la)
const int TEST_DURATION = 3000; // Durée du test en ms (3 secondes)

void setup() {
  Serial.begin(115200);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, HIGH); // Désactive le ventilateur au démarrage (relais normalement ouvert)
  Serial.println("Test du ventilateur");
  Serial.println("---------------------");
}

void loop() {
  // Active le ventilateur
  Serial.println("🔵 Activation du ventilateur...");
  digitalWrite(RELAY_PIN, LOW); // RELAY ON (si votre relais est actif à LOW)
  delay(TEST_DURATION);

  // Désactive le ventilateur
  Serial.println("🔴 Désactivation du ventilateur...");
  digitalWrite(RELAY_PIN, HIGH); // RELAY OFF
  delay(3000); // Pause de 3 secondes avant le prochain cycle
}
