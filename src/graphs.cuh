#ifndef GRAPHS
#define GRAPHS

#include <iostream>

using namespace std;

namespace graphs{

    typedef struct edge{
        int neighbours[10];
        int no_neigh;
    } Edge;
    
    void calculateBC(Edge * edges, int no_nodes);
}

#endif