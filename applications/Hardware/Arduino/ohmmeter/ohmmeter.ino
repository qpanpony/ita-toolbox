/*
  Ohmmeter
 Reads the voltage across an unknown resistor, which is in series with a known resistor.
 The returned value is then the unknown resistance (which is always futile).
 */

// serial stuff
const int baudrate = 9600;
const int buffersize = 25; // Maximum word size of messages sent to arduino. ie: 25 letter messages at max if buffersize = 25
char message[buffersize];

// setup stuff
int nMeasure = 10; // number of averages
float nMeasureFloat = nMeasure*1.0;
int delayBetween = 10; // delay between averages
float Vref = 1.1; // reference for input
float Vin = 3.26; // input voltage
float Rshunt = 100.0; // shunt resistance

// the setup routine runs once when you press reset:
void setup() {
  analogReference(INTERNAL); // means 1.1V as Vref
  analogRead(A0); // to dump, first reading is not valid
  // initialize serial communication
  Serial.begin(baudrate);
  Serial.flush();
  delay(200);
}

// the loop routine runs over and over again forever:
void loop() {

  if (Serial.available() > 0) { 
    serial_read(message); // reads the serial message and stores it in the array "message"
    if(message[0] == 'r') {                      // for resistance

      // read the input on analog pin 0:
      int sensorValue = 0; // measured integer value
      for (int idx = 0; idx < nMeasure; idx++) {
        sensorValue += analogRead(A0);
        delay(20);
      }
      // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - Vref):
      float Vm = sensorValue / nMeasureFloat * (Vref / 1023.0); // measured voltage
      float Vrel = (Vin / Vm) - 1.0; // helper variable
      float R = Rshunt / Vrel; // result
      Serial.print(Vm,3);
      Serial.print(",");
      Serial.println(R,3);
    }
    // Serial.println(message);
  } 
  delay(100);
}

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

  for(int j = 0; j < (length-1); j++) // gets rid of the last char of the temp array and puts it into mess
  {
    temp2[j] = temp[j];
  }
  Serial.flush();
  delay(10);
}


void empty(char array[]) // Emptys the "message" array. ie: fills it with blank values
{
  for (int i = 0; i < buffersize; i++){
    array[i] = ' '; 
  }
}



