#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// Déclaration des caractères personnalisés
byte smileyContent[8] = {0b00000,0b00000,0b01010,0b00000,0b10001,0b01110,0b00000,0b00000};
byte smileyNeutre[8] = {0b00000,0b00000,0b01010,0b00000,0b11111,0b00000,0b00000,0b00000};
byte smileyTriste[8] = {0b00000,0b00000,0b01010,0b00000,0b01110,0b10001,0b00000,0b00000};

int emoji = 1;
int SDA_PIN = 18;
int SCL_PIN = 19;

// Initialisation de l'écran LCD (ajout de l'adresse I2C)
LiquidCrystal_I2C lcd(0x27, 16, 2); // Adresse I2C généralement 0x27 ou 0x3F

void setup() {
  Serial.begin(115200);
  Wire.begin(SDA_PIN, SCL_PIN);
  lcd.init(); // Initialisation avant d'utiliser begin()
  lcd.backlight();
  
  // Création des caractères personnalisés
  lcd.createChar(1, smileyContent);
  lcd.createChar(2, smileyNeutre);
  lcd.createChar(3, smileyTriste);
  
  lcd.clear();
}

void loop() {
  // 1. Affichage du smiley
  lcd.clear();
  lcd.setCursor(7, 0);  // Centré
  lcd.write(byte(emoji));
  delay(4000);

  // 2. Affichage des valeurs
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("T:");
  lcd.print(20); // Correction: suppression du deuxième paramètre
  lcd.print("C H:");
  lcd.print(30); // Correction: suppression du deuxième paramètre
  lcd.print("%");

  lcd.setCursor(0, 1);
  lcd.print("Sol:");
  lcd.print(40); // Correction: suppression du deuxième paramètre
  lcd.print("% Lux:");
  lcd.print(50); // Correction: suppression du deuxième paramètre
  
  delay(4000);
}