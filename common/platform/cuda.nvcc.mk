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
OPTIMIZ_FLAGS=-O0 -Xcicc -O0
CUDACC=$(CUDAHOME)/bin/nvcc $(OPTIMIZ_FLAGS)
CUDALINK=$(CUDAHOME)/bin/nvcc $(OPTIMIZ_FLAGS)

# Flags
PLATFORM_CUDACFLAGS=-ccbin gcc-4.5.4 -gencode arch=compute_20,code=compute_20
PLATFORM_CUDALDFLAGS=-lm -lpthread


