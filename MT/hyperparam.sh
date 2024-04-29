#!/bin/bash

set -e

FAIRSEQ_DIR=fairseq

######## Command line arguments ########
TGT_FILE=$1
SRC_FILE=$2

DATA_DIR=$3/${SRC_FILE}_${TGT_FILE}
SAVE_DIR=$4


NORM_PUNC=mosesdecoder/scripts/tokenizer/normalize-punctuation.perl
TOKENIZER=mosesdecoder/scripts/tokenizer/tokenizer.perl
DETOKENIZER=mosesdecoder/scripts/tokenizer/detokenizer.perl
FAIRSEQ_PREPROCESS=fairseq-preprocess
FAIRSEQ_TRAIN=fairseq-train
FAIRSEQ_GENERATE=fairseq-generate

EVALUATE="python evaluate.py"

MODELS=${SAVE_DIR}/models/${SRC_FILE}_${TGT_FILE}
CHECKPOINTS=${SAVE_DIR}/checkpoints/${SRC_FILE}_${TGT_FILE}
LOGS=${SAVE_DIR}/logs/${SRC_FILE}_${TGT_FILE}
TRANSLATIONS=${SAVE_DIR}/translations/${SRC_FILE}_${TGT_FILE}
DATA_OUT=${SAVE_DIR}/data_out/${SRC_FILE}_${TGT_FILE}

# Call hyperparameter tuning script
python hyperparam_tuning.py "$FAIRSEQ_TRAIN" "$DATA_OUT" "$SRC_FILE" "$TGT_FILE" "$CHECKPOINTS"
