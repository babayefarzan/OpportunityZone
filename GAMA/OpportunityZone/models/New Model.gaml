/***
* Name: NewModel
* Author: Arno
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model NewModel

/* Insert your model definition here */

global {
	file shape_file_buildings <- file("../includes/Opportunity Zones/opportunity zones.shp");
	//definition of the geometry of the world agent (environment) as the envelope of the shapefile
	geometry shape <- envelope(shape_file_buildings);
	list<list<float>> heat_map <- [[30,146,254],[86,149,242],[144,201,254],[180,231,252],[223,255,216],[254,255,113],[248,209,69],[243,129,40],[235,46,26],[109,23,8]]; 
	int max_pop_value;
	int min_pop_value;
		
	float max_income_value;
    float min_income_value;
		
	float max_poverty_value;
	float min_poverty_value;
		
	float max_unemployment_value;
    float min_unemployment_value;
	
	graph<geometry,geometry> my_graph;
	int degreeMax <- 1;
	
	int distance parameter: 'distance ' min: 1 max:10000000<- 1000;
	float _speed parameter: 'speed ' min: 1.0 max:10000.0<- 1000.0;
	
	init {
		//creation of the building agents from the shapefile: the height and type attributes of the building agents are initialized according to the HEIGHT and NATURE attributes of the shapefile
		create OZ from: shape_file_buildings{
			shape <- (simplification(shape,1000.0));
			population<-int(shape.area/100000);
			income<-float(1000+rnd(5000));
			poverty<-rnd(100)/100;
			unemployment<-rnd(100)/100;
			//location<-{location.x,location.y,poverty*world.shape.width*0.1};
		}
		ask OZ{
			if(shape.area<100000000){
				do die;
			}
		}
		//do degreeMax_computation;
		
		ask OZ {
			do compute_degree;
		}
		create people number:1000{
			location<-any_location_in(one_of(OZ));
			target<-any_location_in(one_of(OZ));
		}
		
		max_pop_value <- OZ max_of (each.population);
		min_pop_value <- OZ min_of (each.population);
		
		max_income_value <- OZ max_of (each.income);
		min_income_value <- OZ min_of (each.income);
		
		max_poverty_value <- OZ max_of (each.poverty);
		min_poverty_value <- OZ min_of (each.poverty);
		
		max_unemployment_value <- OZ max_of (each.unemployment);
		min_unemployment_value <- OZ min_of (each.unemployment);
		
		//do degreeMax_computation;
	}
	
	reflex updateDegreeMax {
		//do degreeMax_computation;
	}

	action degreeMax_computation {
		my_graph <- as_distance_graph(OZ,distance);
		/*degreeMax <- 1;
		ask OZ {
			if ((my_graph) degree_of (self) > degreeMax) {
				degreeMax <- (my_graph) degree_of (self);
			}
		}*/
	}
}

species OZ skills:[moving]{
	float height;
	string type;
	rgb color <- #gray;
	int population;
	float income;
	float poverty;
	float unemployment;
	int degree;
	float radius;
	
	
	reflex updateColor{
		//float level2 <-(min([1,max([0,income/max_income_value])]))^(0.5);//income / (max_income_value - min_income_value) ;//;
		float level2 <-(min([1,max([0,income/6000])]))^(0.5);
		float tmp <- level2*(length(heat_map)-1);
		color <- rgb(heat_map[int(tmp)]);
	}
	reflex update{
		//do wander speed:_speed;
		population<-population+rnd(-100,100);
	}
	
	action compute_degree {
		degree <- my_graph = nil ? 0 : (my_graph) degree_of (self);
		radius <- ((((degree + 1) ^ 1.4) / (degreeMax))) * 5;
		color <- hsb(0.66,degree / (degreeMax + 1), 0.5);
	}
	
	aspect default {
		draw shape color: color;
	}
	aspect depth {
		draw shape depth: height color: color;
	}
	aspect population {
		draw shape depth: population color: color;
	}
	aspect income {
		draw shape depth: income*world.shape.width*0.00001 color: color;
	}
	aspect poverty {
		draw circle(poverty*world.shape.width*0.01) color: color ;
	}
	aspect unemployment {
		draw shape depth: unemployment*world.shape.width*0.01 color: color;
	}
	aspect node {
		draw sphere(world.shape.width*0.005) color: color;
		//draw sphere(world.shape.width*0.01*radius) color: color;
	}
}

species people skills:[moving]{
	point target;
	reflex move{
		do goto target:target speed:1000.0;
	}
	aspect default{
		draw circle(world.shape.width*0.001) color:#white;
	}
}

experiment GIS_agentification type: gui {
	output {
		display map type: opengl background:#black {
			species OZ aspect:default;
		}
		display population type: opengl background:#black autosave:true{
			species OZ aspect:population;
			species people;
		}
		display graph type: opengl background:#black{
			species OZ aspect:node;
			graphics "edges" {
				if (my_graph != nil) {
					loop eg over: my_graph.edges {
						geometry edge_geom <- geometry(eg);
						float val <- 255 * edge_geom.perimeter / distance; 
						draw line(edge_geom.points) color:rgb(val,val,val);
					}
				}
				
			}
		}
		display poverty type: opengl background:#black{
			
			graphics "edges" {
				if (my_graph != nil) {
					loop eg over: my_graph.edges {
						geometry edge_geom <- geometry(eg);
						float val <- 255 * edge_geom.perimeter / distance; 
						draw line(edge_geom.points) color:°gray;
					}
				}
				
			}
			species OZ aspect:poverty;
		}

	}
}