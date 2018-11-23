#include <iostream>
#include <vector>

using namespace std;

namespace graph{

    typedef struct vertex {
        long long id;
        vertex * next;
        int visited;
    } Vertex;
    
    typedef struct vertex {
        long long from;
        long long to;
    } Edge;
    
    __global__
    void initDFS(Vertex * vs, int sid);

    __global__
    void dfs();
}