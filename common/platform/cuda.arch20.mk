# (c) 2007 The Board of Trustees of the University of Illinois.

# Cuda-related definitions common to all benchmarks

########################################
# Variables
########################################

# c.default is the base along with CUDA configuration in this setting
include $(PARBOIL_ROOT)/common/platform/c.default.mk

# Paths
CUDAHOME=/home/ag/local/cuda-4.2

# Programs
CUDACC=$(CUDAHOME)/bin/nvcc
CUDALINK=$(CUDAHOME)/bin/nvcc

# Flags
PLATFORM_CUDACFLAGS=-ccbin gcc-4.5.4 -gencode arch=compute_11,code=compute_11
PLATFORM_CUDALDFLAGS=-lm -lpthread


