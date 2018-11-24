#include "graphs.cuh"
using namespace graphs;

#define size 8

__global__
void stage1(bool * status, int * d_q_curlen, int * d_q_nexlen, int * d_S_len, int * d_ends_len, int * d_q_cur, int * d_q_next, int * d_sigma, int * d_delta, int * d_S, int * d_ends, int * d_dist,int* d_depth, int * d_no_nodes, Edge * d_edges){        
    
    int id = threadIdx.x + blockIdx.x*blockDim.x;

    if(id<*d_no_nodes)
    {
        for(int i=0;i<d_edges[id].no_neigh;i++)
        {
            if(atomicCAS(&d_dist[d_edges[id].neighbours[i]],INT_MAX,d_dist[id]+1)==INT_MAX)
            {
                printf("%d netlen,id %d \n",*d_q_nexlen,id);
                int temp = atomicAdd(d_q_nexlen,1);
                printf("%d netlen,id %d\n",*d_q_nexlen,id);
                d_q_next[temp]=d_edges[id].neighbours[i];
            }
            if(d_dist[d_edges[id].neighbours[i]]==(d_dist[id]+1))
                atomicAdd(&d_sigma[d_edges[id].neighbours[i]],d_sigma[id]);
        }

        __syncthreads();
    }
}

__global__
void stage1_1(bool * status, int * d_q_curlen, int * d_q_nexlen, int * d_S_len, int * d_ends_len, int * d_q_cur, int * d_q_next, int * d_sigma, int * d_delta, int * d_S, int * d_ends, int * d_dist,int* d_depth, int * d_no_nodes, Edge * d_edges)
{
    int id = threadIdx.x + blockIdx.x*blockDim.x;

    if(id<*d_no_nodes)
    {
        printf("%d netlen,id %d\n",*d_q_nexlen,id);
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

        if(id==0)
        {
            for(int x = 0;x<5;x++)
                printf("%d ",d_sigma[x]);
            printf("sigma\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_ends[x]);
            printf("ends\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_S[x]);
            printf("S\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_dist[x]);
            printf("dist\n");
            for(int x=0;x<*d_q_curlen;x++)
                printf("%d ",d_q_cur[x]);
            printf("cur\n");
            for(int x=0;x<*d_q_nexlen;x++)
                printf("%d ",d_q_next[x]);
            printf("nex\n");
        }
        if(id==1)
        {
            for(int x = 0;x<5;x++)
                printf("%d ",d_sigma[x]);
            printf("sigma\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_ends[x]);
            printf("ends\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_S[x]);
            printf("S\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_dist[x]);
            printf("dist\n");
            for(int x=0;x<*d_q_curlen;x++)
                printf("%d ",d_q_cur[x]);
            printf("cur\n");
            for(int x=0;x<*d_q_nexlen;x++)
                printf("%d ",d_q_next[x]);
            printf("nex\n");
        }
        if(id==2)
        {
            for(int x = 0;x<5;x++)
                printf("%d ",d_sigma[x]);
            printf("sigma\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_ends[x]);
            printf("ends\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_S[x]);
            printf("S\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_dist[x]);
            printf("dist\n");
            for(int x=0;x<*d_q_curlen;x++)
                printf("%d ",d_q_cur[x]);
            printf("cur\n");
            for(int x=0;x<*d_q_nexlen;x++)
                printf("%d ",d_q_next[x]);
            printf("nex\n");
        }
        if(id==3)
        {
            for(int x = 0;x<5;x++)
                printf("%d ",d_sigma[x]);
            printf("sigma\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_ends[x]);
            printf("ends\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_S[x]);
            printf("S\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_dist[x]);
            printf("dist\n");
            for(int x=0;x<*d_q_curlen;x++)
                printf("%d ",d_q_cur[x]);
            printf("cur\n");
            for(int x=0;x<*d_q_nexlen;x++)
                printf("%d ",d_q_next[x]);
            printf("nex\n");
        }
        if(id==4)
        {
            for(int x = 0;x<5;x++)
                printf("%d ",d_sigma[x]);
            printf("sigma\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_ends[x]);
            printf("ends\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_S[x]);
            printf("S\n");
            for(int x = 0;x<5;x++)
                printf("%d ",d_dist[x]);
            printf("dist\n");
            for(int x=0;x<*d_q_curlen;x++)
                printf("%d ",d_q_cur[x]);
            printf("cur\n");
            for(int x=0;x<*d_q_nexlen;x++)
                printf("%d ",d_q_next[x]);
            printf("nex\n");
        }
    }
}
__global__
void stage2(int * d_delta, int *  d_dist, int *  d_sigma, int * d_S, Edge * d_edges, int offset,int itr){        
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    if(idx < itr){
        int tid = idx + offset;
        int w = d_S[tid];
        float dsw = 0;
        int sw = d_sigma[w];

        for(int i = 0; i < d_edges[w].no_neigh; i++){
            int v = d_edges[w].neighbours[i];
            if(d_dist[] == d_dist[w] + 1){
                dsw += (float) sw * (1 + d_delta[v]) / d_sigma[v];
            }
        }
        d_delta[w] = (int)dsw;
        
        __syncthreads();
    }
}

namespace graphs{

    void calculateBC(Edge * h_edges, int no_nodes){

        int * d_q_curlen, * d_q_nexlen, * d_depth, * d_S_len, * d_ends_len, * d_no_nodes;

        int * d_q_cur, * d_q_next, * d_sigma, * d_delta, * d_S, * d_ends, * d_dist, * h_ends, h_depth;

        int * h_dis = new int[no_nodes];

        for(int cc=0;cc<no_nodes;cc++)
        {
            h_dis[cc]=INT_MAX;
        }

        h_dis[0] = 0;

        for(int cc=0;cc<no_nodes;cc++)
        {
            printf("%d ",h_dis[cc]);
        }
        
        Edge * d_edges;

        bool h_status, * d_status;

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

        // Initialize
        cudaMemcpy(d_q_curlen, &One, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_q_nexlen, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_S_len, &One, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_ends_len, &One, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_no_nodes, &no_nodes, sizeof(int), cudaMemcpyHostToDevice);

        cudaMemcpy(d_q_cur, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_sigma, &One, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_S, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_ends, &Zero, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_dist, h_dis, no_nodes*sizeof(int), cudaMemcpyHostToDevice);
           
        cudaMemcpy(d_edges, h_edges, no_nodes*sizeof(Edge), cudaMemcpyHostToDevice);

        while(1){
            cout << "Hi " << endl;
            h_status = true;
            cudaMemcpy(d_status, &h_status, sizeof(bool), cudaMemcpyHostToDevice);
            stage1<<<10,10>>>(d_status,d_q_curlen,d_q_nexlen,d_S_len,d_ends_len,d_q_cur,d_q_next,d_sigma,d_delta,d_S,d_ends,d_dist,d_depth,d_no_nodes,d_edges);
            stage1_1<<<10,10>>>(d_status,d_q_curlen,d_q_nexlen,d_S_len,d_ends_len,d_q_cur,d_q_next,d_sigma,d_delta,d_S,d_ends,d_dist,d_depth,d_no_nodes,d_edges);
            cudaMemcpy(&h_status, d_status, sizeof(bool), cudaMemcpyDeviceToHost);
            printf("rwlb\ns %d \n",h_status);
            if(h_status == false)
                break;
        }
        
        cudaMemcpy(&h_depth,d_depth,sizeof(int),cudaMemcpyDeviceToHost);
        cudaMemcpy(h_ends,d_ends,no_nodes * sizeof(int),cudaMemcpyDeviceToHost);

        int counter = h_depth;

        while(counter >= 0){
            int offset = ends[depth];
            int itr = ends[depth + 1] - 1 - offset;

            int blocks = ceil((float)itr/size);
            stage2<<<blocks,size>>>(d_delta, d_dist, d_sigma, d_S, d_edges, offset, itr);
            counter --;
        }

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