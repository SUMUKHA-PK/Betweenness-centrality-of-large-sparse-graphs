#ifndef GRAPHS
#define GRAPHS

#include <iostream>

using namespace std;

namespace graphs{

    typedef struct edge{
        int tos[10];
        int no_to;
    } Edge;
    
    void calculateBC(Edge * edges, int no_edges);
}

#endif