//-----------------------------------------------------------------------------
//class InputManager
//Checks the first 256 ASCII coded keys for a key press
//If any of those keys are pressed, the array with index of the key's ASCII code will be true.
//If a key is not pressed, the array at the index of the key's ASCII code will be false. 
//Call inputManagerObject.recordKeyPress(keyCode); inside of the keyPressed event listener
//Call inputManagerObject.recordKeyRelease(keyCode); inside of the keyReleased event listener
//To check if a key is pressed, create an instance of this class in the main program.
//Call the isKeyPressed() function on this InputManager object, passing in the integer value or character of the key 
//For example, if (inputManagerObject.isKeyPressed(32)) { ... } checks if the space bar is pressed
//Processing will inplicitly cast a character to an integer. 
//-----------------------------------------------------------------------------
class InputManager {
  boolean[] keys;

  InputManager() {
    keys = new boolean[256];
  }

  void recordKeyPress(int k) {
    keys[k] = true;
  }

  void recordKeyRelease(int k) {
    keys[k] = false;
  }

  boolean isKeyPressed(int k) {
    return keys[k];
  }

  boolean isKeyReleased(int k) {
    return !keys[k];
  }
}