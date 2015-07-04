import processing.pdf.*;

HDrawablePool barPool;
HDrawablePool hexPool;
HColorPool colorist;
HColorTransform darken;
int barAnchor;
int x, y;

void setup() {
  size(400, 500);
  frameRate(5);
  barAnchor = (int)random(height/2) + height/4;
  x = (int)random(width/4);
  y = barAnchor + (int)random(height/4);
  H.init(this).background(#fefefe).autoClear(true);
  colorist = new HColorPool(#fe5f55, #D64768, #5F5592, #836A7F, #BB9069, #FF9D4C, #F2B637, #5B5F97, #FFC145, #DE639A);
  H.stage().autoClears(true);
  smooth();

  darken = new HColorTransform().fillOnly()
    .percR(0.65)
    .percG(0.65)
    .percB(0.65);

  barPool = new HDrawablePool(5);
  hexPool = new HDrawablePool(25);

  generateBars();
  generateHexes();
  H.drawStage();
  noLoop();
}

void generateHexes() {
  hexPool.autoAddToStage()
    .add(new HPath().star(6, 0.125).noFill())
    .onRequest(new HCallback() {
      public void run(Object obj) {
        int hexSize = (int)random(64) + 10;
        HDrawable d = (HDrawable)obj;
        d.size(hexSize)
         .loc(x, y)
         .strokeWeight((int)random(4) + 2)
         .anchorAt(H.LEFT | H.CENTER_Y)
        ;

        colorist.strokeOnly().applyColor(d);

        if (random(1) < 0.33) {
          x += hexSize;
        }
        if (random(1) < 0.5) {
          y += hexSize/2;

        } else {
          y -= hexSize/2;
        }
      }
    }).requestAll();
}

void generateBars() {
  barPool.autoAddToStage()
    .add(new HRect().width(width).x(0))
    .onRequest(new HCallback() {
      public void run(Object obj) {
        HDrawable d = (HDrawable)obj;

        d.height((int)random(50))
         .y((int)random(75) - 25 + barAnchor)
         .noStroke()
         .anchorAt(H.LEFT)
        ;
        colorist.fillOnly().applyColor(d);
        darken.applyColor(d);
      }
    }
  ).requestAll();
}

void keyPressed() {
  if (key == ' ') {
    saveFrame("capture.png");
    PGraphicsPDF pdf = (PGraphicsPDF) createGraphics(width, height, PDF, "capture.pdf");
    pdf.beginDraw();
    H.stage().paintAll(pdf, false, 1f);
    pdf.dispose();
    pdf.endDraw();
  }
}
