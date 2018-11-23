#include <iostream>
#include <vector>

using namespace std;

namespace graph{

    typedef struct vertex {
        long long id;
        vertex * next;
        int visited;
    } Vertex;

    __global__
    void initDFS(Vertex * vs, int sid);

    __global__
    void dfs();
}