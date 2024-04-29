#!/bin/bash
# let's set the following defaults (can be overriden on commandline):
#SBATCH --job-name base
#SBATCH --partition RTXA6000
#SBATCH --gpus=1
#SBATCH --mem=50G
#SBATCH --ntasks=1
#SBATCH --time=01-00:00:00



srun   --container-image=/netscratch/enroot/nvcr.io_nvidia_pytorch_21.11-py3.sqsh  --container-workdir="`pwd`"   --container-mounts=/netscratch/$USER:/netscratch/$USER,/ds:/ds:ro,"`pwd`":"`pwd`"  --task-prolog="`pwd`/install.sh" run_baseline_system_base.sh  en   ar    data_arabic/ results_arabic/ 
srun   --container-image=/netscratch/enroot/nvcr.io_nvidia_pytorch_21.11-py3.sqsh  --container-workdir="`pwd`"   --container-mounts=/netscratch/$USER:/netscratch/$USER,/ds:/ds:ro,"`pwd`":"`pwd`"  --task-prolog="`pwd`/install.sh" run_baseline_system_base.sh  en   ar    data_arabic_mixed/ results_arabic_mixed/ 

