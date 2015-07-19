

var p_crossover = 0.98;
var p_newGeneRate = 0.10;
var s = 1.5;
var step_x = Math.max(s*5, (s*15));
var step_y = Math.max(s*5, (s*15));
var gene_size = 100;
var population = new Array(100);
var targetPixels, patch;
var pink, fadedPink;
var printed = false;

function calculateArea(x, y) {
	if (!printed) {
		console.log(x, y);
		printed = true;
	}
	x[1] -= x[2];
	y[1] -= y[2];
	x[0] -= x[2];
	y[0] -= y[2];

	return 0.5 * (
		x[0]*y[1] - x[1]*y[0]
	);
}

function Gene(other) {
	if (!(this instanceof Gene)) {
		return new Gene(other);
	}

	this.gene = new Array(gene_size);
	this.fitness = 0.0;

	if (other && other.gene) {
		// Copy
		for(var i=0; i<this.gene.length; i++) {
			this.gene[i] = other.gene[i];
		}
	}
}

Gene.random = function() {
	var retval = new Gene();
	for(var i=0; i<retval.gene.length; i++) {
		retval.gene[i] = random(0, 255);
	}

	return retval;
}

Gene.compare = function (a, b) {
	return a.fitness < b.fitness ?
	    1 : a.fitness > b.fitness ?
	   -1 : 0;
}

Gene.prototype.doFitness = function (value, target) {
	this.fitness = value / target;
}

Gene.prototype.pointMutation = function (rate) {
	rate = rate || (1.0/this.gene.length*8)
	for(var i=0; i<this.gene.length; i++) {
		var newValue = 0;
		for(var c=0; c<8; c++) {
			var bit = (this.gene[i]>>c&1) == 1;
			if (random(1.0) < rate) {
				bit = !bit;
			}
			if (bit) {
				newValue |= 1<<c;
			}
		}
	}
}

Gene.prototype.stepX = function (bit) {
	switch(bit) {
		case 0:
			return step_x;
		case 1:
			return -step_x;
		case 2:
			return step_x;
		default:
			return -step_x;
	}

}

Gene.prototype.stepY = function (bit) {
	switch(bit) {
		case 0:
			return -step_y;
		case 1:
			return -step_y;
		case 2:
			return step_y;
		default:
			return step_y;
	}
}

Gene.crossover = function (p1, p2) {
	var retval = new Gene();

	if (random(1.0) >= p_crossover) {
		return p1;
	}

	var xpt = Math.floor(1 + random(p1.gene.length - 2));
	for(var i=0; i<p1.gene.length; i++) {
		retval.gene[i] = xpt < i ? p1.gene[i] : p2.gene[i];
	}

	return retval;
}

Gene.reproduce = function (selection, children) {
	for(var i=0; i<selection.length; i++) {
		var p2 = (i%2 == 0) ? i+1 : i-1;
		if (i == selection.length -1) {
			p2 = 0;
		}

		children[i] = Gene.crossover(selection[i], selection[p2]);
		children[i].pointMutation(0.5);
	}
}

Gene.prototype.calculateFitness = function (w, h, target) {
	// int x=-w, y=-h;
	var x=0, y=0;
	var pixelCount = 0;
	this.fitness = 0.0;
	var area = 0.0, totalArea = 0.0;
	var targetArea = w*h;
	var min_x = w, max_x = -w;
	var min_y = h, max_y = -h;

	var tri_x = new Array(3);
	var tri_y = new Array(3);

	for(var i=1; i<this.gene.length; i++) {
		tri_x[2] = min_x;
		tri_y[2] = min_y;
		tri_x[1] = max_x;
		tri_y[1] = max_y;
		for(var c=0; c<8; c+=1) {
			var bit = ((this.gene[i]>>c)&3);
			x += this.stepX(bit);
			y += this.stepY(bit);
			tri_x[0] = x;
			tri_y[0] = y;

			area = calculateArea(tri_x, tri_y);
			totalArea += area;
			if (x < -w || x > w || y < -h || y > h) {
				this.doFitness(totalArea, -targetArea);
				return;
			}
			min_x = Math.min(min_x, x);
			min_y = Math.min(min_y, y);
			max_x = Math.max(max_x, x);
			max_y = Math.max(max_y, y);

			++pixelCount;
		}
	}

	doFitness(totalArea, targetArea);
}



Gene.prototype.draw = function(g) {
	// var x=-g.width/2, y=-g.height/2;
	var x=0, y=0;


	g.background('#efefef');
	// g.stroke(#333333, 128);
	// g.strokeWeight(5);
	g.noStroke();
	g.fill(fadedPink);
	g.beginShape(TRIANGLE_STRIP);
	for(var i=0; i<this.gene.length; i++) {
		for(var c=0; c<8; c+=2) {
			var bit = ((this.gene[i]>>c)&3);
			x += this.stepX(bit);
			y += this.stepY(bit);

			if (x < -g.width/2 || x > g.width/2 || y < -g.height/2 || y > g.height/2) {
				g.endShape();
				return;
			}
			g.vertex(x, y);
		}
	}
	g.endShape();
}

function binaryTournament() {
	var i = Math.floor(random(population.length));
	var j = Math.floor(random(population.length));

	while(i===j) {
		j = Math.floor(random(population.length));
	}

	return (population[i].fitness > population[j].fitness) ? population[i] : population[j];
}

function setup() {
	createCanvas((500*s), (400*s));
	smooth();
	noStroke();

	for(var i=0; i<population.length; i++) {
		population[i] = Gene.random();
	}

	patch = createGraphics(width, height);
	patch.translate(patch.width/2, patch.height/2);
	patch.stroke('#333333');

	targetPixels = gene_size*8;
	pink = color('rgba(255, 15, 144, .5)');
	fadedPink = color('rgba(255, 15, 144, .1)');
}

function drawLabel(fitness) {
	beginShape(QUADS);
	fill(pink);
	vertex(0, height/2 - 6);
	vertex(90, height/2 - 6);
	vertex(100, height/2 + 6);
	vertex(0, height/2 + 6);
	endShape();
	fill('#333333');
	textSize(10);
	text(str(fitness), 16, height/2+4);
}

function draw() {
	var x=0, y=0;
	if (keyIsPressed === true) {
		if (key == ' ') {
			for(var i=0; i<population.length; i++) {
				population[i] = Gene.random();
			}
		} if (key == ENTER) {
			saveCanvas();
		}
	}
	background('#efefef');

	for(var i=0; i<population.length; i++) {
		population[i].calculateFitness(patch.width/2, patch.height/2, targetPixels);
	}

	population.sort(Gene.compare);

	var selection = new Array(population.length);
	var children = new Array(population.length);

	for(var i=0; i<population.length; i++) {
		selection[i] = binaryTournament(population);
	}

	population[0].draw(patch);
	image(patch, 0, 0);
	drawLabel(population[0].fitness);

	Gene.reproduce(selection, children);

	for(var i=0; i<population.length; i++) {
		population[i] = children[i];
		if (random(1.0) < p_newGeneRate) {
			population[i] = Gene.random();
		}
	}
}