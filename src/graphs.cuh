#ifndef GRAPHS
#define GRAPHS

#include <iostream>

using namespace std;

namespace graphs
{   
    typedef struct i
    {
        long long id;
        struct i * item;
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

        void call_bfs(int ** G);

        Vertex * vs;
        Edge * es;

    };
}

#endif