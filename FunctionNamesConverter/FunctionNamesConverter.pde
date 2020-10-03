String prefix = "\\\\b(";
String suffix = ")\\\\b";

String url = "https://raw.githubusercontent.com/gnembon/fabric-carpet/master/docs/scarpet/resources/editors/idea/";
//\\b(return|yield|break|case|continue|default|do|while|for|switch|if|else)\\b
ArrayList<String> functions = new ArrayList();
String[] ignore = {"true","false","null","pi","euler"};
int file = 1;

String regex = prefix;

void setup() {
  while(true) {
    String[] f = loadStrings(getFileName(file));
    if(f == null) break;
    for(int i = 0; i < f.length; i++) {
      boolean ignored = false;
      for(int j = 0; j < ignore.length; j++) {
        if(f[i].equals(ignore[j])) {
          println(f[i] + " == " + ignore[j]);
          ignored = true;
        } else {
          println(f[i] + " != " + ignore[j]);
        }
      }
      if(!ignored) {
        functions.add(f[i]);
      }
    }
    file++;
  }
  for(int i = 0; i < functions.size(); i++) {
    regex = regex + functions.get(i) + "|";
  }
  regex = regex.substring(0,regex.length()-1) + suffix;
  String[] regFile = new String[1];
  regFile[0] = regex;
  saveStrings("regex.txt",regFile);
  println(regex);
}





String getFileName(int index) {
  return url + str(index) + ".txt";
}
