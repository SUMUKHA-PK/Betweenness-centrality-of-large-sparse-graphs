#include "graphs.cuh"

namespace graph
{

    graph::__global__ void bfs(int * done, Vertex * vs, Edge * es, int no_nodes)
    {        
        long long int id = threadIdx.x + blockIdx.x * blockDim.x;

        if(vid < no_nodes)
        {
            if(vs[id].inQ == true && vs[id].visited == false)
            {
                
                vs[id].visited = true;

                vs[id].inQ = false;

                __syncthreads();
                
                Item * temp = es[id].item;
                
                while( temp->item != NULL)
                {
                    int n_id = temp.id;

                    if(vs[n_id].visited == false)
                    {
                        *done = false;

                        if(vs[n_id].distance == vs[id].distance + 1)
                        {
                            Item * t = vs[n_id].item;
                            while(t->item != NULL)
                            {
                                t = t->item;
                            }
                            t->id = id;
                            Item nItem = new Item; 
                            *nItem = {.id : -1, .item : NULL};
                            t->item = nItem;
                        }
                        else if(vs[n_id].distance > vs[id].distance + 1)
                        {
                            vs[n_id].item->id = id;
                            Item nItem = new Item; 
                            *nItem = {.id : -1, .item : NULL};    
                            vs[n_id].item->item = nItem;
                        }
                    }
                }
            }
        }
    }
}