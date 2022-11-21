# language order: 'de' 'es' 'nl' 'it' 'pl' 'ar' 'fa' 'he'
DATA_DIR=iwslt14

rm -rf ${DATA_DIR}/alignments
mkdir ${DATA_DIR}/alignments

AR=('de' 'es' 'nl' 'it' 'pl' 'ar' 'fa' 'he')
EFLOMAL_DIR=/ivi/ilps/personal/dwu/tools/eflomal
FASTALIGN_DIR=/ivi/ilps/personal/dwu/tools/fast_align/build

rm ${DATA_DIR}/*.fwd
rm ${DATA_DIR}/*.rev
rm ${DATA_DIR}/*.align

for i in "${!AR[@]}"; do
    ((j=${i}+1))
    while [ $j -lt ${#AR[@]} ]
    do
        SRC=${AR[i]}
        TGT=${AR[j]}
        python ${EFLOMAL_DIR}/align.py -s ${DATA_DIR}/zero_shot.$SRC-$TGT.spm.$SRC -t ${DATA_DIR}/zero_shot.$SRC-$TGT.spm.$TGT --model 3 -f ${DATA_DIR}/$SRC-$TGT.fwd -r ${DATA_DIR}/$SRC-$TGT.rev
        ${FASTALIGN_DIR}/atools -i ${DATA_DIR}/$SRC-$TGT.fwd -j ${DATA_DIR}/$SRC-$TGT.rev -c grow-diag-final-and > ${DATA_DIR}/final.$SRC-$TGT.align
        ((j=j+1))
    done
done

# step-3 order
#mv ${DATA_DIR}/final.*.align ${DATA_DIR}/alignments
#mv ${DATA_DIR}/zero_shot.*.spm.* ${DATA_DIR}/alignments
