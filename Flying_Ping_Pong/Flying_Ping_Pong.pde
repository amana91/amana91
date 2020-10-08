/****** Variables ******/

// control the active screen by setting/updating gameScreen variable
// correct screen is displayed via the value of this variable
//
// 0: Initial Screen
// 1: Game Screen
// 2: Game-over Screen

int gameScreen = 0;

// gameplay settings
float gravity = .3;
float airfriction = 0.00001;
float friction = 0.1;

// scoring
int score = 0;
int maxHealth = 100;
float health = 100; 
float healthDecrease = 1;
int healthBarWidth = 60;

// ball settings
float ballX, ballY;
float ballSize = 20;
color ballColor = color(0);
float ballSpeedVert = 0;
float ballSpeedHorizon = 0;

//racket settings
color racketColor = color(0);
float racketWidth = 100;
float racketHeight = 10;
//int racketBounceRate = 20;

//wall settings
int wallSpeed = 5;
int wallInterval = 1000;
float lastAddTime = 0;
int minGapHeight = 200;
int maxGapHeight = 300;
int wallWidth = 80;
color wallColors = color(97, 50, 175);
//arraylist stores data of gaps between the walls. Actual walls are drawn accordingly
//[gapWallX, gapWallY, gapWallWidth, gapWallHeight]
ArrayList<int[]> walls = new ArrayList<int[]>();



/****** SETUP ******/

void setup() 
{
  size(500, 500);
  ballX = width/4;
  ballY = height/5;
  smooth();
}


/****** DRAW ******/

void draw() {
  // Display the contents of the current screen
  if (gameScreen == 0) { 
    initScreen();
  } else if (gameScreen == 1) { 
    gameScreen();
  } else if (gameScreen == 2) { 
    gameOverScreen();
  }
}

/****** SCREEN CONTENT ******/

void initScreen() {
  background(201, 196, 209); // main screen colour
  textAlign(CENTER);
  fill(121, 88, 175); // text colour
  textSize(50);
  text("Flying Ping Pong ", width/2, height/2);
  textSize(25); 
  text("Click to start", width/2, height-30);
}

void gameScreen () {

  //codes of game screen
  background (201, 196, 209); // game background colour
  drawBall();
  applyGravity();
  keepInScreen();
  drawRacket(); 
  watchRacketBounce();
  applyHorizontalSpeed();
  wallAdder();
  wallHandler();
  drawHealthBar();
  printScore();
}

void gameOverScreen () {
  //codes for game over screen
  background(201, 196, 209); // end screen colour
  textAlign(CENTER);
  fill(121, 88, 175); // text colour
  textSize(45);
  text("Score", width/2, height/2 - 120);
  textSize(45);
  text(score, width/2, height/2);
  textSize(20);
  text("Click to Restart", width/2, height-30);
}



/****** INPUTS ******/

public void mousePressed ()
{
  // if on initial screen when clicked, start game
  if (gameScreen == 0) {
    startGame();
  }
  if (gameScreen == 2) {
    restart();
  }
}

/****** OTHER FUNCTIONS ******/

//This method sets the necessary variables to start the game
void startGame() {
  gameScreen = 1;
}
void gameOver() {
  gameScreen = 2;
}

void restart() {
  score = 0;
  health = maxHealth;
  ballX = width/4;
  ballY = height/5;
  lastAddTime = 0;
  walls.clear();
  gameScreen = 1;
}

void drawBall() {
  fill (ballColor);
  ellipse(ballX, ballY, ballSize, ballSize);
}

void drawRacket() {
  fill(racketColor);
  rectMode(CENTER);
  rect(mouseX, mouseY, racketWidth, racketHeight, 5);
}

void applyGravity() {
  ballSpeedVert += gravity;
  ballY += ballSpeedVert;
  ballSpeedVert -= (ballSpeedVert * airfriction);
}

void makeBounceBottom(float surface) {
  ballY = surface-(ballSize/2);
  ballSpeedVert*=-1;
  ballSpeedVert -= (ballSpeedVert * friction);
}

void makeBounceTop(float surface) {
  ballY = surface+(ballSize/2);
  ballSpeedVert*=-1;
  ballSpeedVert -= (ballSpeedVert * friction);
}

//keep ball in screen 
void keepInScreen() {
  // ball hits floor
  if (ballY+(ballSize/2) > height) { 
    makeBounceBottom(height);
  }
  // ball hits ceiling
  if (ballY-(ballSize/2) < 0) {
    makeBounceTop(0);
  }
  // ball hits left of the screen
  if (ballX-(ballSize/2) < 0) {
    makeBounceLeft(0);
  }
  // ball hits right of the screen
  if (ballX+(ballSize/2) > width) {
    makeBounceRight(width);
  }
}

void watchRacketBounce() {
  float overhead = mouseY - pmouseY;
  if ((ballX+(ballSize/2) > mouseX-(racketWidth/2)) && (ballX-(ballSize/2) < mouseX+(racketWidth/2))) {
    if (dist(ballX, ballY, ballX, mouseY)<=(ballSize/2)+abs(overhead)) {
      makeBounceBottom(mouseY);
      ballSpeedHorizon = (ballX - mouseX)/10;
      // racket moving up
      if (overhead<0) {
        ballY+=(overhead/2);
        ballSpeedVert+=(overhead/2);
      }
    }
  }
}

void applyHorizontalSpeed() {
  ballX += ballSpeedHorizon;
  ballSpeedHorizon -= (ballSpeedHorizon * airfriction);
}

void makeBounceLeft(float surface) {
  ballX = surface+(ballSize/2);
  ballSpeedHorizon*=-1;
  ballSpeedHorizon -= (ballSpeedHorizon * friction);
}

void makeBounceRight(float surface) {
  ballX = surface-(ballSize/2);
  ballSpeedHorizon*=-1;
  ballSpeedHorizon -= (ballSpeedHorizon * friction);
}

void wallAdder() {
  if (millis() - lastAddTime > wallInterval) {
    int randHeight = round(random(minGapHeight, maxGapHeight));
    int randY = round(random(0, height - randHeight));
    // {gapWallX, gapWallY, gapWallWidth, gapWallHeight, scored}
    int[] randWall = {width, randY, wallWidth, randHeight, 0}; 
    walls.add(randWall);
    lastAddTime = millis();
  }
}

void wallHandler() {
  for (int i = 0; i < walls.size(); i++) {
    wallRemover(i);
    wallMover(i);
    wallDrawer(i);
    watchWallCollision(i);
  }
}

void watchWallCollision(int index) {
  int[] wall = walls.get(index);
  // get gap wall settings 
  int gapWallX = wall[0];
  int gapWallY = wall[1];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall[3];
  int wallScored = wall[4];
  int wallTopX = gapWallX;
  int wallTopY = 0;
  int wallTopWidth = gapWallWidth;
  int wallTopHeight = gapWallY;
  int wallBottomX = gapWallX;
  int wallBottomY = gapWallY + gapWallHeight;
  int wallBottomWidth = gapWallWidth;
  int wallBottomHeight = height - (gapWallY + gapWallHeight);


  if (
    (ballX+(ballSize/2)>wallTopX) &&
    (ballX-(ballSize/2)<wallTopX + wallTopWidth) &&
    (ballY+(ballSize/2)>wallTopY) &&
    (ballY-(ballSize/2)<wallTopY +wallTopHeight)
    ) {
    decreaseHealth();
  }

  if (
    (ballX+(ballSize/2)>wallBottomX) &&
    (ballX-(ballSize/2)<wallBottomX + wallBottomWidth) &&
    (ballY+(ballSize/2)>wallBottomY) &&
    (ballY-(ballSize/2)<wallBottomY +wallBottomHeight)
    ) {
    decreaseHealth();
  }

  if (ballX > gapWallX + (gapWallWidth/2) && wallScored == 0) {
    wallScored = 1;
    wall [4] = 1;
    score();
  }
}


void wallDrawer(int index) {
  int[] wall = walls.get(index);
  // get gap wall settings
  int gapWallX = wall[0];
  int gapWallY = wall[1];
  int gapWallWidth = wall[2];
  int gapWallHeight = wall [3];

  //draw actual walls
  rectMode(CORNER);
  noStroke();
  strokeCap(ROUND);
  fill(wallColors);
  rect(gapWallX, 0, gapWallWidth, gapWallY, 0, 0, 15, 15);
  rect(gapWallX, gapWallY + gapWallHeight, gapWallWidth, height - (gapWallY + gapWallHeight), 15, 15, 0, 0);
}

void wallMover(int index) {
  int [] wall = walls.get(index);
  wall[0] -= wallSpeed;
}

void wallRemover(int index) {
  int [] wall = walls.get(index);
  if (wall [0] + wall[2] <= 0) {
    walls.remove(index);
  }
}

void drawHealthBar() {
  noStroke();
  fill(236, 240, 241);
  rectMode(CORNER);
  rect(ballX - (healthBarWidth/2), ballY - 30, healthBarWidth, 5);
  if (health > 60) {
    fill (46, 204, 113);
  } else if (health > 30) {
    fill (230, 126, 34);
  } else {
    fill (231, 76, 60);
  }
  rectMode(CORNER);
  rect(ballX - (healthBarWidth/2), ballY - 30, healthBarWidth * (health/maxHealth), 5);
}

void decreaseHealth() {
  health -= healthDecrease;
  if (health <= 0) {
    gameOver();
  }
} 

void score() {
  score++;
}

void printScore() {
  textAlign(CENTER);
  fill(0);
  textSize(35); 
  text(score, height/2, 50);
}
