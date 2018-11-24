#include "graphs.cuh"

__global__
void stage1(int * d_q_curlen, int * d_q_nexlen, int * d_S_len, int * d_ends_len, int * d_q_cur, int * d_q_next, int * d_sigma, int * d_delta, int * d_S, int * d_ends, int * d_dist, Edge * d_edges){        
    
    int id = threadIdx.x + blockIdx.x*blockDim.x;

    for(id=0;i<d_q_curlen;i++)
    {
        for(int i=0;i<edges[id].no_neigh;i++)
        {
            if(atomicCAS(d_))
        }
    }
}

namespace graphs{

    void calculateBC(Edge * h_edges, int no_nodes){

        int * d_q_curlen, * d_q_nexlen, * d_depth, * d_S_len, * d_ends_len;

        int * d_q_cur, * d_q_next, * d_sigma, * d_delta, * d_S, * d_ends, * d_dist;
        
        Edge * d_edges;

        cudaMalloc((void **)&d_q_curlen, sizeof(int));
        cudaMalloc((void **)&d_q_nexlen, sizeof(int));
        cudaMalloc((void **)&d_depth, sizeof(int));
        cudaMalloc((void **)&d_S_len, sizeof(int));
        cudaMalloc((void **)&d_ends_len, sizeof(int));

        cudaMalloc((void **)&d_q_cur, no_nodes*sizeof(int));
        cudaMalloc((void **)&d_q_next, no_nodes*sizeof(int));
        cudaMalloc((void **)&d_sigma, no_nodes*sizeof(int));
        cudaMalloc((void **)&d_delta, no_nodes*sizeof(int));
        cudaMalloc((void **)&d_S, no_nodes*sizeof(int));
        cudaMalloc((void **)&d_ends, no_nodes*sizeof(int));
        cudaMalloc((void **)&d_dist, no_nodes*sizeof(int));

        cudaMalloc((void **)&d_edges, no_nodes*sizeof(Edge));

        int One = 1;
        int Zero = 0;

        // Initialize
        cudaMemcpy(d_q_curlen, &One, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_q_nexlen, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_S_len, &One, sizeof(int, cudaMemcpyHostToDevice));
        cudaMemcpy(d_ends_len, &One, sizeof(int), cudaMemcpyHostToDevice);

        cudaMemcpy(d_q_cur, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_sigma, &One, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_S, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_ends, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_dist, &Zero, sizeof(int), cudaMemcpyHostToDevice);
           
        cudaMemcpy(d_edges, h_edges, no_nodes*sizeof(Edge), cudaMemcpyHostToDevice);

    }
}