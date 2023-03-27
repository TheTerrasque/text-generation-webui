#!/bin/bash

# Workaround for issue: https://github.com/qwopqwop200/GPTQ-for-LLaMa/issues/31
# sed -i 's/if checkpoint\.endswith/if checkpoint\.as_posix\(\).endswith/' /app/repositories/GPTQ-for-LLaMa/llama.py

model="alpaca-native-4bit"

if [ ! -e "/app/models/$model" ] ; then
    echo "Downloading LLaMa model $model"
    if [ ! -e "/app/models/$model" ] ; then
        python download-model.py ozcur/$model
    fi
fi
# if [ ! -e "/app/models/$model-4bit.pt" ] ; then
#     echo "Downloading LLaMa model $model (weights)"
#     wget https://huggingface.co/decapoda-research/$model-hf-int4/resolve/main/$model-4bit.pt -O /app/models/$model-4bit.pt --progress=dot:giga
# fi


if [ ! -e "/opt/conda/lib/libcudart.so" ] ; then
    echo "Fixing symlink for libcudart.so"
    rm /opt/conda/lib/libcudart.so
    ln -s /usr/local/cuda/lib64/libcudart.so.11.7.* /opt/conda/lib/libcudart.so
fi

cd /app/repositories/GPTQ-for-LLaMa && python setup_cuda.py install
cd /app

python server.py --cai-chat --wbits 4 --listen --listen-port=8889 --model=$model --groupsize=128