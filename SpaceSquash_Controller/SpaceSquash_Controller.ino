// Assigning corresponding pin values to the input buttons
int leftButton = 11;
int rightButton = 4;
int resetButton = 10;

// Assigning corressding pin values to the output: LEDs and Buzzer
int leftLED = 9;
int stopLED = 8;
int rightLED = 7;

int buzzer = 5;


void setup() {
  Serial.begin(9600); // Begins data transmission at 9600 baudrate (bits per second)

  // Assigns mode of pin (INPUT or OUTPUT) to the pre-assigned pin values
  pinMode(leftButton, INPUT);
  pinMode(rightButton, INPUT);
  pinMode (resetButton, INPUT);

  pinMode(leftLED, OUTPUT);
  pinMode(stopLED, OUTPUT);
  pinMode(rightLED, OUTPUT);

  pinMode(buzzer, OUTPUT);
}

void loop() {
  // Read the data coming from the buttons, which is represented in int of either 0 or 1
  int leftMove = digitalRead(leftButton);
  int rightMove = digitalRead(rightButton);
  int reset = digitalRead(resetButton);
  
  if (leftMove == 1) {
    Serial.print("Left\n");
    ledStatus(1, 0, 0);
  }
  else if (rightMove == 1) {
    Serial.print("Right\n");
    ledStatus(0, 0, 1);
  }
  else if (reset == 1){
    Serial.print("Reset\n");
    playMusic();
  }
  else {
    Serial.print("0\n");
    ledStatus(0, 1, 0);
  }
   
  delay(100);// Execute the loop every 0.1 seconds, delaying and thus stabilising the data-read from the Arduino
}

// This function outputs music through the buzzer
void playMusic() {

  // Values of arrary represent the frequeinces of C4, E4, G4, and C5 respectively
  float frequency[] = {261.63, 329.63, 392.00, 523.25}; 
  
  int i;
  // For loop iterates through each note for the buzzer until the 4th frequency (C5) is played
  for (i = 0; i < 4; i++) { 
    tone(buzzer, frequency[i]);
    delay(80); // Duration of each note is 0.08 seconds
  }
  noTone(buzzer); // Stop playing sound from the buzzer
}

// This function is responsible for controlling the LEDs by taking input values to the parameter
void ledStatus(int left, int center, int right) {
  digitalWrite(leftLED, left);
  digitalWrite(stopLED, center);
  digitalWrite(rightLED, right);
}

