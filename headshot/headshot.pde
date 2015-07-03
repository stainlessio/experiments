HDrawablePool pool;
PImage headshot;
HPixelColorist colors;
HCanvas canvas;

void setup() {
	println(dataPath(""));
	println(sketchPath(""));
	size(500, 500);
	H.init(this).background(#fefefe);
	smooth();
	headshot = loadImage("russell.jpg");
	colors = new HPixelColorist(headshot)
                 .fillOnly();
    canvas = new HCanvas().autoClear(false).fade(2);
    H.add(canvas);
	pool = new HDrawablePool(600);
	pool.autoParent(canvas)
	  .add(new HPath().star( 6, .21 ))
	  .layout(
	  	new HPolarLayout(0.4, 0.5)
	  	  .offsetX(width/2.0)
	  	  .offsetY(height/2.0)
	  )
	  .onCreate(
	  	new HCallback() {
	  		public void run(Object obj) {
	  			int i = pool.currentIndex();

	  			HDrawable d = (HDrawable)obj;
	  			d.anchorAt(H.CENTER)
	  			 .noStroke()
	  			 .size((int)random(40))
	  		    ;

	  		    int clr = colors.getColor(d.x(), d.y());
	  		    d.fill(clr, 25);

	  		    new HOscillator()
	  		      .target(d)
	  		      .property(H.SCALE)
	  		      .range(0.5, 1.5)
	  		      .speed(5)
	  		      .freq(0.75)
	  		      .currentStep(i)
	  		    ;

	  		    new HOscillator()
	  		      .target(d)
	  		      .property(H.ROTATION)
	  		      .range(0, 180)
	  		      .speed(3)
	  		      .freq(0.1)
	  		      .currentStep(i)
	  		    ;

	  		}
	  	}
	  ).requestAll();
}

void keyPressed() {
	if (key == ' ') {
		saveFrame("frame-#####.png");
	}
}

void draw() {
	  H.drawStage();	
}