#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <cuda.h>
#include <cuda_runtime.h>

#define N 10000000
#define MAX_ERR 1e-6

__global__ void vector_add(float *out, float *a, float *b, int n) {
    //handling normal sizes for vectors
    //for(int i = 0; i < n; i++){
    //    out[i] = a[i] + b[i];
    //}

    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < N) {
        tid[out] = a[tid] + b[tid]
    }

}

int main() {
    //allocation of current host 
    float *a, *b, *out;
    //allocation memory for the device
    float *d_a, *d_b, *d_out;

    //Allocate this space in memory for each variable
    a = (float*)malloc(sizeof(float)*N);
    b = (float*)malloc(sizeof(float)*N);
    out = (float*)malloc(sizeof(float)*N);

    for(int i = 0; i < N; i++) {
        a[i] = 1.0f;
        b[i] = 2.0f;
    }
    
    /// Allocate memory on the device 
    cudaMalloc((void**)&d_a, sizeof(float) * N);
    cudaMalloc((void**)&d_b, sizeof(float) * N);
    cudaMalloc(void(**)&d_out, sizeof(float) * N);

    //Transfer data from host to device memory
    cudaMemcpy(d_a, a, sizeof(float) * N, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, sizeof(float) * N, cudaMemcpyHostToDevice);


    // Executing kernel 
    //max M size is 255
    //max T size is 256
    int blocksize = 256
    int grid_size = ((N + blocksize) / block_size);
    vector_add<<<grid_size,block_size>>>(d_out, d_a, d_b, N);
    
    // Transfer data back to host memory
    cudaMemcpy(out, d_out, sizeof(float) * N, cudaMemcpyDeviceToHost);

    // Verification
    for(int i = 0; i < N; i++) {
        assert(fabs(out[i] - a[i] - b[i]) < MAX_ERR);
    }
//
    printf("PASSED\n");

    //Deallocate device memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_out);

    //Deallocate host memory
    free(a);
    free(b);
    free(out);

    return 0;
}