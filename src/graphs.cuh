#ifndef GRAPHS
#define GRAPHS

#include <iostream>

using namespace std;

namespace graphs{

    typedef struct edge{
        int neighbours[10];
        int no_neigh;
    } Edge;

    typedef struct result{
        double time;
        int delta;
    } Results;
    
    Results calculateBC(Edge * edges, int no_nodes, int threads);
}

#endif