export PATH=/home/diwu/anaconda3/bin:$PATH
source activate py38cuda11
export CUDA_HOME="/usr/local/cuda-11.0"
export PATH="${CUDA_HOME}/bin:${PATH}"
export LIBRARY_PATH="${CUDA_HOME}/lib64:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="/home/diwu/cudalibs:/usr/lib64/nvidia:${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}"

TRAIN_DATA=/home/dwu/multiparallel_enhanced/iwslt14/iwslt14_databin

fairseq-train $TRAIN_DATA --save-dir /ivi/ilps/personal/dwu/checkpoints/gnn_enhanced/baseline --tensorboard-logdir /home/dwu/gitrepo/LaSS/tensorboard_logdir --langs de,nl,ar,he,en --lang-pairs de-en,en-de,nl-en,en-nl,ar-en,en-ar,he-en,en-he --arch transformer_iwslt_de_en --share-decoder-input-output-embed --dropout 0.1 --task translation_multi_simple_epoch --sampling-method temperature --sampling-temperature 2 --encoder-langtok src --decoder-langtok --criterion label_smoothed_cross_entropy --label-smoothing 0.1 --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 --lr 5e-4 --lr-scheduler inverse_sqrt --warmup-updates 4000 --weight-decay 0.0 --max-tokens 16384 --update-freq 2 --max-update 160000 --fp16 --patience 20 --save-interval-updates 1000 --keep-interval-updates 20 --no-epoch-checkpoints --seed 22 --log-format simple --log-interval 20 --skip-invalid-size-inputs-valid-test
