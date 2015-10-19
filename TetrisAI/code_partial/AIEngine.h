//
//  AIEngine.h
//  TetrisAI
//
//  Created by He Ma on 5/26/15.
//  Copyright (c) 2015 He Ma. All rights reserved.
//

#ifndef __TetrisAI__AIEngine__
#define __TetrisAI__AIEngine__

#include <vector>
#include <string>
#include <iostream>
using namespace std;

const int MAX_HEIGHT = 20;

struct Piece{
    int m_bottom[4];
    int m_top[4];
    int m_leftmost;
    int m_lowest;
    int m_height;
    int m_width;
    Piece(string bottom, string top, int leftmost, int lowest, int width, int height)
    :m_leftmost(leftmost),m_lowest(lowest),m_width(width),m_height(height)
    {
        for(int i = 0;i<4;i++){m_bottom[i]=bottom[i]-'0';}
        for(int i = 0;i<4;i++){m_top[i]=top[i]-'0';}
    };
    
    void printPiece()
    {
        for(int i = 0; i < 4; i++)
        {
            for(int j = 0; j < 4; j++)
            {
                if(3-i>=m_bottom[j]&&3-i<m_top[j]){cout << 'o';}
                else{cout << '.';}
            }
            cout << endl;
        }
        cout << "leftmost: " << m_leftmost
        << " lowest: " << m_lowest
        << " height: " << m_height
        << " width: " << m_width << endl;
    }
};

struct Board{
    int m_rows[20];
    int m_heights[10];
    Board(){};
    Board(int boardW, int boardH, char board[])
    {
        for(int i = 0; i < 20; i++)
        {
            m_rows[i] = 0;
        }
        for(int i = 0; i < 10; i++)
        {
            m_heights[i] = 0;
        }
        for(int y = 0, add = 0; y < boardH; y++, add += boardW)
        {
            for(int x = 0; x < boardW; x++)
            {
                if(board[x + add] == '1')
                {
                    m_heights[x] = y + 1;
                    m_rows[y] |= 1 << (10-x-1);
                }
            }
        }
    };
    void copyBoard(const Board& board){
        memcpy(m_rows, board.m_rows, 20*sizeof(int));
        memcpy(m_heights, board.m_heights, 10*sizeof(int));
    }
};

struct Heuristic{
    int bestX;
    int bestRotation;
    double value;
    Heuristic(int bestX, int bestRotation, double value)
    :bestX(bestX),bestRotation(bestRotation),value(value){};
    bool operator<(const Heuristic& rhs){return value < rhs.value;};
};

class AIEngine
{
public:
    AIEngine();
    void setBoardInfo(int boardW, int boardH, int curX, int curY)
    {
        m_boardW = boardW;
        m_boardH = boardH;
        m_curX = curX-1;
        m_curY = curY-1;
        FULL_ROW = (1<<m_boardW)-1;
    };
    void pieceCheck();
    int getMax(Board& board, char curPiece, int* bestX, int* bestRotation);
    bool canRotate(Board& board, Piece* piece);
    void findBound(Board& board, Piece* piece, int& leftBound, int& rightBound);
    void makeMove(Board& board, Piece* piece, int& rowsEliminated, int leftmostIndex, int& landingHeight);
    double evaluateBoard(Board& board, int rowsEliminated, int landingHeight, int pieceHeight);
    ~AIEngine();

private:
    int m_boardW, m_boardH, m_curX, m_curY, FULL_ROW;
    vector<Piece*> m_OPieceMap, m_IPieceMap, m_SPieceMap, m_ZPieceMap, m_LPieceMap, m_JPieceMap, m_TPieceMap;
    int getRowTransitions(Board& board);
    int getColTransitions(Board& board);
    int getNumOfHoles(Board& board);
    int getNumOfWells(Board& board);
};
#endif /* defined(__TetrisAI__AIEngine__) */
