#include<cuda.h>
#include<iostream>
using namespace std;

int n = 5;
int s=0;

__global__ void kernel(int *d,int *Q,int *Q2,int *R,int *sigma)
{
    int n = 5;
    int s=0;

    int idx = threadIdx.x;
    //Initialize d and sigma
    for(int k=idx; k<n; k+=blockDim.x) 
    {
        if(k == s)
        {
            d[k] = 0;
            sigma[k] = 1;
        }
        else
        {
            d[k] = INT_MAX;
            sigma[k] = 0;
        }
    }

    if(idx==4)
    {
        for(int i=0;i<5;i++)
            printf("%d ",d[i]);
        printf("D done\n");
        for(int i=0;i<5;i++)
            printf("%d ",Q[i]);
        printf("Q done\n");
        for(int i=0;i<5;i++)
            printf("%d ",Q2[i]);
        printf("Q2 done\n");
        for(int i=0;i<5;i++)
            printf("%d ",R[i]);
        printf("R done\n");
        for(int i=0;i<5;i++)
            printf("%d ",sigma[i]);
        printf("Sigma done\n");
    }
    

    __shared__ int Q_len;
    __shared__ int Q2_len;

    if(idx == 0)
    {
        Q[0] = s;
        Q_len = 1;
        Q2_len = 0;
    }
    __syncthreads();

    while(1)
    {
        for(int k=idx; k<Q_len; k+=blockDim.x)
        {
            int v = Q[k];
            for(int w=R[v]; w<R[v+1]; w++)
            {
                // Use atomicCAS to prevent duplicates
                if(atomicCAS(&d[w],INT_MAX,d[v]+1) == INT_MAX)
                {
                    int t = atomicAdd(&Q2_len,1);
                    Q2[t] = w;
                }
                if(d[w] == (d[v]+1))
                {
                    atomicAdd(&sigma[w],sigma[v]);
                }
            }
        }
        __syncthreads();

        if(Q2_len == 0)
        {
            //The next vertex frontier is empty, so we're done searching
            break;
        }
        else
        {
            for(int k=idx; k<Q2_len; k+=blockDim.x)
            {
                Q[k] = Q2[k];
            }

            __syncthreads();

            if(idx == 0)
            {
                Q_len = Q2_len;
                Q2_len = 0;
            }
            __syncthreads();
        }
    }
}

int main()
{
    int d[5]={0,0,0,0,0};
    int Q[5]={0,1,2,3,4};
    int Q2[5]={1,2,3,4,5};
    int R[5]={3,4,1,2,0};
    int sigma[5]={1,2,3,4,5};

    int *d_d,*d_Q,*d_Q2,*d_R,*d_sigma;

    cudaMalloc((void **)&d_d, 5 * sizeof(int));
    cudaMalloc((void **)&d_Q, 5 * sizeof(int));
    cudaMalloc((void **)&d_Q2, 5 * sizeof(int));
    cudaMalloc((void **)&d_R, 5 * sizeof(int));
    cudaMalloc((void **)&d_sigma, 5 * sizeof(int));

    cudaMemcpy(d_d, d, 5 * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_Q, Q, 5 * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_Q2, Q2, 5 * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_R, R, 5 * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_sigma, sigma, 5 * sizeof(int), cudaMemcpyHostToDevice);
    
    kernel<<<5,5>>>(d_d,d_Q,d_Q2,d_R,d_sigma);


    cudaMemcpy(d, d_d, 5*sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(Q, d_Q, 5*sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(Q2, d_Q2, 5*sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(R, d_R, 5*sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(sigma, d_sigma, 5*sizeof(int), cudaMemcpyDeviceToHost);

    for(int i=0;i<5;i++)
        cout<<d[i]<<" ";
    cout<<endl;
    for(int i=0;i<5;i++)
        cout<<Q[i]<<" ";
    cout<<endl;
    for(int i=0;i<5;i++)
        cout<<Q2[i]<<" ";
    cout<<endl;
    for(int i=0;i<5;i++)
        cout<<R[i]<<" ";
    cout<<endl;
    for(int i=0;i<5;i++)
        cout<<sigma[i]<<" ";
    cout<<endl;
    return 0;
}