# CUDA toolkit installation path
RODINIA_DIR	:=/home/ag/bigdata/2_Gpgpu_Architecture/rodinia_3.0/cuda
OUTPUT_DIR	:=$(RODINIA_DIR)/.output
RUN_DIR		:=$(RODINIA_DIR)/.run
LOGS_DIR	:=$(RODINIA_DIR)/.logs
CONFIG_DIR	:=$(RODINIA_DIR)/.gpgpu_config_files
DATASET_DIR	:=$(RODINIA_DIR)/../data 

RUN_CUDA_DIR :=/home/ag/local/cuda-7.5
SIM_CUDA_DIR :=/home/ag/local/cuda-4.2

# CUDA toolkit libraries
RUN_CUDA_LIB_DIR := $(RUN_CUDA_DIR)/lib
SIM_CUDA_LIB_DIR := $(SIM_CUDA_DIR)/lib
ifeq ($(shell uname -m), x86_64)
     ifeq ($(shell if test -d $(CUDA_DIR)/lib64; then echo T; else echo F; fi), T)
     	RUN_CUDA_LIB_DIR := $(RUN_CUDA_DIR)/lib64
     	SIM_CUDA_LIB_DIR := $(SIM_CUDA_DIR)/lib64
     endif
endif

RUN_NVCC :=$(RUN_CUDA_DIR)/bin/nvcc
SIM_NVCC :=$(SIM_CUDA_DIR)/bin/nvcc
NVDISASM :=$(RUN_CUDA_DIR)/bin/nvdisasm
CUOBJDUMP:=$(SIM_CUDA_DIR)/bin/cuobjdump

NEW_NVCC :=$(NEW_CUDA_DIR)/bin/nvcc
OLD_NVCC :=$(OLD_CUDA_DIR)/bin/nvcc

CC := gcc-4.5.4
CCOPTS := -ccbin gcc-4.5.4
NVCCOPTS := -m64 -O0 -Xcicc -O0

CCFLAGS = ${CCOPTS}
CCFLAGS += -I../../common/inc
CCFLAGS += ${NVCCOPTS}

LDFLAGS =
LDFLAGS += ${NVCCOPTS}

CUBINFLAGS = -cubin

RUN_GENCODE_FLAGS +=-gencode arch=compute_50,code=sm_50
SIM_GENCODE_FLAGS +=-gencode arch=compute_20,code=compute_20
CUB_GENCODE_FLAGS +=-gencode arch=compute_20,code=sm_20

