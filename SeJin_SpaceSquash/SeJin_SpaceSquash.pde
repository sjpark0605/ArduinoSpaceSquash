import processing.serial.*;

Serial myPort; // Create a variable to read the input from the Arduino serial

int score = 0;
int lives = 3;

float racketPos = 50;
float ballPosX, ballPosY; // Horizontal and vertical positions of ball
float velX, velY; // Horizontal and vertical velocities of ball

boolean tiltLeft, tiltRight;
boolean gameOver, reset = false;
boolean headUp = true; /* Boolean to determine if ball is moving upwards
                          The value is initalized to "true" since ball always starts upwards. */
PFont font;
PImage wall, ball, racket, bkgd; /* Create variables for images. 
                                    PImage automatically detects height and width of image size. */

void setup() {
  size(1280, 800);
  background(0, 0, 0);
  frameRate(60); // The game runs at 60 FPS or 60 HZ.
  myPort = new Serial(this, "COM6", 9600);
  
  imageMode(CORNER); // Coordinates of images are (0,0) on the top-left corner.
  bkgd = loadImage("background.jpg");
  ball = loadImage("ball.png");
  racket = loadImage("racket.png");
  
  font = createFont("Arial", 30, true);
  serveBall();
}

void draw() {
  // Draw Background on Canvas
  image(bkgd, 0, 0);
  
  // Displays Score on Top Left of Screen
  textFont(font, 30);
  text("Score: " + score, 15, 40);
  text("Lives: " + lives, 1160, 40);
  text("Ball Speed: " + int(sqrt((velY * velY) + (velX * velX))), 580, 40);
  
  // Draws Rectangular Ceiling and Side Barriers
  rect(0, 0, bkgd.width, 10);
  rect(0, 10, 10, bkgd.height - 10); 
  rect(bkgd.width - 10, 10, 10, bkgd.height - 10); 
  
  // Draw racket with corresponding positions
  image(racket, racketPos, 730);
  
  // Read data from the Arduino and execute corressponding commands
  if (myPort.available() > 0) { 
    String data = myPort.readStringUntil(10); // Read data up to the escape character "\n" or NL, which is 10 in ASCII
    if (data != null) {
      switch(data) { // Alternate pre-declared boolean values corresponding to the input from the serial port
        case "Left\n":
          tiltLeft = true;
          tiltRight = false;
          break;
        case "Right\n":
          tiltLeft = false;
          tiltRight = true;
          break;
        case "Reset\n":
          gameReset();
        case "0\n":
          tiltLeft = false;
          tiltRight = false;
          break;
      }
    } 
  }

  // Execute commands according to the boolean values
  if (tiltLeft) {
    racketPos -= 10;
  }
  else if (tiltRight) {
    racketPos += 10;   
  }
  else if (reset) {
    gameReset();
    reset = false;
  }
  
  // Keep the rackets within the side boundaries
  if (racketPos < -10) {
    racketPos = -10;
  }
  else if (racketPos > (bkgd.width - 134)) {
    racketPos = bkgd.width - 134;
  }
  
  //Draw Ball
  translate(ballPosX, ballPosY);
  image(ball,0,0);
  
  // Keep within boundaries
  ballPosX = ballPosX + velX;
  ballPosY = ballPosY + velY;
  
  // Hit the ball if it collides with any permitted object
  bounce();
  int momentum = int(map(abs(ballPosX - racketPos), 0, 30, -2, 2));
  hitBall(momentum);
  
  // Lose life if the ball misses the racket
  if (ballPosY > 800 && lives > 0) {
    lives = lives - 1;
    ballReset();
  }
  
  // Launch game over screen if there are no lives left.
  if (lives <= 0) {
    gameOver();
  }
}

// Reset the ball back onto the racket
void ballReset() {
  ballPosX = racketPos + 60;
  ballPosY = 760;
  velX = random(-3, 3);
  velY = random(-7, -3);
}

// Reset the whole game by resetting the lives, scores, and the ball position
void gameReset() {
  lives = 3;
  score = 0;
  serveBall();
  gameOver = false;
}

// Bounce the ball against any objects
void bounce() {
  // Bounce the ball against the ceiling and the barriers
  if ((ballPosX < 10 || ballPosX > 1250) && !gameOver) {
    velX = -velX;
    score += 1;
  }
  else if (ballPosY < 10) {
    velY = -velY;
    score += 1;
  }  
}

// Bounce the ball against the racket
void hitBall(int momentShift) {
  if ((ballPosY > 760) && !gameOver) {
    if (ballPosX > racketPos + 10 & ballPosX < racketPos + 100) {
      velX = random(-2, 2) * momentShift;
      velY = random(-6, -3);
      score += 10;
    }
  }
}

// Serve the ball at the beginning of the game from the paddle
void serveBall() {
  ballPosX = racketPos + 60;
  ballPosY = 760;
  velX = random (-6,6);
  velY = -3;
}

// Freeze the game and prompt user with "Game Over," the score, and the reset sequence
void gameOver() {
  ballPosX = 1440;
  ballPosY = 800;
  text("Game Over", -bkgd.width/2 - 200, -bkgd.height/2);
  text("Your Score is: " + score, -bkgd.width/2 - 230, -bkgd.height/2 + 40);
  text("Please Press Switch to Restart", -bkgd.width/2 - 340, -bkgd.height/2 + 80);
  gameOver = true;
}
