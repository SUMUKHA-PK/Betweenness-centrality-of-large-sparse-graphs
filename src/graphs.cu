#include "graphs.cuh"
using namespace graphs;

#define size 8

__global__
void stage1(bool * status, int * d_q_curlen, int * d_q_nexlen, int * d_S_len, int * d_ends_len, int * d_q_cur, int * d_q_next, int * d_sigma, int * d_delta, int * d_S, int * d_ends, int * d_dist,int* d_depth, int * d_no_nodes, Edge * d_edges){        
    
    int id = threadIdx.x + blockIdx.x*blockDim.x;

    if(id<*d_q_curlen)
    {   
        int current = d_q_cur[id];
        for(int i=0;i<d_edges[current].no_neigh;i++)
        {
            if(atomicCAS(&d_dist[d_edges[current].neighbours[i]],INT_MAX,d_dist[current]+1)==INT_MAX)
            {
                int temp = atomicAdd(d_q_nexlen,1);
                d_q_next[temp]=d_edges[current].neighbours[i];
            }
            if(d_dist[d_edges[current].neighbours[i]]==(d_dist[current]+1))
                atomicAdd(&d_sigma[d_edges[current].neighbours[i]],d_sigma[current]);
        }
        __syncthreads();
    }
}

__global__
void stage1_1(bool * status, int * d_q_curlen, int * d_q_nexlen, int * d_S_len, int * d_ends_len, int * d_q_cur, int * d_q_next, int * d_sigma, int * d_delta, int * d_S, int * d_ends, int * d_dist,int* d_depth, int * d_no_nodes, Edge * d_edges)
{
    int id = threadIdx.x + blockIdx.x*blockDim.x;

    if(id<*d_q_nexlen)
    {
        d_q_cur[id]=d_q_next[id];
        d_S[id+*d_S_len]=d_q_next[id];
        __syncthreads();
    }
}

__global__ 
void single(int * d_depth, int * d_dist, int * d_S, int * d_S_len){
    *d_depth=d_dist[d_S[*d_S_len-1]]-1;
}

__global__ 
void singleThread(int * d_ends, int * d_ends_len, int * d_q_nexlen, int * d_q_curlen, int * d_S_len){
    d_ends[*d_ends_len]=d_ends[*d_ends_len-1]+*d_q_nexlen;
    *d_ends_len = *d_ends_len + 1;
    *d_q_curlen=*d_q_nexlen;
    *d_S_len+=*d_q_nexlen;
    *d_q_nexlen=0;
}

__global__
void stage2_2(int * d_delta, int *  d_dist, int *  d_sigma, int * d_S, Edge * d_edges, const int offset, const int itr){
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    if(idx <= itr){
        int tid = idx + offset;
        int w = d_S[tid];
        float dsw = 0;
        int sw = d_sigma[w];
    
        for(int i = 0; i < d_edges[w].no_neigh; i++){
            int v = d_edges[w].neighbours[i];
            if(d_dist[v] == d_dist[w] + 1){
                dsw += ((float) sw * (1 + d_delta[v])) / d_sigma[v];
            }
        }
        d_delta[w] = (int)dsw;

        __syncthreads();
    }
}


namespace graphs{

    void calculateBC(Edge * h_edges, int no_nodes){

        int * d_q_curlen, * d_q_nexlen, * d_depth, * d_S_len, * d_ends_len, * d_no_nodes, h_q_nexlen;

        int * d_q_cur, * d_q_next, * d_sigma, * d_delta, *h_delta, * d_S, * d_ends, * d_dist, * h_ends, h_depth;

        int * h_dis = new int[no_nodes];
        h_ends = new int[no_nodes];

        for(int cc=0;cc<no_nodes;cc++)
        {
            h_ends[cc] = 0;
            h_dis[cc] = INT_MAX;
        }

        h_dis[0] = 0;
        
        Edge * d_edges;

        bool * d_status;

        cudaMalloc((void **)&d_q_curlen, sizeof(int));
        cudaMalloc((void **)&d_q_nexlen, sizeof(int));
        cudaMalloc((void **)&d_depth, sizeof(int));
        cudaMalloc((void **)&d_S_len, sizeof(int));
        cudaMalloc((void **)&d_ends_len, sizeof(int));
        cudaMalloc((void **)&d_no_nodes, sizeof(int));
        cudaMalloc((void **)&d_status, sizeof(bool));

        cudaMalloc((void **)&d_q_cur, no_nodes*sizeof(int));
        cudaMalloc((void **)&d_q_next, no_nodes*sizeof(int));
        cudaMalloc((void **)&d_sigma, no_nodes*sizeof(int));
        cudaMalloc((void **)&d_delta, no_nodes*sizeof(int));
        cudaMalloc((void **)&d_S, no_nodes*sizeof(int));
        cudaMalloc((void **)&d_ends, no_nodes*sizeof(int));
        cudaMalloc((void **)&d_dist, no_nodes*sizeof(int));

        cudaMalloc((void **)&d_edges, no_nodes*sizeof(Edge));

        cudaMemset(d_delta, 0, no_nodes*sizeof(int));

        int One = 1;
        int Zero = 0;
        int Two = 2;
        int initEnd[2] = {0, 1};

        // Initialize
        cudaMemcpy(d_q_curlen, &One, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_q_nexlen, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_S_len, &One, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_ends_len, &Two, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_ends, initEnd, 2*sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_no_nodes, &no_nodes, sizeof(int), cudaMemcpyHostToDevice);

        cudaMemcpy(d_q_cur, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_sigma, &One, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_S, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_dist, h_dis, no_nodes*sizeof(int), cudaMemcpyHostToDevice);
           
        cudaMemcpy(d_edges, h_edges, no_nodes*sizeof(Edge), cudaMemcpyHostToDevice);

        while(1){
            stage1<<<10,10>>>(d_status,d_q_curlen,d_q_nexlen,d_S_len,d_ends_len,d_q_cur,d_q_next,d_sigma,d_delta,d_S,d_ends,d_dist,d_depth,d_no_nodes,d_edges);
            cudaMemcpy(&h_q_nexlen, d_q_nexlen, sizeof(int), cudaMemcpyDeviceToHost);
 
            if(h_q_nexlen==0){
                single<<<1, 1>>>(d_depth, d_dist, d_S, d_S_len);
                break;
            }
            stage1_1<<<10,10>>>(d_status,d_q_curlen,d_q_nexlen,d_S_len,d_ends_len,d_q_cur,d_q_next,d_sigma,d_delta,d_S,d_ends,d_dist,d_depth,d_no_nodes,d_edges);
            singleThread<<<1, 1>>>(d_ends, d_ends_len, d_q_nexlen, d_q_curlen, d_S_len);
        }
        
        cudaMemcpy(&h_depth,d_depth,sizeof(int),cudaMemcpyDeviceToHost);
        cudaMemcpy(h_ends,d_ends,no_nodes * sizeof(int),cudaMemcpyDeviceToHost);
        
        int counter = h_depth;

        int offset;

        while(counter >= 0){

            offset = h_ends[counter];
            int itr = h_ends[counter + 1] - 1 - offset;

            // int blocks = ceil((float)itr/size);

            stage2_2<<<1, size>>>(d_delta, d_dist, d_sigma, d_S, d_edges, (const int)offset, (const int)itr);

            counter --;
        }

        h_delta = new int[no_nodes];
        
        cudaMemcpy(h_delta, d_delta, no_nodes * sizeof(int),cudaMemcpyDeviceToHost);
        
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
    }
}