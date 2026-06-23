#include <ESP32Servo.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64

#define TRIG_PIN 5
#define ECHO_PIN 18

Servo servo1;
Servo servo2;
Servo servo3;
Servo servo4;
Servo servo5;

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);
Adafruit_MPU6050 mpu;

float phase = 0;

void setup() {

  Serial.begin(115200);

  servo1.attach(26);
  servo2.attach(27);
  servo3.attach(14);
  servo4.attach(12);
  servo5.attach(13);

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  Wire.begin(21, 22);

  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("OLED Failed");
    while (1);
  }

  if (!mpu.begin()) {
    Serial.println("MPU6050 Failed");
    while (1);
  }

  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);

  Serial.println("SURGE090 Ready");
}

float getDistance() {

  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);

  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);

  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH);

  return duration * 0.034 / 2.0;
}

void moveSnake() {

  servo1.write(90 + 40 * sin(phase));
  servo2.write(90 + 40 * sin(phase + 0.8));
  servo3.write(90 + 40 * sin(phase + 1.6));
  servo4.write(90 + 40 * sin(phase + 2.4));
  servo5.write(90 + 40 * sin(phase + 3.2));

  phase += 0.12;
}

void stopSnake() {

  servo1.write(90);
  servo2.write(90);
  servo3.write(90);
  servo4.write(90);
  servo5.write(90);
}

void loop() {

  float distance = getDistance();

  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  if (distance > 20) {
    moveSnake();
  } else {
    stopSnake();
  }

  display.clearDisplay();

  display.setTextSize(1);

  display.setCursor(0, 0);
  display.println("SURGE090");

  display.setCursor(0, 10);
  display.print("Dist:");
  display.print(distance, 1);
  display.println("cm");

  display.setCursor(0, 20);
  display.print("Ax:");
  display.print(a.acceleration.x, 1);

  display.setCursor(0, 30);
  display.print("Ay:");
  display.print(a.acceleration.y, 1);

  display.setCursor(0, 40);
  display.print("Az:");
  display.print(a.acceleration.z, 1);

  display.setCursor(0, 52);

  if (distance > 20) {
    display.print("STATUS: RUN");
  } else {
    display.print("OBSTACLE!");
  }

  display.display();

  delay(30);
}