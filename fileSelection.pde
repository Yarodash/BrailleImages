String file_selection_result;
Lock file_selection_lock;

synchronized String select_file(){
  file_selection_lock = new Lock();
  try {
    file_selection_lock.lock();
  } catch (InterruptedException e) {}
  
  selectInput("Select file:", "fileSelected");
  
  try {
    file_selection_lock.lock();
  } catch (InterruptedException e) {}
  
  file_selection_lock.unlock();
  return file_selection_result;
}

void fileSelected(File selection) {
    if (selection == null) {
      file_selection_result = null;
    } else {
      file_selection_result = selection.getAbsolutePath();
    }
    file_selection_lock.unlock();
  }
