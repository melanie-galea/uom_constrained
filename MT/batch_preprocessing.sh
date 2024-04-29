#!/bin/bash
# let's set the following defaults (can be overriden on commandline):
#SBATCH --job-name baseline_preprocessing_ar
#SBATCH --partition RTXA6000
#SBATCH --mem=80G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=kurtjosephabela@gmail.com

srun  --container-image=/netscratch/enroot/nvcr.io_nvidia_tensorflow_21.12-tf2-py3.sqsh   --container-workdir="`pwd`"   --container-mounts=/netscratch/$USER:/netscratch/$USER,/ds:/ds:ro,"`pwd`":"`pwd`"  --task-prolog="`pwd`/install.sh" preprocessing.sh   en  ar    data_arabic/ results_arabic/ 
srun  --container-image=/netscratch/enroot/nvcr.io_nvidia_tensorflow_21.12-tf2-py3.sqsh   --container-workdir="`pwd`"   --container-mounts=/netscratch/$USER:/netscratch/$USER,/ds:/ds:ro,"`pwd`":"`pwd`"  --task-prolog="`pwd`/install.sh" preprocessing.sh   en  ar    data_arabic_large/ results_large_arabic
srun  --container-image=/netscratch/enroot/nvcr.io_nvidia_tensorflow_21.12-tf2-py3.sqsh   --container-workdir="`pwd`"   --container-mounts=/netscratch/$USER:/netscratch/$USER,/ds:/ds:ro,"`pwd`":"`pwd`"  --task-prolog="`pwd`/install.sh" preprocessing.sh   en  ar    data_arabic_lstm/ results_lstm_arabic/ 
