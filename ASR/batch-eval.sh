#!/bin/bash
# let's set the following defaults (can be overriden on commandline):
#SBATCH --job-name deepspeech
#SBATCH --partition batch
#SBATCH --gpus=1
#SBATCH --mem=20G
#SBATCH --cpus-per-task=2
#SBATCH --time=00-09:00:00


#srun  --container-image=/netscratch/abela/test.sqsh  --container-workdir="`pwd`"   --container-mounts=/netscratch/$USER:/netscratch/$USER,/ds:/ds:ro,"`pwd`":"`pwd`"   eval.sh

srun  --container-image=/netscratch/abela/test.sqsh  --container-workdir="`pwd`"   --container-mounts=/netscratch/$USER:/netscratch/$USER,/ds:/ds:ro,"`pwd`":"`pwd`"   eval_masri.sh
