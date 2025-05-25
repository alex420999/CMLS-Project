import processing.serial.*;
import controlP5.*;
import oscP5.*;
import netP5.*;

static final int NUM_LINES = 10;

Serial myPort;
ControlP5 cp5;
OscP5 oscP5;
NetAddress sc;

// Synth parameters
int wave1 = 0, wave2 = 0, wave3 = 0;
float vol1 = 1.0, vol2 = 1.0, vol3 = 1.0;
float att = 0.01, dec = 0.2, sust = 0.5, rel = 0.5;
float ens1 = 0.3, ens2 = 0.3, ens3 = 0.3;
float lpfFreq = 10000;
String filtroAttivo = "LPF";
color curColor = 0;
WaveAnimation anim1, anim2, anim3;
LinesAnimation linAnim;
PImage bg;
PImage logo;

void setup() {
  size(1000, 700);
  bg = loadImage("background.png");
  logo = loadImage("logo.png");
  // Initialize serial port
  String portName = Serial.list()[2]; // Change index or name as needed
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');

  // Initialize OSC to send messages to SuperCollider
  oscP5 = new OscP5(this, 12000);
  sc = new NetAddress("127.0.0.1", 57120);
  cp5 = new ControlP5(this);  
 
  initSliders();
  
  /*cp5.addDropdownList("Filtro")
     .setPosition(445, 435)
     .setSize(100, 150)
     .addItem("LPF", 0)
     .addItem("RLPF", 1)
     .addItem("HPF", 2)
     .addItem("RHPF", 3)
     .setItemHeight(35)
     .setBarHeight(35)
     .setColorBackground(color(100))
     .setColorActive(color(255, 100, 100));

  cp5.get(DropdownList.class, "Filtro")
     .getCaptionLabel().setText("Tipo di Filtro");*/
     
  anim1 = new WaveAnimation(0, color(255, 0, 0), 65, 255, 250, 60); 
  anim2 = new WaveAnimation(0, color(0, 255, 0), 370, 255, 250, 60);
  anim3 = new WaveAnimation(0, color(10, 0, 255), 685, 255, 250, 60);
  linAnim = new LinesAnimation(curColor);
}

void draw() {
  image(bg, 0, 0);
  image(logo, 940, 10);
  
  /*fill(curColor);
  stroke(255); // Optional: black border
  strokeWeight(1);
  rect(800, 490, 130, 130); // Adjust position and size as desired*/
  
  pushMatrix();
  translate(0, 0);
  anim1.waveType = int(cp5.getController("wave1").getValue());
  anim1.update();
  popMatrix();

  pushMatrix();
  translate(0, 0);
  anim2.waveType = int(cp5.getController("wave2").getValue());
  anim2.update();
  popMatrix();

  pushMatrix();
  translate(0, 0);
  anim3.waveType = int(cp5.getController("wave3").getValue());
  anim3.update();
  popMatrix();
  
  pushMatrix();
  translate(800, 490);
  linAnim.setColor(curColor);
  linAnim.update();
  linAnim.display();
  popMatrix();
  
  drawSummedWave(anim1, anim2, anim3);
  sendADSR();
}

// Serial event triggered when new line arrives from Arduino
void serialEvent(Serial p) {
  String line = p.readStringUntil('\n');
  if (line != null) {
    line = line.trim();
    println("Received line: " + line); 

    // Parse values from line, format example: "R:123 G:234 B:45 C:200 Interval:500"
    int r = parseValue(line, "R");
    int g = parseValue(line, "G");
    int b = parseValue(line, "B");
    int c = parseValue(line, "C");
    int interval = parseValue(line, "Interval"); // Use "I" if Arduino sends "I:" instead

    if (r >= 0 && g >= 0 && b >= 0 && c >= 0) {
      mapArduinoToParams(r, g, b, c, interval);
    }
  }
}

// Helper to parse integer values after key in the format "key:value"
int parseValue(String s, String key) {
  int idx = s.indexOf(key + ":");
  if (idx == -1) return -1;
  int start = idx + key.length() + 1;

  // 跳过冒号后可能的空格
  while (start < s.length() && s.charAt(start) == ' ') {
    start++;
  }

  int commaIdx = s.indexOf(',', start);
  int spaceIdx = s.indexOf(' ', start);

  int end;
  if (commaIdx == -1 && spaceIdx == -1) {
    end = s.length();
  } else if (commaIdx == -1) {
    end = spaceIdx;
  } else if (spaceIdx == -1) {
    end = commaIdx;
  } else {
    end = min(commaIdx, spaceIdx);
  }

  try {
    String valueStr = s.substring(start, end).trim();
    return Integer.parseInt(valueStr);
  } catch (Exception e) {
    return -1;
  }
}


boolean updatingFromArduino = false;
// Map Arduino RGBC and interval data to synth parameters
// Update ControlP5 sliders and invoke their callbacks to sync variables and send OSC messages
void mapArduinoToParams(int r, int g, int b, int c, int interval) {
  curColor = color(r, g, b);
  // Normalize raw 0-255 sensor values to 0.0 - 1.0 range, with clamping
  float R = constrain(r / 255.0, 0, 1);
  float G = constrain(g / 255.0, 0, 1);
  float B = constrain(b / 255.0, 0, 1);
  float C = constrain(c / 255.0, 0, 1);

  float newLpfFreq = map(C, 0, 1, 50, 20000);
  float newVol1 = map(R, 0, 1, 0.3, 1);
  float newVol2 = map(G, 0, 1, 0.3, 1);
  float newVol3 = map(B, 0, 1, 0.3, 1);
  float newEns1 = map(R, 0, 1, 0.1, 0.7);
  float newEns2 = map(G, 0, 1, 0.1, 0.7);
  float newEns3 = map(B, 0, 1, 0.1, 0.7);
  float newAtt = map(interval, 50, 2000, 0.001, 0.5);
  newAtt = constrain(newAtt, 0.001, 0.5);
  
  updatingFromArduino = true;

  cp5.getController("lpfFreq").setValue(newLpfFreq);
  cp5.getController("vol1").setValue(newVol1);
  cp5.getController("vol2").setValue(newVol2);
  cp5.getController("vol3").setValue(newVol3);
  cp5.getController("ens1").setValue(newEns1);
  cp5.getController("ens2").setValue(newEns2);
  cp5.getController("ens3").setValue(newEns3);
  cp5.getController("att").setValue(newAtt);
  
  lpfFreq(newLpfFreq);
  vol1(newVol1);
  vol2(newVol2);
  vol3(newVol3);
  ens1(newEns1);
  ens2(newEns2);
  ens3(newEns3);
  att(newAtt);

  updatingFromArduino = false;
}

void controlEvent(ControlEvent e) {
/*  if (e.isFrom("Filtro")) {
    int val = int(e.getValue());
    switch(val) {
      case 0: filtroAttivo = "LPF"; break;
      case 1: filtroAttivo = "RLPF"; break;
      case 2: filtroAttivo = "HPF"; break;
      case 3: filtroAttivo = "RHPF"; break;
    }
    return;
  }
*/
  if (updatingFromArduino) return; 
  
  if (e.isController()) {
    String name = e.getName();
    float val = e.getController().getValue();

    if (name.equals("vol1")) vol1(val);
    else if (name.equals("vol2")) vol2(val);
    else if (name.equals("vol3")) vol3(val);
    else if (name.equals("ens1")) ens1(val);
    else if (name.equals("ens2")) ens2(val);
    else if (name.equals("ens3")) ens3(val);
    else if (name.equals("att")) att(val);
    else if (name.equals("dec")) dec(val);
    else if (name.equals("sust")) sust(val);
    else if (name.equals("rel")) rel(val);
    else if (name.equals("lpfFreq")) lpfFreq(val);
    else if (name.equals("wave1")) wave1(int(val));
    else if (name.equals("wave2")) wave2(int(val));
    else if (name.equals("wave3")) wave3(int(val));
  }
}

void sendFilter() {
  OscMessage msg = new OscMessage("/filter");
  msg.add(lpfFreq);
  oscP5.send(msg, sc);
}

void sendVolumes() {
  OscMessage msg = new OscMessage("/volumes");
  msg.add(vol1);
  msg.add(vol2);
  msg.add(vol3);
  oscP5.send(msg, sc);
}

void sendEnsembleDepth() {
  OscMessage msg = new OscMessage("/ensemble");
  msg.add(ens1);
  msg.add(ens2);
  msg.add(ens3);
  oscP5.send(msg, sc);
}

void sendADSR() {
  OscMessage msg = new OscMessage("/env");
  msg.add(att);
  msg.add(dec);
  msg.add(sust);
  msg.add(rel);
  oscP5.send(msg, sc);
}

// Initialize all sliders with ControlP5 (copy your existing slider init code here)
void initSliders() {
  // Example for one slider; repeat for all sliders
  cp5.addSlider("wave1")
     .setPosition(63, 308)
     .setSize(250, 25)
     .setRange(0, 6)
     .setValue(0)
     .setNumberOfTickMarks(7)
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(180, 0, 0))
     .setColorForeground(color(255, 100, 0)) 
     .setColorValue(color(255));
  cp5.getController("wave1").getCaptionLabel()
     .setText("Sine       Saw      Square       Triangle       Pulse       Noise       Blip")
     .setColor(color(255))
     .align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE);
     
  cp5.addSlider("wave2")
     .setPosition(370, 308)
     .setSize(250, 25)
     .setRange(0, 6)
     .setValue(0)
     .setNumberOfTickMarks(7)
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(0, 180, 0))
     .setColorForeground(color(0, 255, 0)) 
     .setColorValue(255);
  cp5.getController("wave2").getCaptionLabel()
     .setText("Sine       Saw      Square       Triangle       Pulse       Noise       Blip")
     .setColor(color(255))
     .align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE);  
     
  cp5.addSlider("wave3")
     .setPosition(680, 308)
     .setSize(250, 25)
     .setRange(0, 6)
     .setValue(0)
     .setNumberOfTickMarks(7)
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(0, 0, 180))
     .setColorForeground(color(0, 0, 255)) 
     .setColorValue(255);
  cp5.getController("wave3").getCaptionLabel()
     .setText("Sine       Saw      Square       Triangle       Pulse       Noise       Blip")
     .setColor(color(255))
     .align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE);

  cp5.addSlider("att")
     .setPosition(70, 450)
     .setSize(30, 175)
     .setRange(0.001, 2.0)
     .setValue(att)
     .setSliderMode(Slider.FIX)
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(220))
     .setColorForeground(color(255)) 
     .setColorValue(color(255));
  cp5.getController("att").getCaptionLabel()
     .setText("Attack")
     .setColor(color(255))
     .align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);
  cp5.getController("att").getValueLabel().setColor(color(255));
  
  cp5.addSlider("dec")
     .setPosition(130, 450)
     .setSize(30, 175)
     .setRange(0.001, 2.0)
     .setValue(dec)
     .setSliderMode(Slider.FIX)
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(220))
     .setColorForeground(color(255)) 
     .setColorValue(color(255));
  cp5.getController("dec").getCaptionLabel()
     .setText("Decay")
     .setColor(color(255))
     .align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);
  cp5.getController("dec").getValueLabel().setColor(color(255));
  
  cp5.addSlider("sust")
     .setPosition(190, 450)
     .setSize(30, 175)
     .setRange(0.0, 1.0)
     .setValue(sust)
     .setSliderMode(Slider.FIX)
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(220))
     .setColorForeground(color(255)) 
     .setColorValue(color(255));
  cp5.getController("sust").getCaptionLabel()
     .setText("Sustain")
     .setColor(color(255))
     .align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);
  cp5.getController("sust").getValueLabel().setColor(color(255));
  
  cp5.addSlider("rel")
     .setPosition(250, 450)
     .setSize(30, 175)
     .setRange(0.001, 3.0)
     .setValue(rel)
     .setSliderMode(Slider.FIX)
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(220))
     .setColorForeground(color(255)) 
     .setColorValue(color(255));
  cp5.getController("rel").getCaptionLabel()
     .setText("Release")
     .setColor(color(255))
     .align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);
  cp5.getController("rel").getValueLabel().setColor(color(255));
  
  cp5.addSlider("lpfFreq")
     .setPosition(435, 435)
     .setSize(500, 30)
     .setRange(50, 20000)
     .setValue(lpfFreq)
     .setNumberOfTickMarks(0)
     .setDecimalPrecision(0)
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(220))
     .setColorForeground(color(255)) 
     .setColorValue(color(255));
  cp5.getController("lpfFreq").getCaptionLabel()
     .setText("Filtro LPF (Hz)")
     .setColor(color(255))
     .align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);
  cp5.getController("lpfFreq").getValueLabel().setColor(color(255, 255, 255));

  cp5.addSlider("vol1")
     .setPosition(63, 350)
     .setSize(200, 20)
     .setRange(0, 1)
     .setValue(vol1)
     .setDecimalPrecision(2)
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(100, 0, 0))
     .setColorForeground(color(180, 0, 0)) 
     .setColorValue(color(255));
  cp5.getController("vol1").getCaptionLabel()
     .setText("Volume Osc 1")
     .setColor(color(255));
     
  cp5.addSlider("vol2")
     .setPosition(370, 350)
     .setSize(200, 20)
     .setRange(0, 1)
     .setValue(vol2)
     .setDecimalPrecision(2)
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(0, 100, 0))
     .setColorForeground(color(0, 180, 0)) 
     .setColorValue(color(255));
  cp5.getController("vol2").getCaptionLabel()
     .setText("Volume Osc 2")
     .setColor(color(255));
     
  cp5.addSlider("vol3")
     .setPosition(680, 350)
     .setSize(200, 20)
     .setRange(0, 1)
     .setValue(vol3)
     .setDecimalPrecision(2)
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(0, 0, 100))
     .setColorForeground(color(0, 0, 180)) 
     .setColorValue(color(255));
  cp5.getController("vol3").getCaptionLabel()
     .setText("Volume Osc 3")
     .setColor(color(255));
   
  cp5.addSlider("ens1")
     .setPosition(63, 375)
     .setSize(150, 20)
     .setRange(0.0, 1.0)
     .setValue(ens1)
     .setLabel("Ensemble Depth Osc1")
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(150, 50, 50))
     .setColorForeground(color(180, 100, 100)) 
     .setColorValue(color(255));
  cp5.getController("ens1").getCaptionLabel()
     .setText("Esemble depth OSC 1")
     .setColor(color(255));
     
  cp5.addSlider("ens2")
     .setPosition(370, 375)
     .setSize(150, 20)
     .setRange(0.0, 1.0)
     .setValue(ens2)
     .setLabel("Ensemble Depth Osc2")
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(50, 150, 50))
     .setColorForeground(color(100, 180, 100)) 
     .setColorValue(color(255));
  cp5.getController("ens2").getCaptionLabel()
     .setText("Esemble depth OSC 2")
     .setColor(color(255));
     
  cp5.addSlider("ens3")
     .setPosition(680, 375)
     .setSize(150, 20)
     .setRange(0.0, 1.0)
     .setValue(ens3)
     .setLabel("Ensemble Depth Osc3")
     .setColorBackground(color(100, 100, 100))
     .setColorActive(color(50, 50, 150))
     .setColorForeground(color(100, 100, 180)) 
     .setColorValue(color(255));
  cp5.getController("ens3").getCaptionLabel()
     .setText("Esemble depth OSC 3")
     .setColor(color(255));
}

void drawSummedWave(WaveAnimation w1, WaveAnimation w2, WaveAnimation w3) {
  stroke(curColor);
  //stroke(color(255, 255, 255));
  float sumStroke = (w1.getStroke() + w1.getStroke() + w1.getStroke())/3;
  strokeWeight(sumStroke);
  noFill();

  pushMatrix();
  translate(500, 550); 

  beginShape();
  for (int x = 0; x < w1.rectWidth; x++) {
    float y1 = w1.getY(x);
    float y2 = w2.getY(x);
    float y3 = w3.getY(x);
    float ySum = (y1 + y2 + y3) / 3; // average to keep within visual range
    vertex(x, ySum);
  }
  endShape();

  popMatrix();
}

// Slider event handlers
void att(float val) { att = val; sendADSR(); }
void dec(float val) { dec = val; sendADSR(); }
void sust(float val) { sust = val; sendADSR(); }
void rel(float val) { rel = val; sendADSR(); }

void wave1(int val) { wave1 = val; sendWaves(); }
void wave2(int val) { wave2 = val; sendWaves(); }
void wave3(int val) { wave3 = val; sendWaves(); }

void sendWaves() {
  OscMessage msg = new OscMessage("/wave");
  msg.add((int)wave1);
  msg.add((int)wave2);
  msg.add((int)wave3);
  oscP5.send(msg, sc);
}

void lpfFreq(float val) { lpfFreq = val; sendFilter(); }

void vol1(float val) { vol1 = val; sendVolumes(); anim1.setAmplitude(val);}
void vol2(float val) { vol2 = val; sendVolumes(); anim2.setAmplitude(val);}
void vol3(float val) { vol3 = val; sendVolumes(); anim3.setAmplitude(val);}

void ens1(float val) { ens1 = val; sendEnsembleDepth(); }
void ens2(float val) { ens2 = val; sendEnsembleDepth(); }
void ens3(float val) { ens3 = val; sendEnsembleDepth(); }
