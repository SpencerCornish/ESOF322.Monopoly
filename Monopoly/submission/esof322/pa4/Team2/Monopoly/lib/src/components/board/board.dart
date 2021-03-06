import 'dart:html';
import '../tiles/tile.dart';

class Board {
  int x;
  int y;
  List<Tile> tiles;
  int tileWidth;
  int tileHeight;

  Board(String file) {
    tiles = new List<Tile>(40);

    tileWidth = (window.innerWidth - 50) ~/ 11;
    tileWidth = tileWidth * 10 ~/ 11; //leave room on left side for buttons
    tileHeight = (window.innerHeight - 50) ~/ 11;

    x = (window.innerWidth / 2 - tileWidth * 5).toInt();
    y = (window.innerHeight / 2 - tileHeight * 5.5).toInt();

    List<String> spaces = readInfo(file);
    for (int i = 0; i < 10; i++) {
      //loop through each row
      int k = i * 13; //starting index
      List<String> temp = new List<String>(); //temporary strings indicating a single tile attribute list
      for (int j = k; j < k + 13; j++) {
        //loop through the size of a tile and initialize the tile attributes
        temp.add(spaces.elementAt(j));
      }
      k += 130; //iterate the counter for the overall string by a side of the board (bottom to left)
      tiles[i] = new Tile(temp, x + i * tileWidth, y, tileWidth, tileHeight); //create a new tile on bottom
      temp.clear(); //reset the tile attribute list for a new tile

      for (int j = k; j < k + 13; j++) {
        temp.add(spaces.elementAt(j));
      }
      k += 130; //iterate the counter for the overall string by a side of the board (left to top)
      tiles[i + 10] =
          new Tile(temp, 10 * tileWidth + x, y + i * tileHeight, tileWidth, tileHeight); //create a new tile on left
      temp.clear();

      for (int j = k; j < k + 13; j++) {
        temp.add(spaces.elementAt(j));
      }
      k += 130; //iterate the counter for the overall string by a side of the board (top to right)
      tiles[i + 20] = new Tile(
          temp, (10 - i) * tileWidth + x, 10 * tileHeight + y, tileWidth, tileHeight); //create a new tile on top
      temp.clear();

      for (int j = k; j < k + 13; j++) {
        temp.add(spaces.elementAt(j));
      }
      tiles[i + 30] = new Tile(temp, x, (10 - i) * tileHeight + y, tileWidth, tileHeight); //create a new tile on right
    }
  }

  List<String> readInfo(String file) {
    List<String> t = file.split(",");
    return t;
  }
}
