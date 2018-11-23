#ifndef GRAPHS
#define GRAPHS

#include <iostream>

using namespace std;

namespace graph
{
    typedef struct Lock
    {
        int * mutex;
    
        Lock()
        {
            int state=0;
            cudaMalloc((void∗∗)&mutex, sizeof(int)));
            cudaMemcpy(mutex, &state, sizeof(int), cudaMemcpyHostToDevice));
        };
    
        ~Lock()
        {
            cudaFree(mutex);
        };
    
        __device__ void
        lock()
        {
            while(atomicCAS(mutex,0,1)!=0);
        };
    
        __device__ void
        unlock()
        {
            atomicExch(mutex,0);
        };
    
    }
    Lock;
    
    typedef struct vertex 
    {
        long long id;
        vertex * parents;
        bool visited;
        bool inQ;
    } Vertex;
    
    typedef struct edge 
    {
        Vertex * v;
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