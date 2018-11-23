#ifndef GRAPHS
#define GRAPHS

#include <iostream>

using namespace std;

namespace graph{

    typedef struct vertex {
        long long id;
        vertex * next;
        int visited;
    } Vertex;
    
    typedef struct edge {
        long long from;
        long long to;
    } Edge;
    
    __global__
    void initDFS(Vertex * vs, int sid);

    __global__
    void dfs(int done, Vertex * vs, Edge * es);
}

#endif