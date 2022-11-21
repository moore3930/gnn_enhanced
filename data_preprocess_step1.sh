DATA_DIR=/ivi/ilps/personal/dwu/datasets/multiparallel_enhanced/iwslt14
TRAIN_DATA_DIR=$DATA_DIR/train_data
VALID_DATA_DIR=$DATA_DIR/valid_data
TEST_DATA_DIR=$DATA_DIR/test_data
ZERO_SHOT_DATA_DIR=$DATA_DIR/zero_shot_data

TRAIN=train
VALID=valid
TEST=test

IWSLT_NAME=iwslt14_databin
ZERO_SHOT_IWSLT_NAME=iwslt14_zero_shot_databin

DICT=dict.txt

cd ${DATA_DIR}
# step-1 learn bpe
for SRC in en; do
    for TGT in ar de es fa he it nl pl; do
        cat ${TRAIN_DATA_DIR}/train.${SRC}-${TGT}.${SRC} ${TRAIN_DATA_DIR}/train.${SRC}-${TGT}.${TGT} >> train.all
    done
done
spm_train --input=train.all --model_prefix=spm.bpe --vocab_size=30000 --character_coverage=1.0 --model_type=bpe
cut -f1 spm.bpe.vocab | tail -n +4 | sed "s/$/ 100/g" > ${DICT}


# step-2.1 apply bpe
for SRC in en; do
    for TGT in ar de es fa he it nl pl; do
        spm_encode --model spm.bpe.model < ${TRAIN_DATA_DIR}/train.${SRC}-${TGT}.${SRC} > train.${SRC}-${TGT}.spm.${SRC}
        spm_encode --model spm.bpe.model < ${TRAIN_DATA_DIR}/train.${SRC}-${TGT}.${TGT} > train.${SRC}-${TGT}.spm.${TGT}
        spm_encode --model spm.bpe.model < ${VALID_DATA_DIR}/valid.${SRC}-${TGT}.${SRC} > valid.${SRC}-${TGT}.spm.${SRC}
        spm_encode --model spm.bpe.model < ${VALID_DATA_DIR}/valid.${SRC}-${TGT}.${TGT} > valid.${SRC}-${TGT}.spm.${TGT}
        spm_encode --model spm.bpe.model < ${TEST_DATA_DIR}/test.${SRC}-${TGT}.${SRC} > test.${SRC}-${TGT}.spm.${SRC}
        spm_encode --model spm.bpe.model < ${TEST_DATA_DIR}/test.${SRC}-${TGT}.${TGT} > test.${SRC}-${TGT}.spm.${TGT}
    done
done


# step-2.2 apply bpe for iwslt zero-shot
AR=('de' 'es' 'nl' 'it' 'pl' 'ar' 'fa' 'he')
for i in "${!AR[@]}"; do
    ((j=${i}+1))
    while [ $j -lt ${#AR[@]} ]
    do
        SRC=${AR[i]}
        TGT=${AR[j]}
        spm_encode --model spm.bpe.model < $ZERO_SHOT_DATA_DIR/zero_shot.$SRC-$TGT.$SRC > zero_shot.${SRC}-${TGT}.spm.${SRC}
        spm_encode --model spm.bpe.model < $ZERO_SHOT_DATA_DIR/zero_shot.$SRC-$TGT.$TGT > zero_shot.${SRC}-${TGT}.spm.${TGT}
        ((j=j+1))
    done
done


# step-3.1 binarize
for SRC in en; do
    for TGT in ar de es fa he it nl pl; do
        fairseq-preprocess \
          --source-lang ${SRC} \
          --target-lang ${TGT} \
          --trainpref ${TRAIN}.${SRC}-${TGT}.spm \
          --validpref ${VALID}.${SRC}-${TGT}.spm \
          --testpref ${TEST}.${SRC}-${TGT}.spm \
          --destdir ${IWSLT_NAME} \
          --thresholdtgt 0 \
          --thresholdsrc 0 \
          --srcdict ${DICT} \
          --tgtdict ${DICT} \
          --workers 70
    done
done


# step-3.2 binarize iwslt zero-shot
for i in "${!AR[@]}"; do
    ((j=${i}+1))
    while [ $j -lt ${#AR[@]} ]
    do
        SRC=${AR[i]}
        TGT=${AR[j]}
        fairseq-preprocess \
          --source-lang ${SRC} \
          --target-lang ${TGT} \
          --testpref zero_shot.${SRC}-${TGT}.spm \
          --destdir ${ZERO_SHOT_IWSLT_NAME} \
          --thresholdtgt 0 \
          --thresholdsrc 0 \
          --srcdict ${DICT} \
          --tgtdict ${DICT} \
          --workers 70
        ((j=j+1))
    done
done


# rm train.en-*
# rm test.en-*
# rm spm.bpe.*
