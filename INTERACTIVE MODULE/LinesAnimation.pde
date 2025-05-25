class LinesAnimation {
  float t = 0;
  color colour;

  LinesAnimation(color col) {
    this.colour = col;
  }

  void setColor(color col) {
    this.colour = col;
  }

  void update() {
    t += 0.5;
  }

  float x1(float tt) {
    return sin(tt / 10.0) * 40 + sin(tt / 5.0) * 10 + 65;
  }

  float y1(float tt) {
    return cos(tt / 10.0) * 40 + 65;
  }

  float x2(float tt) {
    return sin(tt / 10.0) * 60 + sin(tt / 5.0) * 10 + 65;
  }

  float y2(float tt) {
    return cos(tt / 20.0) * 50 + cos(tt / 12.0) * 10 + 65;
  }

  void display() {
    stroke(this.colour);
    strokeWeight(2);
    for (int i = 0; i < NUM_LINES; i++) {
      line(x1(t + i), y1(t + i), x2(t + i), y2(t + i));
    }
    update();
  }
}
