class Button extends Clickable {
  String display_name;
  ClickHandler click_handler;
  
  Button(int x, int y, int width, int height, String display_name, ClickHandler click_handler){
    super(x, y, width, height);
    this.display_name = display_name;
    this.click_handler = click_handler;
  }
  
  void click_handler(int cursorX, int cursorY){
    this.click_handler.click();
  }
  
  public void draw(){
     strokeWeight(1);
     
     stroke(0, 0, 0);
     fill(0, 100, 255);
     rect(x, y, width, height);

     fill(0, 0, 0);
     textSize(13);
     text(display_name, x+10, y+height-23);
   }
}

Button create_button(String display_name, ClickHandler click_handler){
  return new Button(0, Clickable.clickables.size()*Settings.clickable_height,
                    Settings.clickable_width, Settings.clickable_height,
                    display_name, click_handler);
}
