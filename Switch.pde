class Switch extends Clickable {
  boolean value;
  String display_name;
  
  Switch(int x, int y, int width, int height, String display_name, boolean initial_value){
    super(x, y, width, height);
    this.display_name = display_name;
    this.value = initial_value;
  }
  
  void click_handler(int cursorX, int cursorY){
    value ^= true;
  }
  
  public void draw(){
     strokeWeight(1);
     
     stroke(0, 0, 0);
     
     if (value) fill(0, 255, 0);
     else       fill(255, 0, 0);
     rect(x, y, width, height);

     fill(0, 0, 0);
     textSize(13);
     text(display_name+":\nTURNED "+(value ? "ON" : "OFF"), x+10, y+height-23);
   }
}

Switch create_switch(String display_name, boolean initial_value){
  return new Switch(0, Clickable.clickables.size()*Settings.clickable_height,
                    Settings.clickable_width, Settings.clickable_height,
                    display_name, initial_value);
}
