// include the library code:
#include <LiquidCrystal.h>
#include <Wire.h>

//%%%%%% TEMPURATURE + HUMIDITY VARIABLES%%%%
#define ADDRESS (0x8 << 3)
//%%%%%% Serial_Variables %%%%%%%

const int baudrate = 9600;
const int buffersize = 25; // Maximum word size of messages sent to arduino. ie: 25 letter messages at max if buffersize = 25

LiquidCrystal lcd(6, 7, 5, 4, 3, 2);

char message[buffersize];

void setup() {
  //%%%%%% TEMPURATURE + HUMIDITY VARIABLES %%%%%%
  Wire.begin(ADDRESS);
  //%%%%%% Serial_Variables %%%%%%
  lcd.begin(16, 2);
  lcd.setCursor(2,0);
  lcd.print("Ready ...");
  Serial.begin(baudrate); // baud rate was originally 115200
  Serial.flush();
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


void serial_read(char temp2[]) // Reads the serial data and stores it in the array pointer temp2
{
  char temp[buffersize+1];
  int length = 0; 
  empty(temp2);

  for (int k = 0; Serial.available() > 0; k++)
  {
    temp[k] = Serial.read();
    length++;
    delay(10); // Delay to compensate for slow serial
  }          

  for (int j = 0; j < (length-1); j++) // gets rid of the last char of the temp array and puts it into mess
  {
    temp2[j] = temp[j];
  }
  Serial.flush();
}


void empty(char array[]) // Emptys the "message" array. ie: fills it with blank values
{
  for (int i = 0; i < buffersize; i++){
    array[i] = ' '; 
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
  Wire.send(0xE3);
  Wire.endTransmission();
  delay(100);

  Wire.requestFrom(ADDRESS,2);
  if(Wire.available()) {
    valMSB = Wire.receive();
  }
  if(Wire.available()) {
    valLSB = Wire.receive();
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
  Wire.send(0xE5);
  Wire.endTransmission();
  delay(100);

  Wire.requestFrom(ADDRESS,2);
  if(Wire.available()) {
    valMSB = Wire.receive();
  }
  if(Wire.available()) {
    valLSB = Wire.receive();
  }

  valLSB &= ~0x0003;
  unsigned int val = valMSB << 8 | valLSB;
  return val;
}



