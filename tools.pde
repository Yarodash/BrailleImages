public class Lock{
  private boolean isLocked = false;

  public synchronized void lock()
  throws InterruptedException{
    while(isLocked){
      wait();
    }
    isLocked = true;
  }

  public synchronized void unlock(){
    isLocked = false;
    notify();
  }
}

void clearWindow(int cl){
  strokeWeight(0);
  fill(cl);
  rect(-1, -1, width+3, height+3);
}

void clearWindow(float r, float g, float b){
  clearWindow(color(r, g, b));
}

void image_to_box(PImage img, int width, int height){
  if (img.width > width){
    img.resize(width, (int)(width * ((float)img.height / img.width))); 
  }
  
  if (img.height > height){
    img.resize((int)(height * ((float)img.width / img.height)), height);
  }
}
