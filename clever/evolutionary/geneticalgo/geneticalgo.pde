import java.util.*;

final float p_crossover = 0.98;
final float p_newGeneRate = 0.10;
final float s = 1.5;
final int mode = 10;
final int step_x = (int)max(s*5, (s*15/mode));
final int step_y = (int)max(s*5, (s*15/mode));
final int gene_size = 100;


Gene randomGene() {
	Gene retval = new Gene(this);
	for(int i=0; i<retval.gene.length; i++) {
		retval.gene[i] = (byte)(random(0, 255));
	}

	return retval;
}

float calculateArea(int x[], int y[]) {
	x[1] -= x[2];
	y[1] -= y[2];
	x[0] -= x[2];
	y[0] -= y[2];

	return 0.5 * (
		x[0]*y[1] - x[1]*y[0]
	);
}

class Gene implements Comparable {
	byte[] gene;
	float fitness;
	PApplet parent;

	Gene(PApplet parent) {
		this.parent = parent;
		fitness = 0.0;
		gene = new byte[gene_size];
	}

	Gene(PApplet parent, Gene other) {
		for(int i=0; i<gene.length; i++) {
			gene[i] = other.gene[i];
		}
	}

	void doFitness(float pixelCount, float targetCount) {
		fitness = pixelCount / targetCount;
	}

	void calculateFitness(int w, int h, int target) {
		// int x=-w, y=-h;
		int x=0, y=0;
		int pixelCount = 0;
		fitness = 0.0;
		int min_x = w, max_x = -w;
		int min_y = h, max_y = -h;
		float area = 0.0, totalArea = 0.0;
		int[] tri_x, tri_y;
		int targetArea = w*h;

		tri_x = new int[3];
		tri_y = new int[3];

		for(int i=1; i<gene.length; i++) {
			tri_x[2] = min_x;
			tri_y[2] = min_y;
			tri_x[1] = max_x;
			tri_x[1] = max_y;
			for(int c=0; c<8; c+=2) {
				byte bit = (byte)((gene[i]>>c)&3);
				switch(bit) {
					case 0:
						y += step_y;
						break;
					case 1:
						y -= step_y;
						break;
					case 2:
						x += step_x;
						break;
					case 3:
						x -= step_x;
						break;
					case 4:
						x += step_x;
						y += step_y;
						break;
					case 5:
						x -= step_x;
						y += step_y;
						break;
					case 6:
						x += step_x;
						y -= step_y;
						break;
					case 7:
						x -= step_x;
						y -= step_y;
						break;
				}
				tri_x[0] = x;
				tri_y[0] = y;

				area = calculateArea(tri_x, tri_y);
				totalArea += area;
				if (x < -w || x > w || y < -h || y > h) {
					doFitness(area, -targetArea);
					return;
				}
				min_x = min(min_x, x);
				min_y = min(min_y, y);
				max_x = max(max_x, x);
				max_y = max(max_y, y);

				++pixelCount;
			}
		}

		doFitness(totalArea, targetArea);
	}

	void pointMutation(float rate) {
		for(int i=0; i<gene.length; i++) {
			byte newValue = 0;
			for(int c=0; c<8; c++) {
				boolean bit = (gene[i]>>c&1) == 1;
				if (parent.random(1.0) < rate) {
					bit = !bit;
				}
				if (bit) {
					newValue |= 1<<c;
				}
			}
		}
	}

	int compareTo(Object o) {
		Gene other = (Gene)o;
		return fitness < other.fitness ?
		    1 : fitness > other.fitness ?
		   -1 : 0;
	}

	void pointMutation() {
		pointMutation(1.0/(float)gene.length*8);
	}

	void draw(PGraphics g) {
		// int x=-g.width/2, y=-g.height/2;
		int x=0, y=0;

		g.beginDraw();
		g.translate(g.width/2, g.height/2);
		g.background(#efefef);
		// g.stroke(#333333, 128);
		// g.strokeWeight(5);
		g.noStroke();
		g.fill(#ff0000, 64);
		g.beginShape(TRIANGLE_STRIP);
		for(int i=0; i<gene.length; i++) {
			for(int c=0; c<8; c+=2) {
				byte bit = (byte)((gene[i]>>c)&3);
				switch(bit) {
					case 0:
						y += step_y;
						break;
					case 1:
						y -= step_y;
						break;
					case 2:
						x += step_x;
						break;
					case 3:
						x -= step_x;
						break;
					case 4:
						x += step_x;
						y += step_y;
						break;
					case 5:
						x -= step_x;
						y += step_y;
						break;
					case 6:
						x += step_x;
						y -= step_y;
						break;
					case 7:
						x -= step_x;
						y -= step_y;
						break;
				}
				if (x < -g.width/2 || x > g.width/2 || y < -g.height/2 || y > g.height/2) {
					g.endShape();
					g.endDraw();
					return;
				}
				g.vertex(x, y);
			}
		}
		g.endShape();
		g.endDraw();
	}
};

Gene crossover(Gene p1, Gene p2) {
	Gene retval = new Gene(this);

	if (random(1.0) >= p_crossover) {
		return p1;
	}

	int xpt = (int)(1 + random(p1.gene.length - 2));
	for(int i=0; i<p1.gene.length; i++) {
		retval.gene[i] = xpt < i ? p1.gene[i] : p2.gene[i];
	}

	return retval;
}

void reproduce(Gene[] selection, Gene[] children) {
	for(int i=0; i<selection.length; i++) {
		int p2 = (i%2 == 0) ? i+1 : i-1;
		if (i == selection.length -1) {
			p2 = 0;
		}

		children[i] = crossover(selection[i], selection[p2]);
		children[i].pointMutation(0.5);
	}
}

Gene[] population;
PGraphics patch;
int targetPixels;

Gene binaryTournament(Gene[] pop) {
	int i = (int)random(pop.length);
	int j = (int)random(pop.length);

	while(i==j) {
		j = (int)random(pop.length);
	}

	return (pop[i].fitness > pop[j].fitness) ? pop[i] : pop[j];
}

void setup() {
	size((int)(500*s), (int)(400*s));
	smooth();
	noStroke();
	// frameRate(1);
	population = new Gene[100];
	for(int i=0; i<population.length; i++) {
		population[i] = randomGene();
	}

	patch = createGraphics(width/mode, height/mode);
	patch.stroke(#333333);

	targetPixels = gene_size*4;
}

void draw() {
	int x=0, y=0;
	background(#efefef);

	for(int i=0; i<population.length; i++) {
		population[i].calculateFitness(patch.width/2, patch.height/2, targetPixels);
	}

	Arrays.sort(population);

	Gene selection[] = new Gene[population.length];
	Gene children[] = new Gene[population.length];

	for(int i=0; i<population.length; i++) {
		if (mode == 10) {
			population[i].draw(patch);
			image(patch, x, y);

			// fill(#efefef, 200);
			// rect(x, y, patch.width, patch.height);
			if (i == 1) {
				fill(#333333);
				textSize(8);
				text(str(population[i].fitness), x+5, y+patch.height/2-12);
			}
			x += patch.width;
			if (x > (width - patch.width)) {
				x = 0;
				y += patch.height;
			}
		}
		selection[i] = binaryTournament(population);
	}

	if (mode == 1) {
		population[0].draw(patch);
		image(patch, 0, 0);
		fill(#333333);
		text(str(population[0].fitness), 5, height/2);
	}

	reproduce(selection, children);

	for(int i=0; i<population.length; i++) {
		population[i] = children[i];
		if (random(1.0) < p_newGeneRate) {
			population[i] = randomGene();
		}
	}

	// saveFrame("#####.png");
}