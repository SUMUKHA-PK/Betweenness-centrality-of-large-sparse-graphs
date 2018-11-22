//Sumukha Pk 16CO145
//Prajval M  16CO234

#include<cuda.h>
#include<stdio.h>
#include<iostream>
#include<vector>
#include<string>
using namespace std;

int main()
{
    FILE *fp;
    fp = fopen("file.txt", "r");
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
    fp = fopen("file.txt", "r");
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
    long long int *graph = (long long int *)malloc(dim1*dim2*sizeof(long long int));
    for(i=0;i<dim1;i++)
    {
        for(j=0;j<dim2;j++)
            *(graph+i*dim2+j)=0;
    }
    int cc=0;
    for(i=1;i<=dim1;i++)
    {
        long long int x = n2[i]-n2[i-1];
        for(j=cc;j<cc+x;j++)
        {
            *(graph+(i-1)*dim2+n3[j])=n1[j];
        }
        cc+=x;
    }
    for(i=0;i<dim1;i++)
    {
        for(j=0;j<dim2;j++)
            printf("%lld ",*(graph+i*dim2+j));
        printf("\n");
    }

//---------------------------------------------Graph is generated--------------------------

    
    return 0;
}