//
//  TopKQueue.h
//  TetrisAI
//
//  Created by He Ma on 5/26/15.
//  Copyright (c) 2015 He Ma. All rights reserved.
//

#ifndef __TetrisAI__TopKQueue__
#define __TetrisAI__TopKQueue__
/*
#include <queue>
using namespace std;

struct Heuristic{
    int bestX;
    int bestRotation;
    double value;
    Heuristic(int bestX, int bestRotation, double value)
    :bestX(bestX),bestRotation(bestRotation),value(value){};
    bool operator<(const Heuristic& rhs){return value < rhs.value;};
};

class TopKQueue
{
public:
    TopKQueue(int k):maxSize(k){};
    int getSize(){return (int)queue.size();};
    void getHeuristics(int& bestX, int& bestRotation, double& value)
    {
        Heuristic heu = queue.top();
        bestX = heu.bestX;
        bestRotation = heu.bestRotation;
        value = heu.value;
        queue.pop();
    };
    void push(Heuristic heu)
    {
        queue.push(heu);
        if (queue.size()>maxSize) {
            
        }
    };
    
private:
    priority_queue<Heuristic, vector<Heuristic>> queue;
    int maxSize;
};
 */
#endif /* defined(__TetrisAI__TopKQueue__) */
