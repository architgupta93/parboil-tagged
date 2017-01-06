# (c) 2011 The Board of Trustees of the University of Illinois.

# Cuda-related definitions common to all benchmarks

########################################
# Variables
########################################

# c.default is the base along with CUDA configuration in this setting
include $(PARBOIL_ROOT)/common/platform/c.default.mk

# Paths
CUDA_PATH=$(MCUDA_PATH)/include

# Programs
OPTIMIZ_FLAGS=-O0 -Xcicc -O0
CUDACC=$(MCUDA_PATH)/bin/mcc_xmm $(OPTIMIZ_FLAGS)
CUDALINK=$(LINKER) $(OPTIMIZ_FLAGS)

# Flags
PLATFORM_CUDACFLAGS=-O3 
PLATFORM_CFLAGS= -I$(MCUDA_PATH)/include -D__MCUDA__
PLATFORM_CXXFLAGS= -I$(MCUDA_PATH)/include -D__MCUDA__
PLATFORM_CUDALDFLAGS=-lm -lpthread -L$(MCUDA_PATH)/lib -lmcuda


