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

echo "start"


rm -rf ${DATA_DIR}/

mkdir -p ${DATA_DIR}/
cp -rf original_arabic/${SRC_FILE}_${TGT_FILE}/*.${SRC_FILE} ${DATA_DIR}/
cp -rf original_arabic/${SRC_FILE}_${TGT_FILE}/*.${TGT_FILE} ${DATA_DIR}/
mkdir -p ${MODELS} ${CHECKPOINTS} ${LOGS} ${DATA_OUT} ${TRANSLATIONS}


echo "################ Training SentencePiece tokenizer ################"
echo ${SRC_FILE}
python sp_tools.py \
  --train \
  --src ${SRC_FILE} \
  --tgt ${TGT_FILE} \
  --data_dir ${DATA_DIR}/ \
  --model_dir ${MODELS}/ \
  --vocab_size 32000

echo "################ Done training ################"

tail -n +4 ${MODELS}/sentencepiece.bpe.vocab | cut -f1 | sed 's/$/ 100/g' > $MODELS/fairseq.dict

echo "################ Tokenizing and preprocessing data ################"

echo "applying BPE next:"
python sp_tools.py \
  --encode \
  --src ${SRC_FILE} \
  --tgt ${TGT_FILE} \
  --data_dir ${DATA_DIR}/ \
  --data_out ${DATA_OUT}/ \
  --model_dir ${MODELS}/ \
  --vocab_size 32000

echo "################ Done tokenizing ################"

echo "################ Encoding Data ################"

${FAIRSEQ_PREPROCESS}  --source-lang $SRC_FILE --target-lang $TGT_FILE \
    --trainpref $DATA_OUT/train.bpe \
    --validpref $DATA_OUT/dev.bpe \
    --destdir $DATA_OUT \
    --srcdict $MODELS/fairseq.dict \
    --tgtdict $MODELS/fairseq.dict \
    --thresholdtgt 0 \
    --thresholdsrc 0 \
    --workers 4 \
    --testpref $DATA_OUT/test.bpe

echo "################ Done encoding ################"
