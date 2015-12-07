/***************************************************************************
 *cr
 *cr            (C) Copyright 2007 The Board of Trustees of the
 *cr                        University of Illinois
 *cr                         All Rights Reserved
 *cr
 ***************************************************************************/
#ifndef _PRESCAN_CU_
#define _PRESCAN_CU_

#include <assert.h>
#include "model.h"
#include <math.h>

#define WARP_SIZE 32
#define NUM_BANKS 16
#define LOG_NUM_BANKS 4

#define BLOCK_SIZE 256
#define NUM_WARPS (BLOCK_SIZE/WARP_SIZE)
#define HISTS_PER_WARP 16
#define NUM_HISTOGRAMS  (NUM_WARPS*HISTS_PER_WARP)
#define THREADS_PER_HIST (WARP_SIZE/HISTS_PER_WARP)

REAL** g_scanBlockSums;
unsigned int g_numEltsAllocated = 0;
unsigned int g_numLevelsAllocated = 0;

__constant__ REAL dev_binb[NUM_BINS+1];

unsigned int NUM_SETS;
unsigned int NUM_ELEMENTS;

// create the bin boundaries
void initBinB( struct pb_TimerSet *timers )
{
  REAL *binb = (REAL*)malloc((NUM_BINS+1)*sizeof(REAL));
  for (int k = 0; k < NUM_BINS+1; k++)
    {
      binb[k] = cos(pow(10.0, (log10(min_arcmin) + k*1.0/bins_per_dec)) 
		    / 60.0*D2R);
    }
  pb_SwitchToTimer( timers, pb_TimerID_COPY );
  cudaMemcpyToSymbol(dev_binb, binb, (NUM_BINS+1)*sizeof(REAL));
  pb_SwitchToTimer( timers, pb_TimerID_COMPUTE );
  free(binb);
}

__global__ 
void gen_hists( hist_t* histograms, REAL* all_x_data, REAL* all_y_data, 
		REAL* all_z_data, int NUM_SETS, int NUM_ELEMENTS )
{
  unsigned int bx = blockIdx.x;
  unsigned int tid = threadIdx.x;
  bool do_self = (bx < (NUM_SETS + 1));

  REAL* data_x;
  REAL* data_y;
  REAL* data_z;
  REAL* random_x;
  REAL* random_y;
  REAL* random_z;

  __shared__ struct cartesian data_s[BLOCK_SIZE];
  
  __shared__ unsigned int 
    warp_hists[NUM_BINS][NUM_HISTOGRAMS]; // 640B <1k  
   
	//initialize all warp_hists block
	//initialization is intrinsic by default
	__asm__("INTRN:");	 
  for(unsigned int w = 0; w < NUM_BINS*NUM_HISTOGRAMS; w += BLOCK_SIZE )
    {
	__asm__("INTRN:");	 
      if(w+tid < NUM_BINS*NUM_HISTOGRAMS)
	{
	  warp_hists[(w+tid)/NUM_HISTOGRAMS][(w+tid)%NUM_HISTOGRAMS] = 0;
	}
	__asm__("INTRN:");	 
    }
    

 // Get stuff into shared memory to kick off the loop.

	//Again: data structure initialization based on 
	//thread id. This is intrinsic
	__asm__("INTRN:");	 
  if( !do_self)
    {
      data_x = all_x_data;
      data_y = all_y_data;
      data_z = all_z_data;
      random_x = all_x_data + NUM_ELEMENTS * (bx - NUM_SETS);
      random_y = all_y_data + NUM_ELEMENTS * (bx - NUM_SETS);
      random_z = all_z_data + NUM_ELEMENTS * (bx - NUM_SETS);
    }
	__asm__("INTRN:");	 
  else
    {
      random_x = all_x_data + NUM_ELEMENTS * (bx);
      random_y = all_y_data + NUM_ELEMENTS * (bx);
      random_z = all_z_data + NUM_ELEMENTS * (bx);
      
      data_x = random_x;
      data_y = random_y;
      data_z = random_z;
    }
    
  // Iterate over all data points
	__asm__("EXTRN:");	//data bound check, extrinsic
	//This for loops is a data loading loop
  for(unsigned int i = 0; i < NUM_ELEMENTS; i += BLOCK_SIZE )
    {
      // load current set of data into shared memory
      // (total of BLOCK_SIZE points loaded)
	__asm__("EXTRN:");	//data bound check, extrinsic	
      if( tid + i < NUM_ELEMENTS )
	{ // reading outside of bounds is a-okay
	  data_s[tid] = (struct cartesian)
            {data_x[tid + i], data_y[tid + i], data_z[tid + i]};
	}
      
      __syncthreads();

      // Iterate over all random points

	//TODO: Conditional statement in for initialization
	__asm__("EXTRN:");	//data bound check, extrinsic	
      for(unsigned int j = (do_self ? i+1 : 0); j < NUM_ELEMENTS; 
	  j += BLOCK_SIZE)
	{
	  // load current random point values
	  REAL random_x_s;
	  REAL random_y_s;
	  REAL random_z_s;
	  
	__asm__("EXTRN:");	//data bound check, extrinsic	
	  if(tid + j < NUM_ELEMENTS)
	    {
	      random_x_s = random_x[tid + j];
	      random_y_s = random_y[tid + j];
	      random_z_s = random_z[tid + j];
	    }

	  // Iterate for all elements of current set of data points 
	  // (BLOCK_SIZE iterations per thread)
	  // Each thread calcs against 1 random point within cur set of random
	  // (so BLOCK_SIZE threads covers all random points within cur set)
	//TODO: check tow cconsitions in for
	__asm__("EXTRN:");	//data bound check, extrinsic	
	__asm__("EXTRN:");	//data bound check, extrinsic	
	  for(unsigned int k = 0; 
	      (k < BLOCK_SIZE) && (k+i < NUM_ELEMENTS);
	      k += 1)
	    {
	      // do actual calculations on the values:
	      REAL distance = 
	        data_s[k].x * random_x_s +
		    data_s[k].y * random_y_s +
		    data_s[k].z * random_z_s;

	      unsigned int bin_index;

	      // run binary search to find bin_index
	      unsigned int min = 0;
	      unsigned int max = NUM_BINS;
		//binary search, all branches intrinsic
	      {
		unsigned int k2;
	      	
		__asm__("INTRN:");	//TODO: (Check) for the while
		while (max > min+1)
		  {
		    k2 = (min + max) / 2;
			__asm__("INTRN:");//if
		    if (distance >= dev_binb[k2]) 
		      max = k2;
			__asm__("INTRN:");//else
		    else 
		      min = k2;
		__asm__("INTRN:");	//for the while
		  }
		bin_index = max - 1;
	      }

	      unsigned int warpnum = tid / (WARP_SIZE/HISTS_PER_WARP);
		//TODO; complicated if statement
		__asm__("INTRN:");
		__asm__("INTRN:");
		__asm__("INTRN:");
		__asm__("INTRN:");
		__asm__("EXTRN:");
	      if((distance < dev_binb[min]) &&	//intrinsic 
		(distance >= dev_binb[max]) && 	//intrinsic
		//TODO: check if or creates 2 conditions
		(!do_self || 			//intrinsic
		(tid + j > i + k)) && 		//intrinsic
		(tid + j < NUM_ELEMENTS))	//extrinsic
		{
		  atomicAdd(&warp_hists[bin_index][warpnum], 1U);
		}
		//TODO: check two consitions for for
		__asm__("EXTRN:");	//data bound check, extrinsic	
		__asm__("EXTRN:");	//data bound check, extrinsic	
	    }
	__asm__("EXTRN:");	//end of for/data bound check, extrinsic	
	}
	__asm__("EXTRN:");	//end of first for, 	
				//data bound check, extrinsic
    }
    
  // coalesce the histograms in a block
  unsigned int warp_index = tid & ( (NUM_HISTOGRAMS>>1) - 1);
  unsigned int bin_index = tid / (NUM_HISTOGRAMS>>1);
	__asm__("INTRN:");	//intrinsic because
	//the loop must continue until the offset is nil
  for(unsigned int offset = NUM_HISTOGRAMS >> 1; offset > 0; 
      offset >>= 1)
    {
	__asm__("EXTRN:")	//data bound check
      for(unsigned int bin_base = 0; bin_base < NUM_BINS; 
	  bin_base += BLOCK_SIZE/ (NUM_HISTOGRAMS>>1))
	{
	  __syncthreads();

		__asm__("INTRN:");	//check if the current
		//warp is meant to fill this bin of historgram
		__asm__("EXTRN:");	//data bound check	
	  if(warp_index < offset 	//intrinsic
		&& bin_base+bin_index < NUM_BINS )	//extrinsic
	    {
	      unsigned long sum =
		warp_hists[bin_base + bin_index][warp_index] + 
		warp_hists[bin_base + bin_index][warp_index+offset];
	      warp_hists[bin_base + bin_index][warp_index] = sum;
	    }
	__asm__("EXTRN:")	//end of for, data bound check
	}
	__asm__("INTRN:");	//end of previous for, intrinsic
    }
    
  __syncthreads();
    
  // Put the results back in the real histogram
  // warp_hists[x][0] holds sum of all locations of bin x
  hist_t* hist_base = histograms + NUM_BINS * bx;
	__asm__("EXTRN:");	//bound check on number of BINS
				//i.e. no. of pillars in histogram
				//extrinsic
  if(tid < NUM_BINS)
    {
      hist_base[tid] = warp_hists[tid][0];
    }
}

void TPACF(hist_t * histograms, REAL* d_x_data, REAL* d_y_data, 
	   REAL* d_z_data)
{
  dim3 dimBlock(BLOCK_SIZE);
  dim3 dimGrid(NUM_SETS*2 + 1);

  gen_hists <<< dimGrid, dimBlock >>> ( histograms, d_x_data, 
					d_y_data, d_z_data, NUM_SETS, 
					NUM_ELEMENTS);
}
// **===-----------------------------------------------------------===**


#endif // _PRESCAN_CU_
