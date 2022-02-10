Slider lightness = create_slider("BLACK/WHITE BORDER", 10, 240, 127);
Switch dither = create_switch("DITHERING", false);
Switch invert_colors = create_switch("INVERT COLORS", false);
Switch display_settings = create_switch("DISPLAY", true);
Slider chars_per_line = create_slider("CHARACTERS PER LINE", 3, 300, 40);
Slider scroll = create_slider("SCROLL", 0, 1, 0);
ImagePicker mainImage = create_image_picker("IMAGE");

char byte_to_braille(int b){
  return char(10240 + max(b, 1));
}

String dots_to_string(float[][] dots){
  int height = dots.length;
      int width = dots[0].length;
      
      String brailleString = "";
      for (int y = 0; y < height/4; y++){
        for (int x = 0; x < width/2; x++){
          int bit = 0, char_code = 0;
     
          
          for (int dot_x = 0; dot_x < 2; dot_x++)
            for (int dot_y = 0; dot_y < 4; dot_y++, bit += 1)
              char_code += (dots[y*4+dot_y][x*2+dot_x] == 255 ? bit_order[bit] : 0);
              
         brailleString += byte_to_braille(char_code);
        }
        brailleString += ' ';
      }
   return brailleString;
}

int[] bit_order = {1, 2, 4, 64, 8, 16, 32, 128};
class SaveButton implements ClickHandler {
  public void click(){
    if (result != null){
      saveStrings("result.txt", split(dots_to_string(result), ' '));
    }
  }
}

class ProcessAllImagesButton implements ClickHandler {
  public void click(){
    java.io.File folder = new java.io.File(sketchPath("images"));
    String[] filenames = folder.list();
    
    String result = "";
    for (String filename : filenames){
       PImage img = loadImage("images\\"+filename); 
       image_to_box(img, Settings.width, Settings.height);
       String converted_image = dots_to_string(image_to_dots(img));
       result += "   " + converted_image;
    }
      
    saveStrings("compiled_images.txt", split(result, ' '));
  }
}

class SaveAsImageButton implements ClickHandler {
  public void click(){
    if (result == null)
      return;
      
    PImage img = new PImage(result[0].length, result.length);
    for (int y = 0; y < img.height; y++)
      for (int x = 0; x < img.width; x++){
         float cl = result[y][x];
         img.set(x, y, color(cl, cl, cl));
      }
    img.save(sketchPath("result_image.png"));
  }
}

float[] error_distribution = {1, 0, 7.0/16,
                              0, 1, 5.0/16,
                              1, 1, 1.0/16,
                              -1,1, 3.0/16};
void add_error(float[][] dots, int width, int height, float _x, float _y, float error){
   int x = (int)_x, y = (int)_y;
   if (0 <= x && x < width && 0 <= y && y < height)
     dots[y][x] += error;
}

void setup(){
  File f = new File(sketchPath("images"));
  f.mkdir();

  smooth(0);
  surface.setSize(Settings.width + Settings.clickable_width, Settings.height);
  surface.setLocation(300, 150);
  create_button("Save", new SaveButton());
  create_button("Save as image", new SaveAsImageButton());
  create_button("Compile images", new ProcessAllImagesButton());
}

float[] x_shifts = {1.5 / 10, 5.5 / 10};
float[] y_shifts = {1.0 / 18, 4.5 / 18, 8.0 / 18, 11.5 / 18};
float[][] result;

float getColor(PImage img, int x, int y){
  int cl = (x < img.width && y < img.height ? img.get(x, y) : color(0, 0, 0));
  float r = red(cl), g = green(cl), b = blue(cl);
  return 0.299 * r + 0.587 * g + 0.114 * b;
}

int to_black_and_white(float cl){
  return (cl < lightness.value ? 0 : 255);
}

void image_to_dots_and_show(PImage img){
  img = img.copy();
  
  if (invert_colors.value){
    for (int y = 0; y < img.height; y++)
      for (int x = 0; x < img.width; x++){
         int cl = img.get(x, y);
         float r = red(cl), g = green(cl), b = blue(cl);
         img.set(x, y, color(255-r, 255-g, 255-b));
      }
  }
  
  int chars_in_line = (int)chars_per_line.value;
  float width_per_char = ((float)img.width / chars_in_line);
  float height_per_char = (1.8 * width_per_char);
  int chars_in_column = (int)(img.height / height_per_char);
  
  int dots_height = (int)(chars_in_column*4);
  int dots_width = (int)(chars_in_line*2);
  float[][] dots = new float[dots_height][dots_width];
  
  for (int char_x = 0; char_x < chars_in_line; char_x++)
    for (int char_y = 0; char_y < chars_in_column; char_y++)
      for (int x_shift_i = 0; x_shift_i < 2; x_shift_i++)
        for (int y_shift_i = 0; y_shift_i < 4; y_shift_i++){
          float x_coord = (char_x + x_shifts[x_shift_i]) * width_per_char;
          float y_coord = (char_y + y_shifts[y_shift_i]) * height_per_char;
          
          dots[char_y*4 + y_shift_i][char_x*2 + x_shift_i] = getColor(img, (int)x_coord, (int)y_coord);
        }
  
  for (int y = 0; y < dots_height; y++)
    for (int x = 0; x < dots_width; x++){
      int cl = to_black_and_white(dots[y][x]);
      float error = dots[y][x] - cl;
      dots[y][x] = cl;
      
      if (dither.value){
        for (int i = 0; i < error_distribution.length; i += 3)
          add_error(dots, dots_width, dots_height, x+error_distribution[i], y+error_distribution[i+1], error_distribution[i+2] * error);
      }
    }
  
  PImage resultImage;
  
  if (display_settings.value){
    resultImage = new PImage(800, 800);
    
    for (int char_x = 0; char_x < chars_in_line; char_x++)
      for (int char_y = 0; char_y < chars_in_column; char_y++)
        for (int x_shift_i = 0; x_shift_i < 2; x_shift_i++)
          for (int y_shift_i = 0; y_shift_i < 4; y_shift_i++){
            float x_coord = (char_x + x_shifts[x_shift_i]) * width_per_char;
            float y_coord = (char_y + y_shifts[y_shift_i]) * height_per_char;
            
            float cl = dots[char_y*4 + y_shift_i][char_x*2 + x_shift_i];
            
            int colr = color(cl, cl, cl);
            resultImage.set((int)x_coord, (int)y_coord, colr);
          }
          
     image(resultImage, Settings.clickable_width, 0);
   } else {
     resultImage = new PImage(dots[0].length, dots.length);
     
      for (int i = 0; i < dots.length; i++)
        for (int j = 0; j < dots[i].length; j++){
          float cl = dots[i][j];
          resultImage.set(j, i, color(cl, cl, cl));
        }     
      image(resultImage, Settings.clickable_width, scroll.value * -max(0, resultImage.height - Settings.height));
   }
        
   result = dots;
}

float[][] image_to_dots(PImage img){
  img = img.copy();
  
  if (invert_colors.value){
    for (int y = 0; y < img.height; y++)
      for (int x = 0; x < img.width; x++){
         int cl = img.get(x, y);
         float r = red(cl), g = green(cl), b = blue(cl);
         img.set(x, y, color(255-r, 255-g, 255-b));
      }
  }
  
  int chars_in_line = (int)chars_per_line.value;
  float width_per_char = ((float)img.width / chars_in_line);
  float height_per_char = (1.8 * width_per_char);
  int chars_in_column = (int)(img.height / height_per_char);
  
  int dots_height = (int)(chars_in_column*4);
  int dots_width = (int)(chars_in_line*2);
  float[][] dots = new float[dots_height][dots_width];
  
  for (int char_x = 0; char_x < chars_in_line; char_x++)
    for (int char_y = 0; char_y < chars_in_column; char_y++)
      for (int x_shift_i = 0; x_shift_i < 2; x_shift_i++)
        for (int y_shift_i = 0; y_shift_i < 4; y_shift_i++){
          float x_coord = (char_x + x_shifts[x_shift_i]) * width_per_char;
          float y_coord = (char_y + y_shifts[y_shift_i]) * height_per_char;
          
          dots[char_y*4 + y_shift_i][char_x*2 + x_shift_i] = getColor(img, (int)x_coord, (int)y_coord);
        }
  
  for (int y = 0; y < dots_height; y++)
    for (int x = 0; x < dots_width; x++){
      int cl = to_black_and_white(dots[y][x]);
      float error = dots[y][x] - cl;
      dots[y][x] = cl;
      
      if (dither.value){
        for (int i = 0; i < error_distribution.length; i += 3)
          add_error(dots, dots_width, dots_height, x+error_distribution[i], y+error_distribution[i+1], error_distribution[i+2] * error);
      }
    }
        
   return dots;
}

void draw(){  
  if (!Clickable.has_anybody_changed())
    return;
    
  Clickable.resolve_update_everybody();
  
  clearWindow(0, 0, 0);
  Clickable.draw_everybody();
  
  if (!mainImage.is_choosed())
    return;
    
  image_to_dots_and_show(mainImage.value);
}

void mousePressed(){
  Clickable.click_everybody(mouseX, mouseY); 
}

void mouseDragged(){
  Clickable.drag_everybody(mouseX, mouseY); 
}

void mouseReleased(){
  Clickable.release_everybody(mouseX, mouseY); 
}
