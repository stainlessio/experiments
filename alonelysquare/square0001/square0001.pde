import gifAnimation.*;

GifMaker gif;

float i=0, scaleValue;
int state=0;
float lastI;
boolean rising = true;
final int maxStates = 2;
final int stateDuration = 350;

void setup() {
  size(600, 600);

  gif = new GifMaker(this, "export.gif");
  gif.setRepeat(0);

  scaleValue = width/3;
  noStroke();
  smooth();
  rectMode(CENTER);
}

float easeValue(float t, float b, float c, float d) {
	if ((t /= d/2) < 1) {
		return c/2*t*t*t + b;
	}

	return c/2*((t-=2)*t*t +2) + b;
}

void tent(float factor) {
  pushMatrix();
  for(int n=0;n<i*25;n++) {
  	translate(lerp(0, 50, factor), lerp(0, 50, factor));
  	rotate(lerp(0, radians(180/25*n), factor));
  	rect(0,0, 50, 50);
  }
  popMatrix();

}

void doState() {
	float factor = (1.0 - i);
	float tmp;
	switch(state) {
		case 0:
		  fill(lerpColor(#000000, #333333, i));
		  tmp = lerp(scaleValue, 50, i);
		  rect(0,0, tmp, tmp);
		  break;
		case 1:
		  fill(#333333);
		  rect(0,0, 50, 50);
		  fill(#333333, 128);
		  for(int n=0; n <25; n++) {
		  	rotate(lerp(0, radians(360/25*n), factor));
		  	tent(factor);
		  }
		  break;
	}
}

void draw() {
		translate(width/2, height/2);
	i = easeValue(sin(2*PI*frameCount/stateDuration)+1.0, 0, 1, 2);

	background(#ffffff);
	// fill(#ffffff, 20);
	// rect(0,0,width, height);
	doState();

	if (rising) {
		if (i < lastI) {
			state = (state + 1) % maxStates;
			rising = false; // now falling
		}
	} else { // falling
		if (i > lastI) {
			rising = true;

		    if (frameCount > stateDuration && state == 0) {
		       gif.finish();
		       exit();
	        }
		}
	}

	lastI = i;

    gif.setDelay(20);
    gif.addFrame();
}