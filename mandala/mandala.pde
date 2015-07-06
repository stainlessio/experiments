import gifAnimation.*;

GifMaker gif;

final float rotateStep = radians(10);
final int rotateCount = 36;  // rotateStep * rotateCount = 360
final int numberPoints = 15;
final int startFrame = 150;
final int totalFrames = 150;
float x, y, noiseValue, tmp;
int frames = 0;

color[] palette = {
	#000000,
	#342717,
	#406185,
	#4B6F91,

};

int colorStart = 0;
int morphCount = 0;

PVector[] points = new PVector[numberPoints];
PVector[] origPoints = new PVector[numberPoints];

void setup() {
	size(400, 400);

	gif = new GifMaker(this, "export.gif", 100);
	gif.setRepeat(0);
	frameRate(24);
	smooth();
	noStroke();
	x = y = 0;

	for(int i=0;i<numberPoints;i++) {
		points[i] = PVector.random2D();
		points[i].mult(random(width/8));
		origPoints[i] = points[i];
	}
}

void createPiece(int sign) {
	float frameAdjust = sin(2*PI*(frameCount%50)/50.0);
	for(int i=0; i<numberPoints;i++) {
		points[i].set(
			origPoints[i].x + frameAdjust*(20*noise(sin(2*PI*(points[i].x/width%50) / 50))-10),
			origPoints[i].y + frameAdjust*(20*noise(cos(2*PI*(points[i].y/height%50) / 50))-10)
		);
	}
}

void morphPiece() {
	++morphCount;
	for(int i=0;i<numberPoints;i++) {
		origPoints[i].set(
			origPoints[i].x + noise(cos(2*PI*morphCount/50.0)),
			origPoints[i].y + noise(sin(2*PI*morphCount/50.0))
		);
	}
}

void drawPiece() {

	beginShape();
	  for(int i=0;i<numberPoints; i++) {
	  	vertex(points[i].x, points[i].y);
	  }

	endShape(CLOSE);
}

void keyPressed() {
  if (key == ' ') {
    saveFrame("capture-####.png");
  }
}

void draw() {
	fill(#fefefe, 1);
	rect(0,0,width, height);

	pushMatrix();
	translate(width/2, height/2);
	rotate(-rotateStep*noise(frameCount/totalFrames));
	noiseValue = random(10);
		createPiece(0);
	// int i =0;
	colorStart += (int)(noise(noiseValue) * (frameCount%150)/150);
	colorStart %= palette.length;
	for(int i=0; i<rotateCount; i++) {
		fill(palette[(colorStart + i)%palette.length],50);
		rotate(rotateStep);
		drawPiece();
	}
	popMatrix();

	if (frameCount%50 == 0) {
		morphPiece();
	}

	// if (frameCount >= startFrame && frameCount < startFrame + totalFrames) {
	// 	gif.setDelay(20);
	// 	gif.addFrame();
	// 	++frames;
	// 	// saveFrame("capture-####.png");
	// } else if (frames >= totalFrames) {
	// 	gif.finish();
	// 	exit();
	// }
}