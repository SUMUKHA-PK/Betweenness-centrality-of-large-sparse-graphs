#ifndef GRAPHS
#define GRAPHS

#include <iostream>

using namespace std;

namespace graph
{   
    typedef struct item
    {
        long long id;
        struct item * item;
    } Item;

    typedef struct vertex 
    {
        Item * item;
        bool visited;
        bool inQ;
        long long distance;
    } Vertex;
    
    typedef struct edge
    {
        Item * item;
    } Edge;
    
    class graph
    {

    public:

        __global__
        void initBFS(Vertex * vs, int sid);

        __global__
        void bfs(int done, Vertex * vs, Edge * es);

        Vertex * vs;
        Edge * es;

    };
}

#endif