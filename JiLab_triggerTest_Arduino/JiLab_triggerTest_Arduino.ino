/*
CaBMI Ji Lab 
WAL3
d11.21.17
*/

// Define analog pin
int sensorPin = 0;
long count = 0; //how many itterations over thresh
int counter = 0; // total Timeouts
unsigned long previousMillis = 0;        // will store last time LED was updated
const long interval = 1000;


// Setup
void setup() {
 // Init serial
pinMode(10,OUTPUT);
pinMode(7,OUTPUT);
pinMode(5,OUTPUT);
pinMode(13,OUTPUT);

  Serial.begin(9600);
}


// Main loop
void loop() {


// ROI input ( one for now)


   if(Serial.available()>0) // if there is data to read
   {
   int  melody=Serial.read(); // read data


   // send Reward TTL
   if (melody == 99){
   int currentMillis = millis();
    digitalWrite(13, HIGH);
delay(10);
    digitalWrite(13, LOW);
   }
   }
}
