import ddf.minim.*;

Minim minim;
ArrayList<AudioPlayer> players;
AudioInput input;
int numJunkies = 6;

PImage[] images;
ArrayList<Entity> ents;
ArrayList<Pillar> pillars;
ArrayList<Junky> junkies;
Extract extract;
int offsetX = 23;
int offsetY = 70;
int musicPlaying = 0;
Entity musicIndiceDeLecture;
float[] speedMultipliers = {0.7, 0.5, 2.0, 4.0, 1.0, 1.0, 1.0}; // doit avoir comme length le nombre de cassettes
int nombreDeCassettes = 7;

void setup() {
  size(1600, 900);
  frameRate(50);
  ents = new ArrayList<Entity>();
  pillars = new ArrayList<Pillar>();
  junkies = new ArrayList<Junky>();
  players = new ArrayList<AudioPlayer>();
  ents.add(new Entity(0,0,-1,2, true));
  images =new PImage[54];
  
  
  images[0] = loadImage("data/persoBlanc.png");
  images[1] = loadImage("data/cassette0.png");
  images[2] = loadImage("data/fond.png");
  images[3] = loadImage("data/perso.png");  
  images[4] = loadImage("data/map.png");  
  images[4].loadPixels();
  images[5] = loadImage("data/indiceDeLecture.png");
  images[6] = loadImage("data/haloDispatition.png");
  images[7] = loadImage("data/extract.png");
  images[8] = loadImage("data/basdroit.png");
  images[9] = loadImage("data/basgauche.png");
  images[10] = loadImage("data/hautdroit.png");
  images[11] = loadImage("data/hautgauche.png");
  images[12] = loadImage("data/basdroitE.png");
  images[13] = loadImage("data/basgaucheE.png");
  images[14] = loadImage("data/hautdroitE.png");
  images[15] = loadImage("data/hautgaucheE.png");
  for(int i = 0; i<7; i++) {
    images[16+i] = loadImage("data/cassette"+Integer.toString(i)+".png");
    Entity ent = new Entity(10, 100*i ,-1, 16+i, true);
    ents.add(ent);
  }
  musicIndiceDeLecture = new Entity(130,10,1,5, true);
  ents.add(musicIndiceDeLecture);
  
  int[][] positionsX = {{852, 640, 482, 291, 77},{237, 497, 779},{-29, 136, -30, 414, 698},{189, 404, 593, 593, 753, 965}};
  int[][] positionsY = {{-50, 73, 175, 284, 410},{487, 573, 678},{508, 555, 717, 623, 725},{453, 327, 327, 219, 117, -7}};  
  
  Entity extractEnt = new Entity(800-80, 800-50, 0, 7, true);
  extract = new Extract(800,800, extractEnt);
  ents.add(extractEnt);
  for(int type = 0; type<4; type++) {
    for(int j = 0; j< positionsX[type].length; j++) {
      Entity ent = new Entity(positionsX[type][j], positionsY[type][j] ,0,12+type, true);
      Pillar pillar = new Pillar(positionsX[type][j]+106, positionsY[type][j]+130, false, ent);
      ents.add(ent);
      pillars.add(pillar);
    }
  }
  
  for(int i = 0; i<numJunkies; i++) {
    Entity ent = new Entity(0, 0, 1, 3, true);
    Entity ent2 = new Entity(0, 0, 1, 6, false);
    Junky junkie = new Junky(random(100, height - 100),random(100, height - 100), ent, ent2, i);
    junkie.randomValidPosition();
    ents.add(ent);
    ents.add(ent2);
    junkies.add(junkie);
  } 
  
  minim = new Minim(this);
  for(int i = 0; i < (nombreDeCassettes) ; i ++) {    
    AudioPlayer player = minim.loadFile("data/piste"+Integer.toString(i)+".mp3");
    players.add(player);
  }
  input = minim.getLineIn();
  
}

class Entity {
  public int x, y, z, alpha;
  public int img;
  boolean display;
  Entity(int posx, int posy, int z, int img, boolean display) {
    x = posx;
    y = posy;
    this.z = z;
    this.img = img;
    this.display = display;
    this.alpha = 255;
  }
}

double dista(float x, float y, float x2, float y2) {
  return Math.sqrt((x-x2)*(x-x2) + (y-y2)*(y-y2));
}

int findNeighbors(int idx, float minDistance) {
 int ineigh = -1; 
 float max_dist=2000.0;
 for(int i = 0; i < junkies.size(); i++) {
   if(i != idx) {
     float distance = (float)dista(junkies.get(idx).x, junkies.get(idx).y, junkies.get(i).x, junkies.get(i).y);
     if(distance < max_dist && distance<minDistance) {
       max_dist = distance;
       ineigh = i ;    
     }
   }
 }
  return ineigh;
}

float randomManiacAngle(float x, float y) {
  float angle =(random(500)/250.0) * 3.1415; 
  float nx = x + (float)(20 * Math.cos(angle));
  float ny = y + (float)(20 * Math.sin(angle));

  while(colliding(nx, ny)) {
    angle = random(500)/250.0 * 3.1415;
    nx = x + (float)(20 * Math.cos(angle));
    ny = y + (float)(20 * Math.sin(angle));     
  }    
  return angle;
}

int findClosestPillar(float x, float y, ArrayList<Pillar> p, float minDistance, boolean state) {
  int ipillar = -1;
  float max_dist=2000.0;
  for(int i = 0; i < p.size(); i++) {    
    float distance = (float)dista(x, y, p.get(i).x, p.get(i).y);
    if(distance < max_dist && distance<minDistance && (!state || p.get(i).on)) {
      max_dist = distance;
      ipillar = i ;    
    }
  }
  return ipillar;
}

boolean colliding(float x, float y) {
  int rx = (int)x;
  int ry = (int)y;
  if(rx <0 || ry <0 || rx >= images[4].width || ry >= images[4].height)
    return true;
  if(red(images[4].pixels[rx + ry * images[4].width])>128)
    return false;
  return true;
}

class Junky {
  float x, y, speed, angle, timer;
  int countNoDep;
  String instruction, state;
  Entity entity, dyingEnt;
  int selfIndex;
  boolean won;
  
  Junky(float x, float y, Entity ent, Entity dyingEnt, int selfIndex) {
    this.x = x;
    this.y = y;
    this.speed = 30.0;
    this.angle = 1.0;
    this.instruction = "continue";   
    this.timer = 3.0;
    this.state = "moving";
    this.entity = ent;      
    this.dyingEnt = dyingEnt;
    this.selfIndex = selfIndex;
    this.countNoDep = 0;
    this.won = false;
  }
  
  void randomValidPosition() {
    float nx = random(100, width - 100);
    float ny = random(100, height - 100);

    while(colliding(nx, ny) || dista(nx, ny, extract.x, extract.y) < 300) {
      nx = random(100, width - 100);
      ny = random(100, height - 100);      
    }
    
    this.x = (int)nx;
    this.y = (int)ny;
   }
  
  void update(float dt) {
    timer = timer - dt;
    
    if(won) {
      entity.img = 0;   
      entity.alpha = (int)(255 * (timer / 2.0));
      dyingEnt.alpha = (int)(255 * (timer / 2.0));
      return;     
    }
    if(dista(x, y, extract.x, extract.y) < 120) {
     // WINNNER !
       System.out.println("winner!");       
       dyingEnt.display = true;
       dyingEnt.x = (int)x  - 200;
       dyingEnt.y = (int)y  - 200;
       won = true;
       timer = 2.0;
       return;
    }
    
    
    
    if(state != "continue" && instruction!="random") {
        switch(musicPlaying) {
         case 1: instruction = "follow"; break;
         case 2: instruction = "misantrope"; break;
         case 3: instruction = "maniac"; break;
         case 4: instruction = "lovers"; break;
      }       
    } 
    
    float speedMultiplier = 1.0;
    if(musicPlaying != -1)
      speedMultiplier = speedMultipliers[musicPlaying];
     
    if(state == "moving") {
      float oldx = x;
      float oldy = y;
      float nextx = x + (float)(speed*dt * Math.cos(angle));
      float nexty = y + (float)(speed*dt * Math.sin(angle));      
      if(colliding(nextx, nexty)) {
        if(instruction == "maniac")
          angle = angle + 3.1415;
        else
          angle = random(90)*2*3.145/90.0;
      }
      else {
        x = nextx;
        y = nexty;
      }
      if(dista(x,y, oldx, oldy)<0.1) 
        countNoDep += 1;
       else
         countNoDep = 0;
       if(countNoDep > 100)
         instruction = "random";
    }
    
    if(instruction == "follow") {
      if(timer<0.0) {
        int i = findClosestPillar(x, y, pillars, 500.0, true);
        if(i!=-1)  {        
           angle = (float) Math.atan2(pillars.get(i).y - y, pillars.get(i).x - x);
           float dist = (float)dista(pillars.get(i).x, pillars.get(i).y, x, y);
           if(dist < 20) {
              speed = 5.0;
              state = "continue";
              timer = 1.0;
           }
            else {
              speed = speedMultiplier * (20 + 5000 / dist);
           }
        }
        else {
          timer = 3.0+random(8)/4.0;
          if(speed < 6.0)
            instruction = "random";
          else 
            instruction = "continue";          
        }   
      }
    }
    else if (instruction == "misantrope") {
      int i = findNeighbors(selfIndex, 200);
      if(i!=-1)  {
            System.out.println(i);        
           angle = (float) Math.atan2(junkies.get(i).y - y, junkies.get(i).x - x) + 3.1415 + (random(8)/10.0 - 0.4);
           float dist = (float)dista(junkies.get(i).x, junkies.get(i).y, x, y);
           if(dist < 20) {
              speed = 50.0;
           }
            else {
              speed = speedMultiplier * (20 + 5000 / dist);
           }
        } 
      else {
        instruction = "continue";  
        timer = 1.5;
      }
    }
    else if (instruction == "lovers") {
      int i = findNeighbors(selfIndex, 200);
      if(i!=-1)  {
            System.out.println(i);        
           angle = (float) Math.atan2(junkies.get(i).y - y, junkies.get(i).x - x) + (random(10)/20.0 - 0.1);
           float dist = (float)dista(junkies.get(i).x, junkies.get(i).y, x, y);
           if(dist < 20) {
              speed = 50.0;
           }
            else {
              speed = speedMultiplier * (20 + 5000 / dist);
           }
        } 
      else {
        instruction = "continue";  
        timer = 1.5;
      }
    }
    else if (instruction == "maniac") {
      if(musicPlaying != 3) {
        instruction = "continue";  
        timer = 1.5;
      }
      if(timer < 0.0) 
        instruction = "random";
    }
    else if (instruction == "wiggle") {
      x += (random(100) - 50)/50.0;
      y += (random(100) - 50)/50.0;
    }
    else if (instruction == "continue") {
       if(timer<0.0) {
          state = "stopping"; 
          instruction = "random";
          speed = speedMultiplier * 40.0;
       }
    }
    else { //random move
      if (state == "moving") {
        if (timer < 0.0) {
          timer = 0.5 + random(10)/20.0;                    
          state = "stopping";
        }
      }              
      else {
        if (timer < 0.0) {
          timer = 0.5;
          state = "moving";
          if(random(100)<60 && musicPlaying == 1) 
            instruction = "follow";
          if(random(100)<60 && musicPlaying == 2)
            instruction = "misantrope";
          if(musicPlaying == 3) {
            angle = randomManiacAngle(x, y);
            instruction = "maniac";
            timer = 30.0 + random(10);
          }
          speed = speedMultiplier * 40.0;
          angle = random(90)*2*3.145/90.0;
        }
      }
    }
  }
}

class Pillar {
  int x, y;
  boolean on;
  Entity ent;
  
  Pillar(int x, int y, boolean on, Entity entity) {
    this.x = x;
    this.y = y;
    this.on = on;
    this.ent = entity;
  }
  void switchLight() {
    on = !on;    
    //ent.display = on;
    if(on)
      ent.img -=4;
    else
      ent.img +=4;
  }
}

class Extract {
  int x, y;
  Entity ent;
  
  Extract(int x, int y, Entity entity) {
    this.x = x;
    this.y = y;    
    this.ent = entity;
  }
}

void draw() {
  background(0);
  
    // display all entities
  for(int i = 0; i <ents.size(); i++) {    
    if(ents.get(i).display) {
      tint(255, ents.get(i).alpha); 
      image(images[ents.get(i).img], ents.get(i).x, ents.get(i).y);
    }
  }
  for(int i = 0; i <junkies.size(); i++) {
    Junky junkie = junkies.get(i);
    junkie.update(0.02);
    junkie.entity.x = (int)junkie.x - offsetX;
    junkie.entity.y = (int)junkie.y - offsetY;
  }    
  
    // Loop musics 
  if(musicPlaying != -1) {
    if(!players.get(musicPlaying).isPlaying()) {
      players.get(musicPlaying).rewind();
      players.get(musicPlaying).play();
    }
  }
    /*for junkie in junkies:
        junkie.update(0.02)
        ents[junkie.entity].x = junkie.x - offsetX
        ents[junkie.entity].y = junkie.y - offsetY*/
}

void mouseReleased()
{
  int index = findClosestPillar(mouseX, mouseY, pillars, 200.0, false);
  if(index != -1) {
    pillars.get(index).switchLight();
  }
        
  if(mouseX < 160 && mouseY< 770) {
    int idx = mouseY / 100;
    musicIndiceDeLecture.y = idx*100 + 10;
    if(idx < (nombreDeCassettes) && musicPlaying != idx) {      
      for(int i = 0; i < players.size(); i++) {
        if(i != idx)
          players.get(i).pause();
      }
      players.get(idx).play();
      musicPlaying = idx;
    }
  }
  
}

