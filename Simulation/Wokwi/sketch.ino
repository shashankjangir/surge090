/*
 * SURGE-SNAKE Head-Mounted Obstacle Sensor Simulation
 * Designed for ESP32 and HC-SR04 Ultrasonic Sensor on Wokwi.
 * Communicates distance data to Raspberry Pi over Bluetooth Serial.
 */

#include "BluetoothSerial.h"

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to enable it
#endif

BluetoothSerial SerialBT;

// GPIO connections on ESP32
const int TRIG_PIN = 5;
const int ECHO_PIN = 18;

void setup() {
  // Initialize standard hardware Serial for monitoring
  Serial.begin(115200);
  Serial.println("[SYSTEM] Initializing SURGE-SNAKE ESP32 Node...");

  // Initialize Bluetooth Serial
  SerialBT.begin("SURGE-SNAKE-ESP32"); 
  Serial.println("[SYSTEM] Bluetooth Serial device started as 'SURGE-SNAKE-ESP32'");

  // Initialize Ultrasonic Sensor Pin Modes
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  
  Serial.println("[SYSTEM] Hardware setup complete. Starting measurement loop...");
}

void loop() {
  // 1. Send trigger pulse
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  
  // 2. Read pulse echo duration (microseconds)
  long duration = pulseIn(ECHO_PIN, HIGH, 30000); // 30ms timeout
  
  // 3. Calculate distance in cm (Speed of sound = 340 m/s = 0.034 cm/us)
  float distanceCm = duration * 0.034 / 2.0;
  
  // 4. Handle out of range readings
  if (duration == 0 || distanceCm > 400.0) {
    distanceCm = -1.0; // Out of range or no echo
  }

  // 5. Output to serial monitor
  Serial.print("Sensor Distance: ");
  if (distanceCm < 0) {
    Serial.println("OUT_OF_RANGE");
  } else {
    Serial.print(distanceCm, 1);
    Serial.println(" cm");
  }
  
  // 6. Transmit to Raspberry Pi over Bluetooth Serial (formatted packet)
  SerialBT.print("DIST:");
  SerialBT.println(distanceCm, 1);
  
  // Send data at 10 Hz (every 100 ms) to avoid saturating the link
  delay(100); 
}
