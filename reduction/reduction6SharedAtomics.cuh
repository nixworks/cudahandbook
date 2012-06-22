/*
 *
 * reduction6SharedAtomics.cuh
 *
 * Header for reduction using atomics in shared memory.
 *
 * Copyright (c) 2011-2012, Archaea Software, LLC.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions 
 * are met: 
 *
 * 1. Redistributions of source code must retain the above copyright 
 *    notice, this list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright 
 *    notice, this list of conditions and the following disclaimer in 
 *    the documentation and/or other materials provided with the 
 *    distribution. 
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

//
// reads N ints and writes an intermediate sum per block
// blockDim.x must be a power of 2!
//
__global__ void
Reduction6_kernel( int *out, const int *in, size_t N )
{
    extern __shared__ int shared_sum[];

    const int tid = threadIdx.x;
    if ( blockIdx.x == 0 && threadIdx.x == 0 ) {
        *out = 0;
    }
    shared_sum[threadIdx.x] = 0;
    __syncthreads();
    __threadfence();
    for ( size_t i = blockIdx.x*blockDim.x + tid;
          i < N;
          i += blockDim.x*gridDim.x ) {
        atomicAdd( &shared_sum[threadIdx.x], in[i] );
    }
    __syncthreads();
    __threadfence();
    atomicAdd( out, shared_sum[threadIdx.x] );
}

void
Reduction6( int *answer, int *partial, 
            const int *in, size_t N, 
            int numBlocks, int numThreads )
{
    
    Reduction6_kernel<<< 
        numBlocks, numThreads, numThreads*sizeof(int)>>>( 
            answer, in, N );
}