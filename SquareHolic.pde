import controlP5.*;
ControlP5 cp5;

boolean redraw = true;

PImage base; // source image(base)
PImage tuned; // tuned image

float gamma_s = 1.0; // gamma value for source image
float gain_s = 1;  // gain for source image

int back_r = 255;
int back_g = 255;
int back_b = 255;

int size_x = 640;
int size_y = 640;

int thumb_w = 160;
int thumb_h = 120;
int cont_w = 300;

PImage TuneImage(PImage src) {
  float[] lut_s = new float[256];
  for (int i = 0; i < 256; i++) {
    lut_s[i] = 255*pow(((float)i/255), (1/gamma_s));
  }  
  
  int size = max(src.width, src.height);
  PImage res = createImage(size, size, RGB);

  src.loadPixels(); //<>//

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      int tmp_x = x - (size - src.width) / 2;
      int tmp_y = y - (size - src.height) / 2;
      if (tmp_x < 0 || tmp_x >= src.width || tmp_y < 0 || tmp_y >= src.height) {
        res.pixels[x + y * size] = color(back_r,back_g,back_b);
      }
      else {
        color tmp_color = src.pixels[tmp_x + tmp_y * src.width];
  
        res.pixels[x + y * size] = color(
            (int)(lut_s[(int)red(tmp_color)]*gain_s), 
            (int)(lut_s[(int)green(tmp_color)]*gain_s), 
            (int)(lut_s[(int)blue(tmp_color)]*gain_s)
            );
      }
    }
  }
  return res;
}

void setup() {
  size(940, 640);

  cp5 = new ControlP5(this);

  cp5.addButton("Load Source Image")
    .setPosition(40, 40)
    .setSize(130, 39)
    ;

  cp5.addSlider("gamma_s")
    .setRange(0, 2)
    .setPosition(40, 100)
    .setSize(100, 25)
    ;

  cp5.addSlider("gain_s")
    .setRange(0, 4)
    .setPosition(40, 140)
    .setSize(100, 25)
    ;

  cp5.addSlider("back_r")
    .setRange(0, 255)
    .setPosition(40, 200)
    .setSize(100, 25)
    ;

  cp5.addSlider("back_g")
    .setRange(0, 255)
    .setPosition(40, 240)
    .setSize(100, 25)
    ;

  cp5.addSlider("back_b")
    .setRange(0, 255)
    .setPosition(40, 280)
    .setSize(100, 25)
    ;

  cp5.addButton("Save Image")
    .setPosition(40, 540)
    .setSize(100, 39)
    ;

  cp5.addButton("Exit")
    .setPosition(160, 540)
    .setSize(100, 39)
    ;

  base = createImage(size_x, size_y, RGB);
  tuned = createImage(size_x, size_y, RGB);
}



void fileSelected_load(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    base = loadImage(selection.getAbsolutePath());
  }
  redraw = true;
}

void fileSelected_save(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    tuned.save(selection.getAbsolutePath());
  }
}

public void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom("Load Source Image")) {
    selectInput("Select a file to process:", "fileSelected_load");
  }

  if (theEvent.isFrom("Save Image")) {
    selectOutput("Select a file to write to:", "fileSelected_save");
  }

 if (theEvent.isFrom("Exit")) {
    exit();
  }
  redraw = true;
}

void draw() {
  background(0);
  if (redraw) {
    redraw = false;
    tuned = TuneImage(base);
  }
  draw_image(tuned, cont_w, 0, size_x, size_y);
}

void draw_image(PImage img, int x, int y, int lim_w, int lim_h) {
  int vw = img.width; //vw: view width
  int vh = img.height; //vh: view height
  if (vw > lim_w || vh > lim_h) {
    //rr: reduce rate
    float rr = min((float)lim_w / (float)vw, (float)lim_h / (float)vh);
    vw = (int)(vw * rr);
    vh = (int)(vh * rr);
  }
  image(img, x, y, vw, vh);
}
