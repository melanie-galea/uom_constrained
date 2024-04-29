#!/bin/bash
# let's set the following defaults (can be overriden on commandline):
#SBATCH --job-name hyperparam_tuning_lstm
#SBATCH --partition RTXA6000
#SBATCH --gpus=1
#SBATCH --mem=50G
#SBATCH --ntasks=1
#SBATCH --time=03-00:00:00



srun   --container-image=/netscratch/enroot/nvcr.io_nvidia_pytorch_21.11-py3.sqsh  --container-workdir="`pwd`"   --container-mounts=/netscratch/$USER:/netscratch/$USER,/ds:/ds:ro,"`pwd`":"`pwd`"  --task-prolog="`pwd`/install.sh" hyperparam.sh  en   mt    data/ results_lstm/ 

