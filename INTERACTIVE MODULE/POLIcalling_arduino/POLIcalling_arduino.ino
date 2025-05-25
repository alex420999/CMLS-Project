#include <Wire.h>
#include "Adafruit_TCS34725.h"

#define TOUCH_PIN 2
#define NUM_SAMPLES 5

Adafruit_TCS34725 tcs = Adafruit_TCS34725(
  TCS34725_INTEGRATIONTIME_600MS,
  TCS34725_GAIN_4X
);

unsigned long lastTouchTime = 0;

// Funzione per calcolare la mediana di un array
uint16_t median(uint16_t arr[], int n) {
  // Bubble sort semplice
  for (int i = 0; i < n - 1; i++) {
    for (int j = i + 1; j < n; j++) {
      if (arr[j] < arr[i]) {
        uint16_t temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
      }
    }
  }
  if (n % 2 == 1)
    return arr[n / 2];
  else
    return (arr[n / 2 - 1] + arr[n / 2]) / 2;
}

void setup() {
  Serial.begin(9600);
  pinMode(TOUCH_PIN, INPUT);

  if (!tcs.begin()) {
    Serial.println("Color sensor not found! Check wiring.");
    while (1);
  } else {
    Serial.println("Color sensor initialized.");
  }
}

void loop() {
  if (digitalRead(TOUCH_PIN) == HIGH) {
    unsigned long now = millis();
    unsigned long interval = now - lastTouchTime;
    lastTouchTime = now;

    uint16_t r_samples[NUM_SAMPLES];
    uint16_t g_samples[NUM_SAMPLES];
    uint16_t b_samples[NUM_SAMPLES];
    uint16_t c_samples[NUM_SAMPLES];

    // Prendi NUM_SAMPLES campioni
    for (int i = 0; i < NUM_SAMPLES; i++) {
      uint16_t r, g, b, c;
      tcs.getRawData(&r, &g, &b, &c);
      r_samples[i] = r;
      g_samples[i] = g;
      b_samples[i] = b;
      c_samples[i] = c;
      delay(1); // piccolo ritardo tra i campioni
    }

    // Calcola mediana
    uint16_t r_med = median(r_samples, NUM_SAMPLES);
    uint16_t g_med = median(g_samples, NUM_SAMPLES);
    uint16_t b_med = median(b_samples, NUM_SAMPLES);
    uint16_t c_med = median(c_samples, NUM_SAMPLES);

    if (c_med == 0) c_med = 1; // evita divisione per zero

    // Normalizza in base a c_med
    float r_norm = (float)r_med / c_med;
    float g_norm = (float)g_med / c_med;
    float b_norm = (float)b_med / c_med;

    r_norm = r_norm > 1.0 ? 1.0 : r_norm;
    g_norm = g_norm > 1.0 ? 1.0 : g_norm;
    b_norm = b_norm > 1.0 ? 1.0 : b_norm;

    uint8_t r_final = (uint8_t)(r_norm * 255);
    uint8_t g_final = (uint8_t)(g_norm * 255);
    uint8_t b_final = (uint8_t)(b_norm * 255);
    uint8_t c_final = (uint8_t)((float)c_med / 65535.0 * 255);

    Serial.print("R: "); Serial.print(r_final);
    Serial.print(", G: "); Serial.print(g_final);
    Serial.print(", B: "); Serial.print(b_final);
    Serial.print(", C: "); Serial.print(c_final);
    Serial.print(", Interval: "); Serial.println(interval);

    delay(100); // evita letture troppo ravvicinate
  }
}
