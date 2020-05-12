// Importing the serial library to communicate with the Arduino 
import processing.serial.*; 
import processing.sound.*;

// Initializing a vairable named 'myPort' for serial communication
Serial myPort;      

// Data coming in from the data fields
// data[0] = "1" or "0"                  -- BUTTON
// data[1] = 0-4095, e.g "2049"          -- POT VALUE
// data[2] = 0-4095, e.g. "1023"        -- LDR value
String [] data;

int switchValue = 0;
int potValue = 0;
int ldrValue = 0;

// Change to appropriate index in the serial list — YOURS MIGHT BE DIFFERENT
int serialIndex = 2;

//var for timer
Timer time;
// fonts
PFont titleMain;
PFont titleSub;
PFont tutorialMain;
PFont tutorialSub;
PFont gameMain;
PFont loserMain;
PFont loserSub;
PFont winnerMain;
PFont winnerSub;

//images
PImage feets;
PImage clown;

//sounds
SoundFile laugh;
SoundFile bgMusic;

//player variables
int playerX=650;
int playerY=325;
int playerLives=3;
int mover=0;
int distance=0;

//butcher variables
int butcherX=0;
int butcherY=325;
int bMover=0;

//clown variables
float clownX=800;
float clownY=100;

//state variables
int state=0;
int title=0;
int tutorial=1;
int game=2;
int lose=3;
int win=4;

//var for title
boolean canPlay=false;
//var for tutorial
int tutorState=0;
int tutorStart=0;
boolean tutor1=false;
int tutorPlayerIntro=1;
int tutorButcherIntro=2;
int tutorClownIntro=3;
boolean tutorEnd=false;

//var for game
boolean activeClown=false;
float byeClown=100000000;
boolean moved=false;
int clownCheck=0;
boolean winning=false;


void setup ( ) {
  //window size and backgrounds
  size (1400,  400);  
  background(0);
  
  // List all the available serial ports
  printArray(Serial.list());
  
  // Set the com port and the baud rate according to the Arduino IDE
  //-- use your port name
  myPort  =  new Serial (this, "/dev/cu.SLAB_USBtoUART",  115200); 
  
  //font setups
  titleMain=createFont("Monaco", 20);  //Title
  titleSub=createFont("Monaco", 10);
  tutorialMain=createFont("Monaco",30); //Tutorial
  tutorialSub=createFont("Monaco",15);
  gameMain=createFont("Monaco",10); //Game
  loserMain=createFont("Monaco",30);//Lose
  loserSub=createFont("Monaco",10);
  winnerMain=createFont("Monaco",30);//Win
  winnerSub=createFont("Monaco",10);
  
  //Timer
  time = new Timer(1000);
  
  //images
  feets = loadImage("feets.png");
  clown = loadImage("clown.jpg");
  
  //sounds
  laugh = new SoundFile(this, "laughing.mp3");
  bgMusic = new SoundFile(this, "bgmusic.mp3");
  bgMusic.play();
} 


// We call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();  
    
    print(inBuffer);
    
    // This removes the end-of-line from the string 
    inBuffer = (trim(inBuffer));
    
    // This function will make an array of TWO items, 1st item = switch value, 2nd item = potValue
    data = split(inBuffer, ',');
   
   // we have THREE items — ERROR-CHECK HERE
   if( data.length >= 3 ) {
      switchValue = int(data[0]);           // first index = switch value 
      potValue = int(data[1]);               // second index = pot value
      ldrValue = int(data[2]);               // third index = LDR value
   }
  }
} 

void draw ( ) {  
  //print(switchValue);
  checkSerial();
  
  //state machine
  if(state==title)
  {
  introduction();  
  }else if(state==game)
  {
  runGame();
  }else if(state==lose)
  {
    loseGame();
  }else if(state==win)
  {
   winGame();
  }
  
  //changes state to tutorial from title
  runner();
  if(switchValue==0)
  {
  canPlay=true;
  }
  if(switchValue==1 && state==title && canPlay==true)
  {
  state=game;
  }else if(state==title && switchValue==1)
  {
  state++;
  }
  
  //
  
  
} 

void introduction( ) 
{
  activeClown=false;
  byeClown=100000000;
  moved=false;
  clownCheck=0;
  playerLives=3;
  mover=0;
  bMover=0;
  background(0);
  textFont(titleMain);
  fill(255);
  text("Instructions", 600 + random(-1,1),100+random(-1,1));
  
  textFont(titleSub);
  fill(255);
  text("1. Press the button to move.", 625, 150);
  text("2. Turn the dial to adjust risky moves.", 615, 165);
  text("3. Play in the dark for extra hints", 620,180);
  text("4. DON'T get caught", 630,195);
  text("Press the button to start",650,350);
}


void runGame()
  {
  time.start();
  background(0);
  drawPlayer(playerX+(mover),playerY, playerLives);
  drawFeets();
  runner();
  fill(255);
  textFont(gameMain);
  text("Distance: "+distance,10,10);
  int dtoWin=650-mover;
  text("Distance to win: "+dtoWin,10,20);
  if(switchValue==1 && !moved)
    {
    moved=true;
    mover=mover+distance;
    bMover=bMover-distance; 
    if(bMover<=0)
      {
      bMover=0;
      } 
    }
  if(switchValue==0)
    {
    moved=false;
    }
  
  bMover=bMover+2;
  mover--;
  if(mover<=0)
    {
    mover=0;
    }
    if(bMover>=(playerX+mover))
    {
    bMover=0;
    playerLives--;
    }
    
  //makes clown active and inactive back and forth
  clownCheck++;
  println(clownCheck);
  if(clownCheck>=random(50,300) && !activeClown)
    {
    activeClown=true;
    laugh.play();
    clownCheck=0;
    }else if(clownCheck>=random(20,50) && activeClown==true)
      {
      activeClown=false;
      clownCheck=0;
    }
     
     
  if(activeClown)
    {
     drawClown();
     if(moved)
       {
       float clownCaught = map(distance,1,80,0,100);
       float clownGrab = random(100);
       if(clownGrab<clownCaught)
         {
         playerLives--;
         activeClown=false;
         }
       
       }
    }
  if(mover>=650)
      {
      state=win;
      }
  if(playerLives==0)
    {
    state=lose;
    }
    
  } 

void loseGame()
  {
  background(0);
  textFont(loserMain);
  text("YOU ARE DEAD",650,200);
  textFont(loserSub);
  }
  
  void winGame()
  {
  background(0);
  textFont(winnerMain);
  text("You lived... for now...",650,200);
  }

void drawPlayer(int Px,int Py,int life)
{
  //player color changes based on life
  if(life==3)
  {
  fill(0,255,0);
  }else if(life==2)
  {
  fill(255,235,0);
  }else if(life==1)
  {
  fill(255,0,0);
  }
  
  noStroke();
  ellipseMode(CORNERS);
  ellipse(Px,Py,Px+20,Py+20);
  triangle(Px+10,Py,Px-10,Py+20,Px+20,Py+20);
}

void runner()
  {
    //if player can run then adjust the move
    distance = int(map(potValue, 0,4095,1,20))*2;
  }
  

void drawFeets()
{
float alphavalue = map(ldrValue, 600,1300,-255,0);
float betavalue = abs(alphavalue);

tint (255,betavalue);
image(feets,butcherX+bMover, butcherY,50,50);
}

void drawClown()
{
float alphavalue = map(ldrValue, 600,1300,-255,0);
float betavalue = abs(alphavalue);

tint (255,betavalue);
image(clown,clownX+random(-1,1),clownY+random(-1,1),100,100);
}
