#define MOTOR_SLEEP D6    // stepper motor enable, active low

#define X_DIR D3 // stepper motor X direction control
#define Y_DIR D4 // stepper motor Y direction control
#define Z_DIR D5 // stepper motor Z direction control
#define A_DIR D6 // stepper motor A direction control
#define X_STP D0 // X stepper control
#define Y_STP D1 // Y stepper control
#define Z_STP D2 // Z stepper control
#define A_STP D3 // A stepper control

// 5ml = 2200 steps with delay = 300

void setup() {
  Serial.begin(9600);

  Serial.println("Booting");

  // Configure pins
  pinMode(X_DIR, OUTPUT);
  pinMode(X_STP, OUTPUT);
  pinMode(Y_DIR, OUTPUT);
  pinMode(Y_STP, OUTPUT);
  pinMode(Z_DIR, OUTPUT);
  pinMode(Z_STP, OUTPUT);
  pinMode(MOTOR_SLEEP, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);

  // Put motors to sleep
  digitalWrite(MOTOR_SLEEP, HIGH);

  // Set all motors in forward mode
  digitalWrite(X_DIR, false);
  digitalWrite(Y_DIR, false);
  digitalWrite(Z_DIR, false);

  // Ready to go
  Serial.println("Waiting for instructions:");
}

// Global state
bool motorsIsAwake = false;
int motorXSteps = 0;
int motorYSteps = 0;
int motorZSteps = 0;
int motorASteps = 0;
int motorStepDelay = 440;

void handleSerial() {
  if (Serial.available() != 0) {
    String inputStr = Serial.readString(); // read until timeout
    inputStr.trim();                       // remove any \r \n whitespace at the end of the String

    if (inputStr.equals("STOP")) {
      motorXSteps = 0;
      motorYSteps = 0;
      motorZSteps = 0;
      motorASteps = 0;
      Serial.println("STOP");
    } else if (inputStr.startsWith("X")) {
      motorXSteps = inputStr.substring(1).toInt();
      Serial.println("X" + String(motorXSteps));
    } else if (inputStr.startsWith("Y")) {
      motorYSteps = inputStr.substring(1).toInt();
      Serial.println("Y" + String(motorYSteps));
    } else if (inputStr.startsWith("Z")) {
      motorZSteps = inputStr.substring(1).toInt();
      Serial.println("Z" + String(motorZSteps));
    } else if (inputStr.startsWith("A")) {
      motorASteps = inputStr.substring(1).toInt();
      Serial.println("A" + String(motorASteps));
    } else if (inputStr.startsWith("MSD")) {
      motorStepDelay = inputStr.substring(3).toInt();
      Serial.println("MSD" + String(motorStepDelay));
    } else {
      Serial.println("Unknown command: " + inputStr);
    }
  }
}

void loop() {
  handleSerial();

  if (motorXSteps + motorYSteps + motorZSteps + motorASteps == 0) {
    if (motorsIsAwake) {
      Serial.println("Put motors to sleep");
      digitalWrite(MOTOR_SLEEP, HIGH);
      motorsIsAwake = false;
    }
  } else {
    if (!motorsIsAwake) {
      Serial.println("Wake motors from sleep");
      digitalWrite(MOTOR_SLEEP, LOW);
      motorsIsAwake = true;
    }
  }

  for (int i = 0; i < 100; i++) {
    if (motorXSteps > 0) {
      digitalWrite(X_STP, HIGH);
    }

    if (motorYSteps > 0) {
      digitalWrite(Y_STP, HIGH);
    }

    if (motorZSteps > 0) {
      digitalWrite(Z_STP, HIGH);
    }

    if (motorASteps > 0) {
      digitalWrite(A_STP, HIGH);
    }

    delayMicroseconds(motorStepDelay);

    if (motorXSteps > 0) {
      digitalWrite(X_STP, LOW);
      motorXSteps -= 1;
    }

    if (motorYSteps > 0) {
      digitalWrite(Y_STP, LOW);
      motorYSteps -= 1;
    }

    if (motorZSteps > 0) {
      digitalWrite(Z_STP, LOW);
      motorZSteps -= 1;
    }

    if (motorASteps > 0) {
      digitalWrite(A_STP, LOW);
      motorASteps -= 1;
    }

    delayMicroseconds(motorStepDelay);
  }
}
