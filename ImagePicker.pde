class ImagePicker extends Clickable {
  PImage value;
  String display_name;
  String image_destination;
  Object locker;
  
  ImagePicker(int x, int y, int width, int height, String display_name){
    super(x, y, width, height);
    this.display_name = display_name;
    this.locker = new Object();
  }
  
  void click_handler(int cursorX, int cursorY){
    synchronized (locker) {
      image_destination = select_file();
      if (image_destination == null)
        return;
         
      value = loadImage(image_destination);
      image_to_box(value, Settings.width, Settings.height);
    }
  }
  
  boolean is_choosed(){
    return (value != null);
  }
  
  public void draw(){
     strokeWeight(1);
     
     stroke(0, 0, 0);
     
     if (value != null) fill(90, 255, 90);
     else               fill(255, 90, 90);
     rect(x, y, width, height);

     String image_name = "None";
     if (image_destination != null){
        String[] temp = split(image_destination, '\\');
        image_name = temp[temp.length-1];
     }

     fill(0, 0, 0);
     textSize(13);
     text(display_name+":\n"+image_name, x+10, y+height-23);
   }
}

ImagePicker create_image_picker(String display_name){
  return new ImagePicker(0, Clickable.clickables.size()*Settings.clickable_height,
                    Settings.clickable_width, Settings.clickable_height,
                    display_name);
}
