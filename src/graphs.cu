#include "graphs.cuh"

__global__
void bfs(int * done, Vertex * vs, Edge * es, int no_nodes)
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

namespace graphs
{
    void graph::call_bfs(int ** G)
    {
        Vertex * h_vs = new Vertex[5];
        Vertex * d_vs;
        cudaMalloc((void **)&d_vs, 5 * sizeof(Vertex));

        Edge * h_es = new Edge[5]; 
        Edge * d_es;
        cudaMalloc((void **)&d_es, 5 * sizeof(Edge));

        for(int i=0; i < 5; i++){

            Item * temp = new Item;
            *temp = {.id : -1, .item : NULL};
            h_vs[i].item = temp;
            h_es[i].item = temp;

            h_vs[i].distance = MAX;
            h_vs[i].visited = false;
            h_vs[i].inQ = false;

            for(int j=0; j < 5; j++){
                if(G[i][j] == 1){
                    temp = h_es[i].item;

                    while(temp->item != NULL){
                        temp = temp->item;
                    }

                    Item * tempE = new Item;
                    *tempE = {.id : j, .item : NULL};
                    temp->item = tempE;
                }
            }

            h_vs[0].distance = 0;
            h_vs[0].inQ = 1;
            
            int done;
            cudaMemcpy(d_vs, h_vs, 5 * sizeof(Vertex), cudaMemcpyHostToDevice);
            cudaMemcpy(d_es, h_es, 5 * sizeof(Edge), cudaMemcpyHostToDevice);
            
            bool h_done = true, * d_done;
            cudaMalloc((void **)&d_done, sizeof(bool));

            bfs<<<5, 5>>>(d_done, d_vs, d_es, 5);
        }
    }
}