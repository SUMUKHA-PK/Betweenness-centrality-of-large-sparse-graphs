//Sumukha Pk 16CO145
//Prajval M  16CO234

#include<cuda.h>
#include<stdio.h>
#include<iostream>
#include<vector>
#include<string>
#include"graphs.cuh"

using namespace std;
using namespace graphs;

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

    long long int dim2=n4[0],dim1=n4[1];
    Edge * edges = new Edge[dim1];   //Number of edges is size of n1
    Vertex * vertices = new Vertex[dim2];

    for(i=0;i<dim1;i++)
        edges[i]->item=NULL;
    
    long long cc =0,cd=0,ignore=0;
    for(i=1;i<=dim1;i++)
    {
        vertices[i-1].id=i-1;
        long long x = n2[i]-n2[i-1];
        for(j=cc;j<cc+x;j++)
        {
            if((i-1)!=n3[j])
            {
                edges[i-1].from=(i-1);
                edges[cd].to=n3[j];
                cd++;
                Item * temp = edges[i-1].item;
                while(temp->item!=NULL)
                    temp=temp->item;
                Item *t = new Item;
                temp->item=t;
                t->item=NULL;
            }
            else
            {   
                ignore++;
            }
        }
        cc+=x;
    }
    a-=ignore;
    // for(i=0;i<a;i++)
    // {
    //     cout<<edges[i].from<<" "<<edges[i].to<<endl;
    // }
    
    for(i=a;i<2*a;i++)
    {
        edges[i].from=edges[i-a].to;
        edges[i].to=edges[i-a].from;
    }
    free(n1);
    free(n2);
    free(n3);
    free(n4);
//---------------------------------------------Graph is generated--------------------------

    
    return 0;
}