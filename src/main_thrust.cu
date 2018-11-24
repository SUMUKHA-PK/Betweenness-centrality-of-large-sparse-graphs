#include <iostream>
#include <vector>
#include <math.h>

#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/functional.h>
#include <thrust/transform.h>
#include <thrust/extrema.h>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#define THREADS 64

using namespace std;
using namespace thrust;

typedef struct vertex {
    int parents[15];
    int no_parents;
    int distance;
    bool done;
} Vertex;

typedef struct qu {
    int id;
    int distance;
} Queue;

typedef struct edge{
    int tos[10];
    int no_to;
} Edge;

struct compare_key_value{
    __host__ __device__
    bool operator()(Queue l, Queue r) {
        return l.distance < r.distance;
    }
};

struct compare_key_value qSelector;

int ExtractMin(device_vector<Queue> &queue){

    device_vector<Queue>::iterator t = min_element(queue.begin(), queue.end(), qSelector);

    Queue x = *t;
    
    cout << x.distance << endl;

    queue.erase(t);

    return x.id;
}

__global__
void relax(Vertex * nodes, int * edges, int id, int no_edges){
    int idx = threadIdx.x + blockDim.x * blockIdx.x;

    nodes[id].done = true;

    __syncthreads();

    if(idx < no_edges){
        if(nodes[edges[idx]].done == false){
            // printf("%d %d %d %d\n", nodes[edges[idx]].distance, nodes[id].distance + 1, edges[idx], id);
            if(nodes[edges[idx]].distance == nodes[id].distance + 1){
                nodes[edges[idx]].parents[nodes[edges[idx]].no_parents - 1] = id;
                nodes[edges[idx]].no_parents += 1;
            }
            if(nodes[edges[idx]].distance > nodes[id].distance + 1){
                nodes[edges[idx]].distance = nodes[id].distance + 1;
                nodes[edges[idx]].parents[nodes[edges[idx]].no_parents] = id;
                nodes[edges[idx]].no_parents = 1;
            }
        }
    }

}

int dijkstra(int source, int target, int no_nodes, vector<Edge> es){

    host_vector<Vertex> h_nodes(no_nodes);
    host_vector<Queue> h_queue(no_nodes);
    host_vector<Edge> h_edges(es);

    for(int i = 0; i < no_nodes; i++){
        h_queue[i].id = i;
        h_queue[i].distance = INT_MAX;
        h_nodes[i].distance = INT_MAX;
        h_nodes[i].no_parents = 0;
        h_nodes[i].done = false;
    }

    h_queue[source].distance = 0;
    h_nodes[source].distance = 0;

    device_vector<Vertex> d_nodes(h_nodes);
    device_vector<Queue> d_queue(h_queue);

    Vertex * d_nodes_ptr = raw_pointer_cast(d_nodes.data());
    
    for(int i = 0; i < no_nodes - 1; i++){
        int id = ExtractMin(d_queue);
        cout << "ID  :" << id << endl; 
        int no_edges = h_edges[id].no_to;
        int * edges;

        cudaMalloc((void **)&edges, no_edges*sizeof(int));
        cudaMemcpy(edges, h_edges[id].tos, no_edges*sizeof(int), cudaMemcpyHostToDevice);

        for(int i=0; i<no_edges; i++){
            cout << h_edges[id].tos[i] << "\t";
        }
        
        int blocks = ceil((float)no_edges/THREADS);
        relax<<<blocks, THREADS>>>(d_nodes_ptr, edges, id, no_edges);
        cout << endl << endl;
    }
    cout << endl << endl;

    for(int i=0; i < no_nodes; i++){
        Vertex temp = d_nodes[i];
        cout << i << " " << temp.distance << " " << temp.no_parents << " " << endl;
    }

    return 0;
}

int main(){

    int B[5][5] = {
        {0, 1, 0, 1, 0},
        {1, 0, 1, 0, 0},
        {0, 1, 0, 1, 1},
        {1, 0, 1, 0, 0},
        {0, 0, 1, 0, 0},
    };

    vector<Edge> es; 

    for(int i=0; i < 5; i++){
        Edge temp;
        temp.no_to = 0;

        es.push_back(temp);

        for(int j=0; j < 5; j++){
            if(B[i][j] == 1){
                es[i].tos[es[i].no_to] = j;
                es[i].no_to += 1;
            }
        }
    }

    dijkstra(0, 4, 5, es);
}