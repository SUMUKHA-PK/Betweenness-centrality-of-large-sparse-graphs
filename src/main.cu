//Sumukha Pk 16CO145
//Prajval M  16CO234

#include<cuda.h>
#include<stdio.h>
#include<iostream>
#include<vector>
#include<string>
#include <ctime>
#include"graphs.cuh"
#include"graphs.cu"

using namespace std;
using namespace graphs;

void printDevProp(cudaDeviceProp devProp){
    
    // printf("Compute Capability:            %d.%d\n",  devProp.major, devProp.minor);
    printf("Device Name:                   %s\n",  devProp.name);
    // printf("Total global memory:           %zu\n",  devProp.totalGlobalMem);
    // printf("Total shared memory per block: %zu\n",  devProp.sharedMemPerBlock);
    // printf("Total registers per block:     %d\n",  devProp.regsPerBlock);
    // printf("Warp size:                     %d threads\n",  devProp.warpSize);
    // printf("Maximum memory pitch:          %zu\n",  devProp.memPitch);
    // printf("Maximum threads per block:     %d\n",  devProp.maxThreadsPerBlock);
    // for (int i = 0; i < 3; ++i)
    // 	printf("Maximum dimension %d of block:  %d\n", i, devProp.maxThreadsDim[i]);
    // for (int i = 0; i < 3; ++i)
    // 	printf("Maximum dimension %d of grid:   %d\n", i, devProp.maxGridSize[i]);
    printf("Clock rate:                    %d\n",  devProp.clockRate);
    // printf("Total constant memory:         %zu\n",  devProp.totalConstMem);
    // printf("Texture alignment:             %zu\n",  devProp.textureAlignment);
    // printf("Concurrent copy and execution: %s\n",  (devProp.deviceOverlap ? "Yes" : "No"));
    // printf("Number of multiprocessors:     %d\n",  devProp.multiProcessorCount);
    // printf("Kernel execution timeout:      %s\n",  (devProp.kernelExecTimeoutEnabled ? "Yes" : "No"));
    return;
}

int main(int argc,char ** argv)
{
    FILE *fp;
    fp = fopen(argv[argc-1], "r");
    char c = fgetc(fp); 
    int flag = -1;
    long long int i,j,a=0,nnz=2,b=0,count=0;
    while (c != EOF) 
    { 
        if(c=='\n')
        {
            if(flag==-1)
            {
                a=count;
                count=0;
                flag++;
            }
            else if(flag==0)
            {
                b=count;
                count=0;
                flag++;
            }
        }
        else if(c==' ') ++count;
        c = fgetc(fp); 
    } 
    fclose(fp);
    fp = fopen(argv[argc-1], "r");
    c = fgetc(fp);
    long long int *n1 = (long long int *)malloc(a*sizeof(long long int));
    long long int *n2 = (long long int *)malloc(b*sizeof(long long int));
    long long int *n3 = (long long int *)malloc(a*sizeof(long long int));
    long long int *n4 = (long long int *)malloc(nnz*sizeof(long long int));
    count=0;
    string x = "";
    while (c != EOF) 
    { 
        if(c!=' ')
        {
            x+=c;
        } 
        else if(c==' '||c=='\n')
        {
            if(count<a)
            {
                n1[count]=stoi(x);
                x="";
                count++;
            }   
            else if(count>=a&&count<(a+b))
            {
                n2[count-(a)]=stoi(x);
                x="";
                count++;
            }
            else if(count>=(a+b)&&count<(2*a+b))
            {
                n3[count-(a+b)]=stoi(x);
                x="";
                count++;
            }
            else
            {
                n4[count-(2*a+b)]=stoi(x);
                x="";
                count++;
            }
        }
       c = fgetc(fp); 
    } 
    n4[1]=stoi(x);
    fclose(fp);

//-------------------------------------------File input done------------------------------

    long long int dim1=n4[1];
    Edge * edges = new Edge[dim1];   //Number of edges is size of n1
    
    long long cc =0,ignore=0;
    for(i=1;i<=dim1;i++)
    {
        edges[i-1].no_neigh=0;
        long long x = n2[i]-n2[i-1];
        for(j=cc;j<cc+x;j++)
        {
            if((i-1)!=n3[j])
            {
                edges[i-1].neighbours[edges[i-1].no_neigh] = n3[j];
                edges[i-1].no_neigh+=1;
            }
            else
            {   
                ignore++;
            }
        }
        cc+=x;
    }
    a-=ignore;

    cudaDeviceProp devProp;
    cudaGetDeviceProperties(&devProp, 0);

    printDevProp(devProp);

    cout << "Started Computing ...." << endl << endl;

    clock_t begin = clock();

    calculateBC(edges, dim1);    

    clock_t end = clock();
    
    double elapsed_secs = double(end - begin) / (CLOCKS_PER_SEC * 1000);

    cout << "Elapsed Time : " << elapsed_secs << endl;

    cout << endl << "Completed Computing ...." << endl;

    free(n1);
    free(n2);
    free(n3);
    free(n4);
//---------------------------------------------Graph is generated--------------------------

    
    return 0;
}