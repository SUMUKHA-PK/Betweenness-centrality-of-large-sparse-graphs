#include "graphs.cuh"
using namespace graphs;

__global__
void stage1(bool * status, int * d_q_curlen, int * d_q_nexlen, int * d_S_len, int * d_ends_len, int * d_q_cur, int * d_q_next, int * d_sigma, int * d_delta, int * d_S, int * d_ends, int * d_dist,int* d_depth, Edge * d_edges){        
    
    int id = threadIdx.x + blockIdx.x*blockDim.x;

    
    for(int i=0;i<d_edges[id].no_neigh;i++)
    {
        if(atomicCAS(&d_dist[i],INT_MAX,d_dist[id]+1)==INT_MAX)
        {
            int temp = atomicAdd(d_q_nexlen,1);
            d_q_next[temp]=i;
        }
        if(d_dist[i]==(d_dist[id]+1))
            atomicAdd(&d_sigma[i],d_sigma[id]);
    }

    __syncthreads();

    if(*d_q_nexlen==0)
    {
        *d_depth=d_dist[d_S[*d_S_len-1]]-1;
        *status = false;
    }
    else
    {
        if(id>=0&&id<*d_q_nexlen)
        {
            d_q_cur[id]=d_q_next[id];
            d_S[id+*d_S_len]=d_q_next[id];
        }
        __syncthreads();
        
        d_ends[*d_ends_len]=d_ends[*d_ends_len-1]+*d_q_nexlen;
        *d_ends_len++;
        *d_q_curlen=*d_q_nexlen;
        *d_S_len+=*d_q_nexlen;
        *d_q_nexlen=0;

        __syncthreads();
    }
}

__global__
void stage1(bool * status, int * d_q_curlen, int * d_q_nexlen, int * d_S_len, int * d_ends_len, int * d_q_cur, int * d_q_next, int * d_sigma, int * d_delta, int * d_S, int * d_ends, int * d_dist,int* d_depth, Edge * d_edges){        
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
}

namespace graphs{

    void calculateBC(Edge * h_edges, int no_nodes){

        int * d_q_curlen, * d_q_nexlen, * d_depth, * d_S_len, * d_ends_len;

        int * d_q_cur, * d_q_next, * d_sigma, * d_delta, * d_S, * d_ends, * d_dist, h_depth;
        
        Edge * d_edges;

        bool h_status, * d_status;

        cudaMalloc((void **)&d_q_curlen, sizeof(int));
        cudaMalloc((void **)&d_q_nexlen, sizeof(int));
        cudaMalloc((void **)&d_depth, sizeof(int));
        cudaMalloc((void **)&d_S_len, sizeof(int));
        cudaMalloc((void **)&d_ends_len, sizeof(int));
        cudaMalloc((void **)&d_status, sizeof(bool));

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
        cudaMemcpy(d_S_len, &One, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_ends_len, &One, sizeof(int), cudaMemcpyHostToDevice);

        cudaMemcpy(d_q_cur, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_sigma, &One, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_S, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_ends, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_dist, &Zero, sizeof(int), cudaMemcpyHostToDevice);
           
        cudaMemcpy(d_edges, h_edges, no_nodes*sizeof(Edge), cudaMemcpyHostToDevice);

        while(1){
            h_status = true;
            cudaMemcpy(d_status, &h_status, sizeof(bool), cudaMemcpyHostToDevice);
            stage1<<<10,10>>>(d_status,d_q_curlen,d_q_nexlen,d_S_len,d_ends_len,d_q_cur,d_q_next,d_sigma,d_delta,d_S,d_ends,d_dist,d_depth,d_edges);
            cudaMemcpy(&h_status, d_status, sizeof(bool), cudaMemcpyDeviceToHost);

            if(h_status == false)
                break;
        }
        
        cudaMemcpy(&h_depth,d_depth,sizeof(int),cudaMemcpyDeviceToHost);

        cudaFree(d_q_curlen);
        cudaFree(d_q_nexlen);
        cudaFree(d_depth);
        cudaFree(d_S_len);
        cudaFree(d_ends_len);

        cudaFree(d_q_cur);
        cudaFree(d_q_next);
        cudaFree(d_sigma);
        cudaFree(d_delta);
        cudaFree(d_S);
        cudaFree(d_ends);
        cudaFree(d_dist);

        int counter = h_depth;


        while(counter--){
            stage2<<<10,10>>>();
        }
    }
}