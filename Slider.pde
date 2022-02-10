class Slider extends Clickable {
  float left_value, right_value, value;
  String display_name;
  
  Slider(int x, int y, int width, int height, String display_name, float left_value, float right_value, float initial_value){
    super(x, y, width, height);
    this.display_name = display_name;
    this.left_value = left_value;
    this.right_value = right_value;
    this.value = initial_value;
  }
  
  void click_handler(int cursorX, int cursorY){
    value = left_value + (float)((right_value - left_value)) * ((float)cursorX / (width - 1));
  }
  
  void drag_handler(int cursorX, int cursorY) { click_handler(cursorX, cursorY); }
  void release_handler(int cursorX, int cursorY) { click_handler(cursorX, cursorY); }
  
  public void draw(){
     strokeWeight(1);
     
     stroke(0, 0, 0);
     fill(255, 0, 0);
     rect(x, y, width, height);
     
     int t = (int)(width * (value - left_value) / (right_value - left_value));
     fill(0, 255, 0);
     rect(x, y, t, height);
     
     fill(0, 0, 0);
     textSize(13);
     text(display_name+":\n"+value, x+10, y+height-23);
   }
}

Slider create_slider(String display_name, float left_value, float right_value, float initial_value){
  return new Slider(0, Clickable.clickables.size()*Settings.clickable_height,
                    Settings.clickable_width, Settings.clickable_height,
                    display_name, left_value, right_value, initial_value);
}
