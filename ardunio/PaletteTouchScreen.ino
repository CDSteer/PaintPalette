/*************************************************** 
  This is an example for the Adafruit STMPE610 Resistive
  touch screen controller breakout
  ----> http://www.adafruit.com/products/1571
 
  Check out the links above for our tutorials and wiring diagrams
  These breakouts use SPI or I2C to communicate

  Adafruit invests time and resources providing this open source code,
  please support Adafruit and open-source hardware by purchasing
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.
  MIT license, all text above must be included in any redistribution
 ****************************************************/

#include <SPI.h>
#include <Wire.h>

#include "Adafruit_STMPE610.h"
#include <SPI.h>
#include "Adafruit_BLE_UART.h"

// Pick one of three wiring options below!

// Option #1 - uses I2C, connect to hardware I2C port only!
// SCL to I2C clock (#A5 on Uno) and SDA to I2C data (#A4 on Uno)
// tie MODE to GND and POWER CYCLE (there is no reset pin)
Adafruit_STMPE610 touch = Adafruit_STMPE610();

// Option #2 - use hardware SPI, connect to hardware SPI port only!
// SDI to MOSI, SDO to MISO, and SCL to SPI CLOCK
// on Arduino Uno, that's 11, 12 and 13 respectively
// Then pick a CS pin, any pin is OK but we suggest #10 on an Uno
// tie MODE to 3.3V and POWER CYCLE the STMPE610 (there is no reset pin)

// Adafruit_STMPE610 touch = Adafruit_STMPE610(STMPE_CS);

// Option #3 - use software SPI, connect to *any* 4 I/O pins!
// define the following pins to whatever 4 you want and wire up!
// Tie MODE to 3.3V and POWER CYCLE the STMPE610 (there is no reset pin)
// Adafruit_STMPE610 touch = Adafruit_STMPE610(STMPE_CS, STMPE_SDI, STMPE_SDO, STMPE_SCK);

/******************/



// Connect CLK/MISO/MOSI to hardware SPI
// e.g. On UNO & compatible: CLK = 13, MISO = 12, MOSI = 11
#define ADAFRUITBLE_REQ 10
#define ADAFRUITBLE_RDY 2     // This should be an interrupt pin, on Uno thats #2 or #3
#define ADAFRUITBLE_RST 9

Adafruit_BLE_UART BTLEserial = Adafruit_BLE_UART(ADAFRUITBLE_REQ, ADAFRUITBLE_RDY, ADAFRUITBLE_RST);
/**************************************************************************/
/*!
    Configure the Arduino and start advertising with the radio
*/
/**************************************************************************/

String valueStr, strD08;

void setup() { 
  Serial.begin(9600);
  Serial.println("Adafruit STMPE610 example");
  Serial.flush();

  // if using hardware SPI on an Uno #10 must be an output, remove line
  // if using software SPI or I2C
  pinMode(10, OUTPUT);

  // If using I2C you can select the I2C address (there are two options) by calling
  // touch.begin(0x41), the default, or touch.begin(0x44) if A0 is tied to 3.3V
  // If no address is passed, 0x41 is used
  if (! touch.begin()) {
    Serial.println("STMPE not found!");
    while(1);
  }
  Serial.println("Waiting for touch sense");

  while(!Serial); // Leonardo/Micro should wait for serial init
  Serial.println(F("Adafruit Bluefruit Low Energy nRF8001 Print echo demo"));

  // BTLEserial.setDeviceName("NEWNAME"); /* 7 characters max! */
  valueStr = "value here";
  strD08 = "D08: ";

  BTLEserial.begin();
}

/**************************************************************************/
/*!
    Constantly checks for new events on the nRF8001
*/
/**************************************************************************/
aci_evt_opcode_t laststatus = ACI_EVT_DISCONNECTED;
TS_Point p;
void loop() {
  uint16_t x, y;
  uint8_t z;
  if (touch.touched()) {
    // read x & y & z;
    while (! touch.bufferEmpty()) {
      Serial.print(touch.bufferSize());
      touch.readData(&x, &y, &z);
//      Serial.print("->("); 
//      Serial.print(x); Serial.print(", "); 
//      Serial.print(y); Serial.print(", "); 
//      Serial.print(z);
//      Serial.println(")");
      p = touch.getPoint();
      p.x = map(p.x, 100, 4000, 0, 40);
      p.y = map(p.y, 100, 4000, 0, 40);
      p.z = map(p.z, 255, 0, 0, 255);

      Serial.print("->("); 
      Serial.print(p.x); Serial.print(", "); 
      Serial.print(p.y); Serial.print(", "); 
      Serial.print(p.z); 
      Serial.println(")");
      
    }
    touch.writeRegister8(STMPE_INT_STA, 0xFF); // reset all ints

    
  }
  delay(10);

    // Tell the nRF8001 to do whatever it should be working on.
  BTLEserial.pollACI();

  // Ask what is our current status
  aci_evt_opcode_t status = BTLEserial.getState();
  // If the status changed....
  if (status != laststatus) {
    // print it out!
    if (status == ACI_EVT_DEVICE_STARTED) {
        Serial.println(F("* Advertising started"));
    }
    if (status == ACI_EVT_CONNECTED) {
        Serial.println(F("* Connected!"));
    }
    if (status == ACI_EVT_DISCONNECTED) {
        Serial.println(F("* Disconnected or advertising timed out"));
    }
    // OK set the last status change to this one
    laststatus = status;
  }

  if (status == ACI_EVT_CONNECTED) {
    /*********************    READ   ***********************************/
    // Lets see if there's any data for us!
    bool printEnd = false;
    if (BTLEserial.available()) {
      printEnd = true;
      Serial.print("* "); Serial.print("\n* Recieved -> \"");
    }
    // OK while we still have something to read, get a character and print it out
    while (BTLEserial.available()) {
      char c = BTLEserial.read();
      Serial.print(c);
    }
    if(printEnd) {
      Serial.println("\"");
    }
    /********************************************************************/

    
    /*********************    WRITE   ***********************************/
    // Next up, see if we have any data to get from the Serial console
    int valD08 = digitalRead(8);
    valueStr = strD08 + valD08;
    
    uint8_t sendbuffer[20];
    valueStr.getBytes(sendbuffer, 20);
    
    String s = String(p.x);
    s.concat(String(';'));
    s.concat(String(p.y));
    s.concat(String(';'));
    s.concat(String(p.z));
    s.getBytes(sendbuffer, 20);
    char sendbuffersize = min(20, s.length());

    Serial.print(F("\n* Sending -> \"")); Serial.print((char *)sendbuffer); Serial.println("\"");
    BTLEserial.write(sendbuffer, sendbuffersize);
    
//    if (Serial.available()) {
//      // Read a line from Serial
//      Serial.setTimeout(100); // 100 millisecond timeout
//      String s = Serial.readString();
//
//      // We need to convert the line to bytes, no more than 20 at this time
//      uint8_t sendbuffer[20];
//      s.getBytes(sendbuffer, 20);
//      char sendbuffersize = min(20, s.length());
//
//      Serial.print(F("\n* Sending -> \"")); Serial.print((char *)sendbuffer); Serial.println("\"");
//
//      // write the data
//      BTLEserial.write(sendbuffer, sendbuffersize);
//    }
    /********************************************************************/
  }
}

