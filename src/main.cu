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

    for(int i = 0; i < dim1; i++){
        cout << edges[i].no_neigh << endl;

        for(int j=0; j<edges[i].no_neigh; j++)
            cout << edges[i].neighbours[j] << "\t";

        cout << endl << endl;
    }

    free(n1);
    free(n2);
    free(n3);
    free(n4);
//---------------------------------------------Graph is generated--------------------------

    
    return 0;
}