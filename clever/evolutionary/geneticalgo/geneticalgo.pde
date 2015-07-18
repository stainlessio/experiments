import java.util.*;

final float p_crossover = 0.98;
final int step_x = 5;
final int step_y = 5;
final int gene_size = 100;

Gene randomGene() {
	Gene retval = new Gene(this);
	for(int i=0; i<retval.gene.length; i++) {
		retval.gene[i] = (byte)(random(0, 255));
	}

	return retval;
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

	void calculateFitness(int w, int h, int target) {
		int x=0, y=0;
		int pixelCount = 0;

		for(int i=0; i<gene.length; i++) {
			for(int c=0; c<8; c+=3) {
				byte bit = (byte)((gene[i]>>c)&7);
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
						break;				}
				if (x < -w || x > w || y < -h || y > h) {
					fitness = (float)pixelCount / (float)target;
					return;
				}
				++pixelCount;
			}
		}
		fitness = (float)pixelCount / (float)target;
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
		int x=0, y=0;

		g.beginDraw();
		g.translate(patch.width/2, patch.height/2);
		g.background(#efefef);
		// g.stroke(#333333);
		g.noStroke();
		g.fill(#ffcccc);
		g.beginShape();
		for(int i=0; i<gene.length; i++) {
			for(int c=0; c<8; c+=3) {
				byte bit = (byte)((gene[i]>>c)&7);
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
					g.endShape(CLOSE);
					g.endDraw();
					return;
				}
				g.vertex(x, y);
			}
		}
		g.endShape(CLOSE);
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
		children[i].pointMutation();
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
	size(500, 400);
	smooth();
	noStroke();
	// frameRate(1);
	population = new Gene[100];
	for(int i=0; i<population.length; i++) {
		population[i] = randomGene();
	}

	patch = createGraphics(50, 40);
	patch.stroke(#333333);

	targetPixels = patch.width * patch.height;
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
		population[i].draw(patch);
		image(patch, x, y);

		// fill(#efefef, 200);
		// rect(x, y, patch.width, patch.height);
		fill(#333333);

		text(str(population[i].fitness), x+5, y+patch.height/2-12, patch.width-5, patch.height/2+12);
		x += patch.width;
		if (x > (width - patch.width)) {
			x = 0;
			y += patch.height;
		}

		selection[i] = binaryTournament(population);
	}

	reproduce(selection, children);

	for(int i=0; i<population.length; i++) {
		population[i] = children[i];
	}

	if (random(1.0) >= p_crossover) {
		// Very occasionally a new gene enters the pool
		population[population.length-1] = randomGene();
	}
	saveFrame("#####.png");
}