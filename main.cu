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
    long long int a=0,b=0,count=0;
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
            else
            {
                n3[count-(a+b)]=stoi(x);
                x="";
                count++;
            }
        }
       c = fgetc(fp); 
    } 
    n3[a-1]=stoi(x);

    fclose(fp);
    return 0;
}