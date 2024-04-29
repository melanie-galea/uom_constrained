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

pip list


# UNCOMMENT

pip uninstall -y numpy
pip install numpy==1.21.0
pip uninstall -y typing_extensions
pip uninstall -y fastapi
pip install --no-cache fastapi


#pip uninstall -y numpy
#pip install numpy
#pip uninstall -y typing_extensions
#pip uninstall -y fastapi
#pip install --no-cache fastapi
#pip install sentencepiece


echo "################ Starting training ################"


#echo $DATA_OUT
#echo $EPOCHS
## UNCOMMENT
${FAIRSEQ_TRAIN} \
    $DATA_OUT \
    --source-lang $SRC_FILE --target-lang $TGT_FILE \
    --arch lstm  \
    --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
    --criterion label_smoothed_cross_entropy --label-smoothing 0.2 \
    --lr-scheduler inverse_sqrt --warmup-updates 10000 --warmup-init-lr 1e-7 --lr 1e-3 --max-tokens-valid 2048   --weight-decay 0.0001 \
    --dropout 0.1 \
    --max-update 1000000 --validate-interval-updates 1000\
    --save-interval 15 \
    --save-dir $CHECKPOINTS \
    --max-tokens 2048 --max-source-positions 1024 --max-target-positions 1024 \
    --validate-interval 1 \
    --eval-bleu --eval-bleu-detok "space" --eval-bleu-args '{"beam": 5}' --eval-bleu-print-samples --patience 10 --best-checkpoint-metric "bleu" --maximize-best-checkpoint-metric \
    --encoder-bidirectional
    #--max-epoch 1 \
    #--encoder-embed-dim 2 --encoder-hidden-size 2 \
    #--decoder-embed-dim 2 --decoder-hidden-size 2 \


echo "################ Done training, starting evaluation ################"

${FAIRSEQ_GENERATE} \
      $DATA_OUT   \
    --source-lang $SRC_FILE --target-lang $TGT_FILE \
    --path $CHECKPOINTS/checkpoint_best.pt \
    --beam 5 \
    --gen-subset test --batch-size 32 --max-tokens-valid 8196 --skip-invalid-size-inputs-valid-test  > $TRANSLATIONS/${SRC_FILE}_${TGT_FILE}.out
echo "################ Done fairseq-generate ################"

# copy only the hypothesises to results/data_out/translations/mt_en.bpe.hyp
cat $TRANSLATIONS/${SRC_FILE}_${TGT_FILE}.out | grep -P "^H" |sort -V |cut -f 3- | sed 's/\[ro_RO\]//g'  > $TRANSLATIONS/${SRC_FILE}_${TGT_FILE}.bpe.hyp
# copy the same to results/data_out/translations/mt_en.bpe.hyp.tokenized
cp $TRANSLATIONS/${SRC_FILE}_${TGT_FILE}.bpe.hyp $TRANSLATIONS/${SRC_FILE}_${TGT_FILE}.bpe.hyp.tokenized

echo "################ SP TOOLS################"

python sp_tools.py \
  --decode \
  --src $TRANSLATIONS/${SRC_FILE}_${TGT_FILE}.bpe.hyp.tokenized \
  --tgt $TRANSLATIONS/${SRC_FILE}_${TGT_FILE}.bpe.hyp \
  --model_dir ${MODELS}/




cp $TRANSLATIONS/${SRC_FILE}_${TGT_FILE}.bpe.hyp $TRANSLATIONS/${SRC_FILE}_${TGT_FILE}.bpe.hyp.detokenized


echo "################ Done decoding ################"
# echo  $TRANSLATIONS/${SRC_FILE}_${TGT_FILE}.bpe.hyp.detokenized  /netscratch/abela/opus_data_fixed/test.${TGT_FILE}


echo "################ Generating Metrics on Test Data ################"
${EVALUATE} \
  --system_output $TRANSLATIONS/${SRC_FILE}_${TGT_FILE}.bpe.hyp.detokenized \
  --gold_reference  original/${SRC_FILE}_${TGT_FILE}/test.${TGT_FILE}
