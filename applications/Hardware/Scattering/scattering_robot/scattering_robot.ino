// include the library code:
#include <LiquidCrystal.h>
#include <Wire.h>

//%%%%%% TEMPURATURE + HUMIDITY + TURN TABLE VARIABLES%%%%
#define ADDRESS (0x8 << 3)
#define BREMS_RELAIS (11)  //Port B3
#define NETZ_RELAIS (12)   //Port B4
//%%%%%% Serial_Variables %%%%%%%

const int baudrate = 9600;
const int buffersize = 25; // Maximum word size of messages sent to arduino. ie: 25 letter messages at max if buffersize = 25

const double up_rate = 1620.8;       // Milli seconds per centimeter of UPWARD movement (ms/cm)     ie: Centimeter value * up_rate = milli seconds required
const double down_rate = 1614.70588; // Milli seconds per centimeter of DOWNWARD movement (ms/cm)   ie: Centimeter value * down_rate = milli seconds required
const double rot_cw_rate = 635.9832;     // Milli seconds per radian of clockwise motion (ms/deg)   ie: Degree value * rot_rate = milli seconds required
const double turn_table_rate = 80000/360; // Milli seconds per 360 degrees    ie: degree value * turn_table_rate = milli seconds required

LiquidCrystal lcd(6, 7, 5, 4, 3, 2);

char message[buffersize];
long delay_time;
long time;
long time_ref;
int microdelay;

//%%%%%%% Robot Variables %%%%%%%

boolean a, step_now;


// DEFINE ENABLE PIN
const int enable =  17;

// DEFINE PINS FOR VERTICAL MOVEMENT
const int step_1 =  10;
const int dir_1  =  13;

// ROTATION
const int step_2 =  9;
const int dir_2  =  8;

// SWITCHES
const int button_up =  14;
const int button_down =  16;
const int button_rotate =  15;



void setup() {
  //%%%%%% TEMPURATURE + HUMIDITY + TURN TABLE VARIABLES %%%%%%
  Wire.begin(ADDRESS);
  pinMode(NETZ_RELAIS, OUTPUT);
  pinMode(BREMS_RELAIS, OUTPUT);
  //%%%%%% Serial_Variables %%%%%%
  lcd.begin(16, 2);
  lcd.setCursor(2,0);
  lcd.print("Ready ...");
  Serial.begin(baudrate); // baud rate was originally 115200
  Serial.flush();

  //%%%%%% Robot Variables %%%%%%
  pinMode( enable, OUTPUT);
  pinMode( dir_1, OUTPUT);
  pinMode( dir_2, OUTPUT);
  pinMode( step_1, OUTPUT);
  pinMode( step_2, OUTPUT);
  pinMode( button_up, INPUT);
  pinMode( button_down, INPUT);
  pinMode( button_rotate, INPUT);
  digitalWrite( enable, HIGH);
  digitalWrite( dir_1, LOW);
  digitalWrite( dir_2, LOW);
  digitalWrite( step_1, LOW);
  digitalWrite( step_2, LOW);  
  digitalWrite( button_up, HIGH);  
  digitalWrite( button_down, HIGH);  
  digitalWrite( button_rotate, HIGH);    
  step_now = 0;
}

void loop() {

  if ( Serial.available() > 0) { 

    serial_read(message); // reads the serial message and stores it in the array "message"
    // debugging stuff
    //lcd.clear();
    //lcd.print("New message: ");
    //lcd.setCursor(0,1);
    //lcd.print(message);
    
    // delay(1000); debugging

    if(message[0] == 'm') {                      //TEMPERATURE + HUMIDITY

      // start a temperature measurement (hold master)
      float T = -46.85 + 175.72*(float)measure_T()/65536;

      // start a humidity measurement (hold master)
      float RH = -6 + 125.0*(float)measure_RH()/65536;

      Serial.print(T);
      Serial.print(",");
      Serial.println(RH);

      lcd.clear();
      lcd.setCursor(3, 0);
      lcd.print(int(T),DEC);
      lcd.setCursor(12, 0); 
      lcd.print(int(RH),DEC);
      lcd.setCursor(0, 1);
      lcd.print("Measurement done");
    }

    if(message[0] == 't') {                       //TURN TABLE ROTATION
    
      double turnDegrees = distance();  // turnRadians radians to move

      lcd.clear();
      lcd.setCursor(0, 1);
      lcd.print(" Moving: ");
      lcd.setCursor(9, 1); 
      lcd.print(int(turnDegrees),DEC);
      lcd.setCursor(11, 1); 
      lcd.print(" deg ");

      // delay(1000); debugging

      long timeToWait = long(turnDegrees*turn_table_rate);
      digitalWrite( BREMS_RELAIS, HIGH);
      delay(timeToWait);
      digitalWrite( BREMS_RELAIS, LOW);
      lcd.setCursor(0, 1);
      lcd.print(" Moving done    ");

      Serial.println("Turn table rotated");

    }
    
    if(message[0] == 'p') {                       //TURN TABLE POWER ON
    
      digitalWrite( NETZ_RELAIS, HIGH);
      delay(100);
      Serial.println("Turn table turned on");
      
      lcd.clear();
      lcd.setCursor(0, 1);
      lcd.print(" Turn table on  ");
    }
    
    if(message[0] == 'n') {                       //TURN TABLE POWER OFF
    
      digitalWrite( NETZ_RELAIS, LOW);
      delay(100);
      Serial.println("Turn table turned off");
    
      lcd.clear();
      lcd.setCursor(0, 1);
      lcd.print(" Turn table off ");
    }

    if(message[0] == 'l'){                       //ROTATE LEFT (COUNTER CLOCK WISE AS VIEWED FROM ABOVE)

      lcd.clear();
      lcd.setCursor(0,1);
      lcd.print("Direction: LEFT");
      lcd.print("    ");

      rotate_left();  
    }


    if(message[0] == 'r'){                       //ROTATE RIGHT (CLOCK WISE AS VIEWED FROM ABOVE)

      lcd.clear();
      lcd.setCursor(0,1);
      lcd.print("Direction: RIGHT");
      lcd.print("    ");

      rotate_right();  
    }

    if(message[0] == 'u'){                      //MOVE UP

      lcd.clear();
      lcd.setCursor(0,1);
      lcd.print("Direction: UP");
      lcd.print("    ");

      move_up(); 

    }

    if(message[0] == 'd'){                      //MOVE DOWN      

      lcd.clear();
      lcd.setCursor(0,1);
      lcd.print("Direction: DOWN");
      lcd.print("    ");

      move_down();

    }
  } 
  /*
  else {
    double turnRadians = 0.1047;  // turnRadians radians to move

      lcd.clear();
      lcd.setCursor(0, 1);
      lcd.print(" Moving: ");
      lcd.setCursor(9, 1); 
      lcd.print(int(turnRadians*360/6.283),DEC);
      lcd.setCursor(11, 1); 
      lcd.print(" deg ");

      // delay(1000); debugging

      long timeToWait = long(turnRadians*turn_table_rate);
      digitalWrite( BREMS_RELAIS, HIGH);
      delay(timeToWait);
      digitalWrite( BREMS_RELAIS, LOW);
      lcd.setCursor(0, 1);
      lcd.print(" Moving done    ");
      delay(2000);
  } // END of if(Serial.available() > 0)
  */
  
  delay(100); // necessary since serial is SLOW
} // END of loop()


double distance() // calculates either the amount of centimeters to move up/down or degrees to rotate left/right from information sent from MATLAB
{           // ie: turns a string like 0145 into 0.145 meters or alternatively 14.5 degrees
  double first_number = int(message[1])- 48;
  double second_number = int(message[2]) - 48;
  double third_number = int(message[3]) - 48;
  double fourth_number = int(message[4]) - 48;

  double answer = first_number*100 + second_number*10 + third_number + fourth_number*0.1;
  return answer;
}


void serial_read(char temp2[]) // Reads the serial data and stores it in the array pointer temp2
{
  char temp[buffersize+1];
  int length = 0; 
  empty(temp2);

  for( int k = 0; Serial.available() > 0; k++)
  {
    temp[k] = Serial.read();
    length++;
    delay(10); // Delay to compensate for slow serial
  }          

  for(int j = 0; j < (length-1); j++) // gets rid of the last char of the temp array and puts it into mess
  {
    temp2[j] = temp[j];
  }
  Serial.flush();
}


void empty(char array[]) // Emptys the "message" array. ie: fills it with blank values
{
  for(int i = 0; i < buffersize; i++){
    array[i] = ' '; 
  }
}


void move_down()                                                //DOWN
{
  digitalWrite( dir_1, HIGH);
  digitalWrite( enable, LOW);

  delay_time = distance()*down_rate;
  time_ref = millis();

  while( digitalRead(button_down) == HIGH) // if either button is pressed
  {
    time = millis()-time_ref;
    if(time > 1000 && digitalRead(button_up) == LOW){
      break; //<---After 1 second it checks if the bottom button is pressed as a precaution.  
    }
    //    The reason for one second is if the robot were to start moving up from the bottom  
    if(time >= delay_time){
      break;
    }                             //    the button would be already pressed. It needs 1 second to move off the button                  
    //    before checking this condition.
    if( step_now == 1) step_now = 0;
    else step_now = 1;
    delay(2);
    digitalWrite( step_1, step_now);
  }           
  digitalWrite( enable, HIGH);

  if(digitalRead(button_down) == LOW){
    Serial.println("bottom pressed");
  } 
  else if(digitalRead(button_up) == LOW){
    Serial.println("top pressed");
  } 
  else {
    Serial.println("down complete");
  }  
}


void move_up()                                                    //UP
{
  digitalWrite( dir_1, LOW);
  digitalWrite( enable, LOW);

  delay_time = distance()*up_rate;
  time_ref = millis();


  while( digitalRead(button_up) == HIGH) // if either button is pressed
  {
    time = millis()-time_ref;
    if(time > 1000 && digitalRead(button_down) == LOW){ 
      break;
    }//<---After 1 second it checks if the bottom button is pressed as a precaution.  
    //    The reason for one second is if the robot were to start moving up from the bottom  
    if(time >= delay_time){
      break;
    }                              //    the button would be already pressed. It needs 1 second to move off the button 
    //    before checking this condition.
    if( step_now == 1) step_now = 0;
    else step_now = 1;
    delay(2);
    digitalWrite( step_1, step_now);
  }           
  digitalWrite( enable, HIGH);

  if(digitalRead(button_down) ==  LOW){
    Serial.println("bottom pressed");
  }
  else if(digitalRead(button_up) ==  LOW){
    Serial.println("top pressed");
  }
  else if(digitalRead(button_up) ==  HIGH || digitalRead(button_down) ==  HIGH){
    Serial.println("up complete");
  }
  else {
    Serial.println("Unknown");
  }
}

void rotate_left()                       //LEFT: This function moves the robot to the reference rotation position (resets the rotation)
{
  digitalWrite( dir_2, HIGH);
  digitalWrite( enable, LOW);

  while( digitalRead(button_rotate) == HIGH)
  {

    if( step_now == 1) step_now = 0;
    else step_now = 1;
    delay(5);
    digitalWrite( step_2, step_now);
  }           
  digitalWrite( enable, HIGH);

  delay(250);
  digitalWrite( dir_2, LOW);
  digitalWrite( enable, LOW);

  while(digitalRead(button_rotate) == LOW)
  {
    if( step_now == 1){ 
      step_now = 0; 
      microdelay=1000;
    } //Micro delay dictates 1 second pause between bursts
    else { 
      step_now = 1; 
      microdelay=2;
    }
    delay(microdelay);
    digitalWrite( step_2, step_now);
  }

  digitalWrite( enable, HIGH);

  if(digitalRead(button_rotate) == HIGH){
    Serial.println("left complete");
  }
  else if(digitalRead(button_rotate) ==  LOW){
    Serial.println("rotation pressed");
  }
}


void rotate_right()                                             //RIGHT
{

  digitalWrite( dir_2, LOW);
  digitalWrite( enable, LOW);

  delay_time = distance()*rot_cw_rate;
  time_ref = millis();


  while(digitalRead(button_rotate) == HIGH)
  {
    time = millis()-time_ref;
    if(time >= delay_time){
      break;
    } 

    if( step_now == 1) step_now = 0;
    else step_now = 1;
    delay(5);
    digitalWrite( step_2, step_now);
  }

  digitalWrite( enable, HIGH);
  if(digitalRead(button_rotate) == HIGH){
    Serial.println("right complete");
  }
  else if(digitalRead(button_rotate) == LOW){
    Serial.println("rotation pressed");
  }
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// These functions measure Temperature and Humidity. They communicate using I2C through the wire library. 
// The code was taken frmo Markus's original scatter box code.

unsigned int measure_T() {           
  // start a temperature measurement (hold master)
  byte valMSB = 0;
  byte valLSB = 0;
  Wire.beginTransmission(ADDRESS);
  Wire.write(0xE3);
  Wire.endTransmission();
  delay(100);

  Wire.requestFrom(ADDRESS,2);
  if(Wire.available()) {
    valMSB = Wire.read();
  }
  if(Wire.available()) {
    valLSB = Wire.read();
  }

  valLSB &= ~0x0003;
  unsigned int val = valMSB << 8 | valLSB;
  return val;
}

unsigned int measure_RH() {
  // start a humidity measurement (hold master)
  byte valMSB = 0;
  byte valLSB = 0;
  Wire.beginTransmission(ADDRESS);
  Wire.write(0xE5);
  Wire.endTransmission();
  delay(100);

  Wire.requestFrom(ADDRESS,2);
  if(Wire.available()) {
    valMSB = Wire.read();
  }
  if(Wire.available()) {
    valLSB = Wire.read();
  }

  valLSB &= ~0x0003;
  unsigned int val = valMSB << 8 | valLSB;
  return val;
}



