//Sumukha Pk 16CO145
//Prajval M  16CO234

#include<cuda.h>
#include<stdio.h>
#include<iostream>
#include<vector>
#include<string>
#include"graphs.h"

using namespace std;
using namespace graph;

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
    Edge * edges = new Edge[a];   //Number of edges is size of n1

    long long cc =0,cd=0,ignore=0;
    for(i=1;i<=dim1;i++)
    {
        long long x = n2[i]-n2[i-1];
        for(j=cc;j<cc+x;j++)
        {
            if((i-1)!=n3[j])
            {
                edges[cd].from=(i-1);
                edges[cd].to=n3[j];
                cd++;
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
    
    free(n1);
    free(n2);
    free(n3);
    free(n4);
//---------------------------------------------Graph is generated--------------------------

    return 0;
}