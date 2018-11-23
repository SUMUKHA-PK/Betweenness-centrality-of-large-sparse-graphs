#include<iostream>
#include<vector>

using namespace std;
int main()
{
    vector<vector<int> > v;
    for(int i=0;i<5;i++)
    {
        vector<int> f;
        if(i==1||i==2)
        {
            f.push_back(0);
        }
        if(i==3)
        {
            f.push_back(1);
            f.push_back(2);
        }
        if(i==4)
        {
            f.push_back(2);
        }
        v.push_back(f);
    }
    for(int i=0;i<5;i++)
    {
        for(int j=0;j<size(v[i]);j++)
        {
            cout<<v[i][j]<<" ";
        }
        cout<<endl;
    }
    long long int node = 4;
    dfs(vertex[node],0);
    return 0;
}
Item nodes = new Item;
int count=0;
void dfs(Vertex vertex)
{
    if(nodes->item!=NULL)
    {
        dfs(vertex[nodes.id]);
        nodes=nodes->item;
    }
    else
        count++;
}