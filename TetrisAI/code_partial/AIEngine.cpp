//
//  AIEngine.cpp
//  TetrisAI
//
//  Created by He Ma on 5/26/15.
//  Copyright (c) 2015 He Ma. All rights reserved.
//

#include "AIEngine.h"
#include <queue>

AIEngine::AIEngine()
{
    // O piece
    m_OPieceMap.push_back(new Piece("0110","0330",1,1,2,2));
    // I piece
    m_IPieceMap.push_back(new Piece("2222", "3333",0,2,4,1));
    m_IPieceMap.push_back(new Piece("0000", "0040",2,0,1,4));
    // S piece
    m_SPieceMap.push_back(new Piece("0112", "0233",1,1,3,2));
    m_SPieceMap.push_back(new Piece("0021", "0043",2,1,2,3));
    // Z piece
    m_ZPieceMap.push_back(new Piece("0211", "0332",1,1,3,2));
    m_ZPieceMap.push_back(new Piece("0012", "0034",2,1,2,3));
    // L piece
    m_LPieceMap.push_back(new Piece("0122","0333",1,1,3,2));
    m_LPieceMap.push_back(new Piece("0011","0042",2,1,2,3));
    m_LPieceMap.push_back(new Piece("0222","0334",1,2,3,2));
    m_LPieceMap.push_back(new Piece("0310","0440",1,1,2,3));
    // J piece
    m_JPieceMap.push_back(new Piece("0221","0333",1,1,3,2));
    m_JPieceMap.push_back(new Piece("0013","0044",2,1,2,3));
    m_JPieceMap.push_back(new Piece("0222","0433",1,2,3,2));
    m_JPieceMap.push_back(new Piece("0110","0240",1,1,2,3));
    // T piece
    m_TPieceMap.push_back(new Piece("0212","0333",1,1,3,2));
    m_TPieceMap.push_back(new Piece("0012","0043",2,1,2,3));
    m_TPieceMap.push_back(new Piece("0222","0343",1,2,3,2));
    m_TPieceMap.push_back(new Piece("0210","0340",1,1,2,3));

}

void AIEngine::pieceCheck()
{
    for (int i = 0; i<m_OPieceMap.size(); i++) {m_OPieceMap[i]->printPiece();}
    for (int i = 0; i<m_IPieceMap.size(); i++) {m_IPieceMap[i]->printPiece();}
    for (int i = 0; i<m_SPieceMap.size(); i++) {m_SPieceMap[i]->printPiece();}
    for (int i = 0; i<m_ZPieceMap.size(); i++) {m_ZPieceMap[i]->printPiece();}
    for (int i = 0; i<m_LPieceMap.size(); i++) {m_LPieceMap[i]->printPiece();}
    for (int i = 0; i<m_JPieceMap.size(); i++) {m_JPieceMap[i]->printPiece();}
    for (int i = 0; i<m_TPieceMap.size(); i++) {m_TPieceMap[i]->printPiece();}
}

AIEngine::~AIEngine()
{
    for (int i = 0; i<m_OPieceMap.size(); i++) {delete m_OPieceMap[i];}
    for (int i = 0; i<m_IPieceMap.size(); i++) {delete m_IPieceMap[i];}
    for (int i = 0; i<m_SPieceMap.size(); i++) {delete m_SPieceMap[i];}
    for (int i = 0; i<m_ZPieceMap.size(); i++) {delete m_ZPieceMap[i];}
    for (int i = 0; i<m_LPieceMap.size(); i++) {delete m_LPieceMap[i];}
    for (int i = 0; i<m_JPieceMap.size(); i++) {delete m_JPieceMap[i];}
    for (int i = 0; i<m_TPieceMap.size(); i++) {delete m_TPieceMap[i];}
}

int AIEngine::getMax(Board& board , char curPiece, int *bestX, int *bestRotation){
    vector<Piece*> rotations;
    switch (curPiece){
    case 'O':
        rotations = m_OPieceMap; break;
    case 'I':
        rotations = m_IPieceMap; break;
    case 'S':
        rotations = m_SPieceMap; break;
    case 'Z':
        rotations = m_ZPieceMap; break;
    case 'L':
        rotations = m_LPieceMap; break;
    case 'J':
        rotations = m_JPieceMap; break;
    case 'T':
        rotations = m_TPieceMap; break;
    }

    double heursitics = -1 * std::numeric_limits<float>::infinity();
    *bestX = 0;
    *bestRotation = 0;
    Board nextBoard;
    int leftBound, rightBound;
    
    for(int i = 0;i<rotations.size();i++)
    {
        Piece* rotation = rotations[i];
        if (canRotate(board, rotation)){
            findBound(board, rotation, leftBound, rightBound);
            for(int j = 0; j <= m_boardW-(rotation->m_width); j++)
            {
                nextBoard.copyBoard(board);
                int rowsEliminated, landingHeight;
                makeMove(nextBoard, rotation, rowsEliminated, j, landingHeight);
                double curEvaluation = evaluateBoard(nextBoard,  rowsEliminated, landingHeight, rotation->m_height);
                if (curEvaluation > heursitics) {
                    heursitics = curEvaluation;
                    *bestX = j;
                    *bestRotation = i;
                }
            }
        }
    }
    *bestX += 2-rotations[*bestRotation]->m_leftmost + 1;
    *bestRotation += 1;
    return 0;
}

bool AIEngine::canRotate(Board& board, Piece *piece)
{
    for (int i = 0; i < piece->m_width; i++)
    {
        for (int j = piece->m_bottom[(piece->m_leftmost)+i]; j < piece->m_top[(piece->m_leftmost)+i]; j++) {
            if (((board.m_rows[m_curY-2+j]>>(m_boardW - (m_curX-2+i+piece->m_leftmost) - 1))&1) == 1) {
                return false;
            }
        }
    }
    return true;
}

void AIEngine::findBound(Board &board, Piece *piece, int &leftBound, int &rightBound)
{
    int lowestX = 3;
    int highestX = 0;
    for (int i = 0; i < 4; i++)
    {
        if(piece->m_bottom[i]==piece->m_lowest)
        {
            lowestX = i;
            break;
        }
    }
    for (int i = m_curX-2+lowestX; i >= lowestX - piece->m_leftmost; i--) {
        if (board.m_heights[i] <= (m_curY - 2 + piece->m_lowest)) {
            leftBound = i + piece->m_leftmost - lowestX;
        }else {
            break;
        }
    }

    for (int i = 3; i >= 0; i--)
    {
        if(piece->m_bottom[i]==piece->m_lowest)
        {
            highestX = i;
            break;
        }
    }
    for (int i = m_curX-2+highestX; i <= (m_boardW-piece->m_width + highestX - piece->m_leftmost); i++) {
        if (board.m_heights[i] <= (m_curY - 2 + piece->m_lowest)) {
            rightBound = i + piece->m_leftmost - highestX;
        }else {
            break;
        }
    }
}

void AIEngine::makeMove(Board& board, Piece* piece, int& rowsEliminated, int leftmostIndex, int& landingHeight)
{
    // Find the lowest row the piece can go to.
    int lowestY = -4;
    int curY = 0;
    for (int i = 0; i < piece->m_width; i++) {
        curY = board.m_heights[i+leftmostIndex] - piece->m_bottom[(piece->m_leftmost)+i];
        if (curY > lowestY) {
            lowestY = curY;
        }
    }
    
    landingHeight = lowestY + piece->m_lowest;
    
    // Fill in the board
    for (int i = 0; i < piece->m_width; i++)
    {
        for (int j = piece->m_bottom[(piece->m_leftmost)+i]; j < piece->m_top[(piece->m_leftmost)+i]; j++) {
            board.m_rows[lowestY + j] |= 1<<(m_boardW-1-leftmostIndex-i);
        }
        board.m_heights[leftmostIndex+i]+= (piece->m_top[(piece->m_leftmost)+i] - piece->m_lowest);
    }
    
    // Remove the lines that are full
    rowsEliminated = 0;
    int rowToCopy[MAX_HEIGHT];
    int nextCopy = 0;
    for(int i = 0; i < m_boardH; i++)
    {
        if (board.m_rows[i]!=FULL_ROW) {
            rowToCopy[nextCopy] = i;
            nextCopy++;
        }else{
            rowsEliminated++;
        }
    }
    for (int i = 0; i<nextCopy; i++) {
        if (rowToCopy[i] != i) {
            board.m_rows[i] = board.m_rows[rowToCopy[i]];
        }
    }
    
    for (int i = nextCopy; i<m_boardH; i++) {
        board.m_rows[i] = 0;
    }
    
    for (int i = 0; i < m_boardW; i++) {
        board.m_heights[i] -= rowsEliminated;
    }
}

double AIEngine::evaluateBoard(Board& board, int rowsEliminated, int landingHeight, int pieceHeight){
    int rowTransitions = getRowTransitions(board);
    int colTransitions = getColTransitions(board);
    int numOfHoles = getNumOfHoles(board);
    int wellSums = getNumOfWells(board);
    return (landingHeight+0.5*pieceHeight) * -4.500158825082766 +
    rowsEliminated * 3.4181268101392694 +
    rowTransitions * -3.2178882868487753 +
    colTransitions * -9.348695305445199 +
    numOfHoles * -7.899265427351652 +
    wellSums * -3.3855972247263626;
}

int AIEngine::getRowTransitions(Board &board)
{
    int transitions = 0;
    int last_bit = 1;
    int bit = 0;
    
    for (int i = 0; i < m_boardH; i++) {
        int row = board.m_rows[i];
        for (int j = 0; j < m_boardW; j++) {
            bit = (row >> (m_boardW-j-1)) & 1;
            if (bit != last_bit) {
                transitions++;
            }
            last_bit = bit;
        }
        if (bit == 0) {
            transitions++;
        }
        last_bit = 1;
    }
    return transitions;
}

int AIEngine::getColTransitions(Board &board)
{
    int transitions = 0;
    int last_bit = 1;
    int bit = 0;
    
    for (int i = 0; i < m_boardW; i++) {
        for (int j = 0; j < m_boardH; j++) {
            int row = board.m_rows[j];
            bit = (row >> (m_boardW-i-1)) & 1;
            if (bit != last_bit) {
                transitions++;
            }
            last_bit = bit;
        }
        last_bit = 1;
    }
    return transitions;
}

int AIEngine::getNumOfHoles(Board& board)
{
    int holes = 0;
    int row_holes = 0;
    int previous_row = board.m_rows[m_boardH - 1];
    
    for (int i = m_boardH - 2; i >= 0; i--) {
        row_holes = ~board.m_rows[i] & (previous_row | row_holes);
        for (int j = 0; j < m_boardW; j++) {
            holes += ((row_holes >> (m_boardW-j-1)) & 1);
        }
        previous_row = board.m_rows[i];
    }
    return holes;
}

int AIEngine::getNumOfWells(Board& board)
{
    int well_sums = 0;
    
    for (int i = 1; i < m_boardW - 1; i++) {
        for (int j = m_boardH - 1; j >= 0; j--) {
            if ((((board.m_rows[j] >> (m_boardW-i-1)) & 1) == 0) &&
                (((board.m_rows[j] >> (m_boardW-i)) & 1) == 1) &&
                (((board.m_rows[j] >> (m_boardW-i-2)) & 1) == 1))
            {
                well_sums++;
                for (int k = j - 1; k >= 0; k--) {
                    if (((board.m_rows[k] >> (m_boardW-i-1)) & 1) == 0) {
                        well_sums++;
                    } else {
                        break;
                    }
                }
            }
        }
    }

    // Check for well cells in the rightmost column of the board.
    for (int j = m_boardH - 1; j >= 0; j--) {
        if ((((board.m_rows[j] >> (m_boardW-0-1)) & 1) == 0) &&
            (((board.m_rows[j] >> (m_boardW-1-1)) & 1) == 1)) {
            well_sums++;
            for (int k = j - 1; k >= 0; --k) {
                if (((board.m_rows[k] >> (m_boardW-0-1)) & 1) == 0) {
                    well_sums++;
                } else {
                    break;
                }
            }
        }
    }
    
    // Check for well cells in the rightmost column of the board.
    for (int j = m_boardH - 1; j >= 0; j--) {
        if ((((board.m_rows[j] >> 0) & 1) == 0) &&
            (((board.m_rows[j] >> 1) & 1) == 1)) {
            well_sums++;
            for (int k = j - 1; k >= 0; --k) {
                if (((board.m_rows[k] >> 0) & 1) == 0) {
                    well_sums++;
                } else {
                    break;
                }
            }
        }
    }
    return well_sums;
}
















