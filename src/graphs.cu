#include "graphs.cuh"

namespace graph
{

    graph::__global__ void bfs(int * done, Vertex * vs, Edge * es, int no_nodes)
    {
        Lock lock;
        
        long long int id = threadIdx.x + blockIdx.x * blockDim.x;

        if(vid < no_nodes)
        {

            if(vs[id].visited == false && vx[id].inQ == true)
            {
                while(es[id]->v != NULL){
                                  
                }
            }

        }

    }
    
}