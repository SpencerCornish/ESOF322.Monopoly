import '../tiles/tile.dart';
import 'dart:math';
import 'dart:html';

import 'package:monopoly/src/components/board/board.dart';


class Player {
  Random rand = new Random();
  Board _board;
  String _name;
  int _number;
  String _color;
  int _size;
  // Token Type: Enum here?
  int _money;
  int _numDoubles = 0;
  int _currentLocation = 0;
  List<Tile> _ownedTiles;
  bool _inJail = false;
  int _rollValue;

  Player(this._name, this._size, this._number, this._color, this._board) {
    _money = 1500;
    _ownedTiles = new List<Tile>();
  }

  //player rolls dice and moves position
  void move(int rollValue) {
    int nextLocation = _currentLocation + _rollValue;

    if (_inJail)
      getOutOfJail();

    {
      if (rollValue == 0) {
        _rollValue = rollDice();

      } else if (rollValue >= 2) {
        _rollValue = rollValue;

      } else {
        print("invalid entry");
      }

      if (nextLocation > 39) {
        //if the player has landed on or passed go
        _currentLocation = nextLocation - 40;
        _money += 200;
      }

      _currentLocation = nextLocation;
      setPosition(nextLocation);

      if (_numDoubles > 0) //if the player rolled doubles move again
        move(rollValue);
    }
  }

  updateMonopoly(Tile tile) {
    List<Tile> count;
    for(Tile curTile in _ownedTiles) {
      if(curTile.color == _color) {
        count.add(curTile);
      }
      if(count.length == tile.totalNum) {
        for (Tile newMonopTile in count)
          newMonopTile.isInMonopoly = true;
      }
      for(Tile curTile in _board.tiles) {
        if(curTile.color == _color) {
          curTile.isInMonopoly = false;
        }
      }
    }
  }

  int rollDice() {
    int die1 = rand.nextInt(6) + 1;
    int die2 = rand.nextInt(6) + 1;

    if (die1 == die2)
      _numDoubles++;
    else
      _numDoubles = 0;

    _rollValue = die1 + die2;
    return _rollValue;
  }

  void buyTile(Tile t) {
    if (t = updateMonopoly(t))
    t.owner = this;
    properties.add(t);
    _money -= t.price;
    //check if all of one color owned by this player
      //if yes inMonop = true for all tiles of said color
      //else false

  }


  void buyBuilding(Tile p, int numHouse) {
    if (p.isInMonopoly) {
      //TODO check that player is building evenly
      //get tiles in monop
      //check num houses on each
      //if num houses same or greater
        //build house
      //else
        //return error message
      if (p.numBuildings < 4) {
        for (int i = 0; i < numHouse; i++) { //build num houses player wants to buy
          _money -= p.buildPrice; //subtract build price
          p.addBuilding(); //add a building count on tile
        }
      } else if (p.numBuildings == 4) { //build hotel
        _money -= p.buildPrice; //subtract build price
        p.addBuilding(); //add a building to count on tile
      } else {
        print("ERROR: Max number of buildings reached. You cannot build anymore on this property");
      }
    }
    else
      print ("ERROR: Property not in a monopoly. you cannont build");
  }

  void sellBuilding(Tile t) {
    t.numBuildings - 1;
    _money += (t.buildPrice / 2).round();
  }

  List<Tile> get properties => _ownedTiles;
  int get money => _money;
  String get name => _name;
  //TODO get token
  int get position => _currentLocation;

  void set name(String n) {
    _name = n;
  }

  void setToken(var token) {
    //TODO
  }

  void setPosition(int spot) {
    _currentLocation = spot;
  }


  void goToJail() {
    _currentLocation = 10;
    _inJail = true;
  }

  void getOutOfJail() {
    int _attempts = 0;
    String _methodToGetOut;
    switch (_methodToGetOut) {
      case 'rolled doubles':
        int roll = rollDice();
        if (_numDoubles > 1) {
          _inJail = false;
          move(roll); //move rolled amount
          move(0); //roll again because doubles
        } else if (_numDoubles < 1) { //after 3 tries paid bail and continue turn
          if (_attempts >= 3) {
            _money -= 50;
            _inJail = false;
            move(roll);
          } else {
            _inJail = true;
            _attempts++;
          }
        }
        else {
          _inJail = true;
          //end turn
        }
        break;
      case 'paid bail':
        _money -= 50;
        _inJail = false;
        move(0);
        break;
    }
  }

  void payRent(Player owner, Player renter, Tile t) {
    int _rent = t.calcRent(_rollValue);
    renter._money -= _rent;
    owner._money += _rent;
    //owner.getPaid(t.calcRent(_rollValue));
  }


  void tradeProperty(Player seller, Player buyer, Tile t, int tradeAmount) {
    this._ownedTiles.remove(t);;
    seller._money += tradeAmount;

    buyer.buyTile(t);
    buyer._money -= tradeAmount;

    if (t.isMortgaged) {
      String _choice;
      switch (_choice) {
        case 'repay mortgage':
          _money -= t.mortgageCost;
          break;
        case 'keep mortgaged':
          _money -= (t.mortgageCost * 0.9).round();
      }
    }
  }

  void draw(CanvasRenderingContext2D ctx){
    //draw player color on board
    ctx.fillStyle = _color;
    ctx.fillRect(((_number+1)/8)*_board.tileWidth+_board.tiles[_currentLocation].x,
        (1/2)*_board.tileHeight+_board.tiles[_currentLocation].y, _size, _size);

    //draw player info inside of board area
    int infoX = (_board.x + _board.tileWidth*1.75 + _number*_board.tileWidth*1.25).toInt();
    int infoY = (_board.y + _board.tileHeight*2).toInt();
    ctx.fillStyle = 'black';
    ctx.font = 'bold 14pt sans-serif';
    ctx.fillText(_name, infoX, infoY);  //display "player name"

    ctx.font = '10pt sans-serif';
    ctx.fillText("Money: ", infoX, infoY + 20); //display "Money:"
    ctx.font = 'bold 10pt sans-serif';
    ctx.fillText('\$' + _money.toString(), infoX, infoY + 37); //display amount of money

    ctx.font = '10pt sans-serif';
    ctx.fillText("Properties Owned:", infoX, infoY + 55); //display "Properties Owned:"
    ctx.font = '10pt sans-serif';

    for(Tile tile in _ownedTiles){  //display owned properties
      ctx.fillText(tile.name, infoX, infoY + 70 + _ownedTiles.indexOf(tile)*15);
    }
  }
}
