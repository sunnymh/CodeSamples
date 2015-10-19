//
//  main.cpp
//  TetrisAI
//
//  Created by He Ma on 5/24/15.
//  Copyright (c) 2015 He Ma. All rights reserved.
//

#include <iostream>
#include "AIEngine.h"

AIEngine engine;

int AI(int boardW, int boardH,
              char board[],
              char curPiece,
              int curX, int curY,
              int curR,
              char nextPiece,
              int* bestX, int* bestRotation)
{
    engine.setBoardInfo(boardW,boardH,curX,curY);
    Board boardInit(boardW, boardH, board);
    engine.getMax(boardInit, curPiece, bestX, bestRotation);
    return 0;
}

int main(int argc, const char * argv[]) {
    int bestX;
    int bestRotation;
    int boardW = 10;
    int boardH = 20;
    int curX = boardW/2 + 1;
    int curY = boardH - 1;
    int curR = 1;
    char nextPiece = ' ';
    
    //char curPiece = 'Z';
    char curPiece = 'O';
    char board[] = //"11111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111100111111110011111111001111";
    
    AI(boardW, boardH,
       board, curPiece,
       curX, curY, curR, nextPiece,
       &bestX, &bestRotation);
    cout << bestX<< "    "<<bestRotation<< endl;
    //engine.pieceCheck();
    return 0;
}
