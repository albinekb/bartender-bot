// #define EN 8    // stepper motor enable, active low
// #define X_DIR 5 // X-axis stepper motor direction control
// #define Y_DIR 6 // Y-axis stepper motor direction control
// #define Z_DIR 7 // Z-axis stepper motor direction control
// #define X_STP 2 // X-axis stepper control
// #define Y_STP 3 // Y-axis stepper control
// #define Z_STP 4 // Z-axis stepper control

#ifndef STASSID
#define STASSID "dlink-4034-2_4GHz" // set your SSID
#define STAPSK "dmhwv39388"         // set your wifi password
#endif

#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>

#define EN D6    // stepper motor enable, active low
#define X_DIR D3 // X-axis stepper motor direction control
#define Y_DIR D4 // Y-axis stepper motor direction control
#define Z_DIR D5 // Z-axis stepper motor direction control
#define X_STP D0 // X-axis stepper control
#define Y_STP D1 // Y-axis stepper control
#define Z_STP D2 // Z-axis stepper control

void setup()
{

  Serial.begin(9600);

  WiFi.mode(WIFI_STA);
  WiFi.begin(STASSID, STAPSK);

  while (WiFi.waitForConnectResult() != WL_CONNECTED)
  {
    Serial.println("Connection Failed! Rebooting...");
    delay(5000);
    ESP.restart();
  }

  Serial.println("Booting");

  ArduinoOTA.onStart([]()
                     { Serial.println("Start"); });
  ArduinoOTA.onEnd([]()
                   { Serial.println("\nEnd"); });
  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total)
                        { Serial.printf("Progress: %u%%\r", (progress / (total / 100))); });
  ArduinoOTA.onError([](ota_error_t error)
                     {
    Serial.printf("Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) Serial.println("Auth Failed");
    else if (error == OTA_BEGIN_ERROR) Serial.println("Begin Failed");
    else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
    else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
    else if (error == OTA_END_ERROR) Serial.println("End Failed"); });

  // the stepping motor used in the O pin is set to output
  pinMode(X_DIR, OUTPUT);
  pinMode(X_STP, OUTPUT);
  pinMode(Y_DIR, OUTPUT);
  pinMode(Y_STP, OUTPUT);
  pinMode(Z_DIR, OUTPUT);
  pinMode(Z_STP, OUTPUT);
  pinMode(EN, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);

  ArduinoOTA.begin();
  Serial.println("Ready");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void enableMotors()
{
  pinMode(EN, OUTPUT);
  digitalWrite(EN, LOW); // Depending on your motor drivers, this could be HIGH for enabling.
}

void disableMotors()
{
  digitalWrite(EN, HIGH); // Depending on your motor drivers, this could be LOW for disabling.
}

/*
Function: step function: to control the stepper motor direction, the number of steps.
Parameters: dir direction control, dirPin DIR pin corresponding to the stepper motor, stepperPin step pin corresponding to the stepper motor, stepping a few steps steps
No return value
*/
void step(boolean dir, byte dirPin, byte stepperPin, int steps, int sp)
{
  digitalWrite(dirPin, dir);
  delay(10);

  for (int i = 0; i < steps; i++)
  {
    digitalWrite(stepperPin, HIGH);
    delayMicroseconds(sp);
    digitalWrite(stepperPin, LOW);
    delayMicroseconds(sp);
  }
}

String strs[20];
int StringCount = 0;
void handleSerial()
{
  Serial.println("Waiting for instructions:");
  while (Serial.available() == 0)
  {
  }                                      // wait for data available
  String inputStr = Serial.readString(); // read until timeout
  inputStr.trim();                       // remove any \r \n whitespace at the end of the String

  while (inputStr.length() > 0)
  {
    int index = inputStr.indexOf(' ');
    if (index == -1) // No space found
    {
      strs[StringCount++] = inputStr;
      break;
    }
    else
    {
      strs[StringCount++] = inputStr.substring(0, index);
      inputStr = inputStr.substring(index + 1);
    }
  }

  for (int i = 0; i < StringCount; i++)
  {
    Serial.print(i);
    Serial.print(": \"");
    Serial.print(strs[i]);
    Serial.println("\"");
  }
}

void loop()
{
  ArduinoOTA.handle();
  // handleSerial();

  enableMotors();
  //
  step(false, Y_DIR, Y_STP, 5000, 130);
  disableMotors();
  delay(20);
}
