//Sumukha Pk 16CO145
//Prajval M  16CO234

#include<cuda.h>
#include<stdio.h>

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
        else if(c>='0'&&c<='9') count++;
        c = fgetc(fp); 
    } 
    fclose(fp);
    fp = fopen("file.txt", "r");
    c = fgetc(fp);
    long long int *n1 = (long long int *)malloc(a*sizeof(long long int));
    long long int *n2 = (long long int *)malloc(b*sizeof(long long int));
    long long int *n3 = (long long int *)malloc(a*sizeof(long long int));
    count=0;
    while (c != EOF) 
    { 
        if(c>='0'&&c<='9')
        {
            if(count<a)
            {
                n1[count]=c-'0';
                count++;
            }   
            else if(count>=a&&count<(a+b))
            {
                n2[count-(a)]=c-'0';
                count++;
            }
            else
            {
                n3[count-(a+b)]=c-'0';
                count++;
            }
       } 
       c = fgetc(fp); 
    } 
    for(int i=0;i<a;i++)
        printf("%lld ",n1[i]);
    printf("\n");
    for(int i=0;i<b;i++)
        printf("%lld ",n2[i]);
    printf("\n");
    for(int i=0;i<a;i++)
        printf("%lld ",n3[i]);
    
    fclose(fp);
    return 0;
}