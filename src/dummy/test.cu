#include <iostream>
#define MAX 1000000

using namespace std;

typedef struct vertex
{
    int parents[10];
    int no_parents;
    bool visited;
    bool inQ;
    long long distance;
} Vertex;

typedef struct edge
{
    int tos[10];
    int no_to;
} Edge;

void call_bfs(int ** G);

__device__ void lock(int *mutex) {
	while (atomicCAS(mutex, 0, 1) != 0);
}

__device__ void unlock(int *mutex) {
	atomicExch(mutex, 0);
}

__global__
void bfs(bool * done, Vertex * vs, Edge * es, int no_nodes, int * mutex);

int main()
{ 
    int ** G = new int * [5];
    int B[5][5] = {
        {0, 1, 0, 1, 0},
        {1, 0, 1, 0, 0},
        {0, 1, 0, 1, 1},
        {1, 0, 1, 0, 0},
        {0, 0, 1, 0, 0},
    };
    
    for(int i = 0; i < 5; i++)
    {
        G[i] = new int[5];
        for(int j=0; j < 5; j++)
            G[i][j] = B[i][j];
    }

    call_bfs(G);

    return 0;
}

void call_bfs(int ** G)
{
    Vertex * h_vs = new Vertex[5];
    Vertex * d_vs;
    cudaMalloc((void **)&d_vs, 5 * sizeof(Vertex));

    Edge * h_es = new Edge[5]; 
    Edge * d_es;
    cudaMalloc((void **)&d_es, 5 * sizeof(Edge));

    for(int i=0; i < 5; i++)
    {
        h_vs[i].no_parents = 0;
        h_es[i].no_to = 0;

        h_vs[i].distance = MAX;
        h_vs[i].visited = false;
        h_vs[i].inQ = false;

        for(int j=0; j < 5; j++)
        {
            if(G[i][j] == 1)
            {
                h_es[i].tos[h_es[i].no_to] = j;
                h_es[i].no_to += 1;
            }
        }
    }

    h_vs[0].distance = 0;
    h_vs[0].inQ = 1;
    
    cudaMemcpy(d_vs, h_vs, 5 * sizeof(Vertex), cudaMemcpyHostToDevice);
    cudaMemcpy(d_es, h_es, 5 * sizeof(Edge), cudaMemcpyHostToDevice);
    
    bool h_done, *d_done;
    cudaMalloc((void **)&d_done, sizeof(bool));

    int * mutex;
    cudaMalloc((void **)&mutex, sizeof(int));

    while(true){
        h_done = true;
        cudaMemcpy(d_done, &h_done, sizeof(bool), cudaMemcpyHostToDevice);
        bfs<<<5, 5>>>(d_done, d_vs, d_es, 5, mutex);
        cudaMemcpy(&h_done, d_done, sizeof(bool), cudaMemcpyDeviceToHost);
        if(h_done == true)
            break;
    }
    
    cudaMemcpy(h_vs, d_vs, 5 * sizeof(Vertex), cudaMemcpyDeviceToHost);

    for(int i=0; i < 5; i++){
        Vertex node = h_vs[i];
        cout << "Node :" << i << endl;
        cout << "Distance: " << node.distance << endl << "No Of Parents: " << node.no_parents << endl << "Parents :";
        for(int j = 0; j < node.no_parents; j++){
            cout << node.parents[j] << "\t";
        }
        cout << endl << endl;
    }
}

__global__
void bfs(bool * done, Vertex * vs, Edge * es, int no_nodes, int * mutex)
{        
    long long int id = threadIdx.x + blockIdx.x * blockDim.x;

    if(id < no_nodes)
    {
        if(vs[id].inQ == true && vs[id].visited == false)
        {
            vs[id].visited = true;

            vs[id].inQ = false;

            __syncthreads();
            
            Edge temp = es[id];

            for(int i = 0; i < temp.no_to; i++)
            {
                int n_id = temp.tos[i];
                if(vs[n_id].visited == false)
                {
                    *done = false;
                    
                    if(vs[n_id].distance == vs[id].distance + 1)
                    {
                        vs[n_id].parents[vs[n_id].no_parents] = id;
                        vs[n_id].no_parents += 1;
                        vs[n_id].inQ = true;
                    }
                    else if(vs[n_id].distance > vs[id].distance + 1)
                    {
                        vs[n_id].parents[0] = id;
                        vs[n_id].no_parents = 1;
                        vs[n_id].distance = vs[id].distance + 1;
                        vs[n_id].inQ = true;
                    }
                    // printf("Visited and Done %d  %d\n", vs[n_id].visited, done);
                }
            }

            // printf("\n\n");
        }
    }
}
