class WaveAnimation {
  int waveType;
  color strokeColor;
  float t = 0;
  int rectX;
  int rectY;
  int rectWidth;
  int rectHeight;
  float ampl = 1;
  float waveLength = 50.0;
  float dynamicStroke = 1;

  WaveAnimation(int waveType, color strokeColor, int rectX, int rectY, int rectWidth, int rectHeight) {
    this.waveType = waveType;
    this.strokeColor = strokeColor;
    this.rectX = rectX;
    this.rectY = rectY;
    this.rectWidth = rectWidth;
    this.rectHeight = rectHeight;
  }
  
  float getY(int x) {
    float offset = t * 0.5;
    float waveX = (x + offset) % waveLength;
    float normX = waveX / waveLength;
  
    switch (waveType) {
      case 0: return sin((x + t) * TWO_PI / waveLength) * (rectHeight / 2);
      case 1: return (normX * 2 - 1) * (rectHeight / 2); // Saw
      case 2: return (normX < 0.5 ? 1 : -1) * (rectHeight / 2); // Square
      case 3: return (2 * abs(2 * normX - 1) - 1) * (rectHeight / 2); // Triangle
      case 4: return (normX > 0.02 ? 1 : -1) * (rectHeight / 2); // Pulse
      case 5: return random(-rectHeight / 2, rectHeight / 2); // Noise
      case 6: return (x == int(t) % rectWidth) ? -rectHeight / 2 : 0; // Blip (simplified)
      default: return 0;
    }
  }
  
  float getStroke(){
    return this.dynamicStroke;
  }
  
  void setAmplitude(float vol){
    this.ampl = vol;
  }

  void update() {
  stroke(strokeColor);
  dynamicStroke = map(ampl, 0, 1, 1, 6);  // o scegli range adatto
  strokeWeight(dynamicStroke);
  noFill();

  pushMatrix();
  translate(rectX, rectY);

  switch (waveType) {
    case 0: drawSine(); break;
    case 1: drawSaw(); break;
    case 2: drawSquare(); break;
    case 3: drawTriangle(); break;
    case 4: drawPulse(); break;
    case 5: drawNoise(); break;
    case 6: drawBlip(); break;
  }

  popMatrix();

  t += 2;
}

void drawSine() {
  beginShape();
  float phaseSpeed = 0.05;
  for (int x = 0; x < rectWidth; x++) {
    float y = ampl * sin(TWO_PI * x / waveLength + t * phaseSpeed) * (rectHeight / 2);
    vertex(x, y);
  }
  endShape();
}

  void drawSaw() {
    beginShape();
    float offset = t * 0.5;
    for (int x = 0; x < rectWidth; x++) {
      float pos = (x + offset) % waveLength;
      float saw = pos / waveLength;
      float y = this.ampl * (saw * 2 - 1) * (rectHeight / 2);
      vertex(x, y);
    }
    endShape();
  }

  void drawSquare() {
    beginShape();
    float offset = t * 0.5;
    for (int x = 0; x < rectWidth; x++) {
      float pos = (x + offset) % waveLength;
      float saw = pos / waveLength;
      float y = (saw < 0.5) ? this.ampl *(rectHeight / 2) : -this.ampl *(rectHeight / 2);
      vertex(x, y);
    }
    endShape();
  }

  void drawTriangle() {
    beginShape();
    float offset = t * 0.5;
    for (int x = 0; x < rectWidth; x++) {
      float pos = (x + offset) % waveLength;
      float saw = pos / waveLength;
      float y = this.ampl * (2 * abs(2 * saw - 1) - 1) * (rectHeight / 2);
      vertex(x, y);
    }
    endShape();
  }

  void drawPulse() {
    beginShape();
    float offset = t * 0.5;
    for (int x = 0; x < rectWidth; x++) {
      float pos = (x + offset) % waveLength;
      float saw = pos / waveLength;
      float y = (saw > 0.02) ? (rectHeight / 2) : -this.ampl *(rectHeight / 2);
      vertex(x, y);
    }
    endShape();
  }

  void drawNoise() {
    beginShape();
    for (int x = 0; x < rectWidth; x++) {
      float y = this.ampl * random(-rectHeight / 2, rectHeight / 2);
      vertex(x, y);
    }
    endShape();
  }

  void drawBlip() {
  strokeWeight(2);
  line(0, 0, rectWidth, 0);

  float blipX = map(t % rectWidth, 0, rectWidth, 0, rectWidth);
  strokeWeight(4);
  int steps = 10;
  float baseHeight = this.ampl * rectHeight / 2;

  for (int i = -steps/2; i <= steps/2; i++) {
    float xPos = blipX + i * 2;
    float noiseHeight = baseHeight + random(-rectHeight * 0.1, rectHeight * 0.1);
    line(xPos, 0, xPos, -noiseHeight);
  }
}
}
