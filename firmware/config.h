#define TRIG 12
#define ECHO 13

void setup() {
  Serial.begin(115200);
  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT);
  Serial.println("=============================");
  Serial.println("  FLOOD PREDICTION SYSTEM");
  Serial.println("  by Ayush Deep | GEC Vaishali");
  Serial.println("=============================");
  Serial.println("Water Level Sensor Ready!");
}

void loop() {
  digitalWrite(TRIG, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG, LOW);

  long duration = pulseIn(ECHO, HIGH);
  float distance = duration * 0.034 / 2;
  float waterLevel = 400 - distance;

  Serial.print("Water Level: ");
  Serial.print(waterLevel);
  Serial.print(" cm  |  Status: ");

  if (waterLevel > 380) {
    Serial.println("EMERGENCY - EVACUATE NOW!");
  } else if (waterLevel > 300) {
    Serial.println("WARNING - Prepare to evacuate");
  } else if (waterLevel > 200) {
    Serial.println("WATCH - Stay alert");
  } else {
    Serial.println("SAFE - Normal level");
  }

  delay(2000);
}