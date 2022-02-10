abstract static class Clickable{
  static ArrayList<Clickable> clickables = new ArrayList<Clickable>();
  int x, y, width, height;
  boolean updated;
  
  Clickable(int x, int y, int width, int height){
    clickables.add(this);
    
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    updated = true;
  }
  
  boolean in_bounds(int cursorX, int cursorY){
    return (x <= cursorX && cursorX < x + width && y <= cursorY && cursorY < y + height);
  }
  
  void update(){
     this.updated = true; 
  }
  
  void resolve_update(){
     this.updated = false; 
  }
  
  void click(int cursorX, int cursorY){
    if (!in_bounds(cursorX, cursorY))
      return;
      
    update();
    click_handler(cursorX - x, cursorY - y);
  }
  
  void drag(int cursorX, int cursorY){
    if (!in_bounds(cursorX, cursorY))
      return;
    
    update();
    drag_handler(cursorX, cursorY);
  }
  
  void release(int cursorX, int cursorY){
    if (!in_bounds(cursorX, cursorY))
      return;
    
    update();
    release_handler(cursorX, cursorY);
  }
  
  void draw(){};
  abstract void click_handler(int cursorX, int cursorY);
  void drag_handler(int cursorX, int cursorY){};
  void release_handler(int cursorX, int cursorY){};
  
  static void click_everybody(int cursorX, int cursorY){
    for (Clickable c : clickables)
      c.click(cursorX, cursorY);
  }
  
  static void drag_everybody(int cursorX, int cursorY){
    for (Clickable c : clickables)
      c.drag(cursorX, cursorY);
  }
  
  static void release_everybody(int cursorX, int cursorY){
    for (Clickable c : clickables)
      c.release(cursorX, cursorY);
  }
  
  static void draw_everybody(){
    for (Clickable c : clickables)
      c.draw();
  }
  
  static void resolve_update_everybody(){
    for (Clickable c : clickables)
      c.resolve_update();
  }
  
  static boolean has_anybody_changed(){
     for (Clickable c : clickables)
       if (c.updated)
         return true;
        
     return false;
  }
}
