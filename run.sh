#!/bin/bash

# Workaround for issue: https://github.com/qwopqwop200/GPTQ-for-LLaMa/issues/31
# sed -i 's/if checkpoint\.endswith/if checkpoint\.as_posix\(\).endswith/' /app/repositories/GPTQ-for-LLaMa/llama.py

if [ ! -e "/app/models/llama-7b" ] ; then
    echo "Downloading LLaMa model 7B (metadata)"
    if [ ! -e "/app/models/llama-7b-hf" ] ; then
        python download-model.py --text-only decapoda-research/llama-7b-hf
    fi
    mv /app/models/llama-7b-hf /app/models/llama-7b
fi
if [ ! -e "/app/models/llama-7b-4bit.pt" ] ; then
    echo "Downloading LLaMa model 7B (weights)"
    wget https://huggingface.co/decapoda-research/llama-7b-hf-int4/resolve/main/llama-7b-4bit.pt -O /app/models/llama-7b-4bit.pt --progress=dot:giga
fi

if [ ! -e "/opt/conda/lib/libcudart.so" ] ; then
    echo "Fixing symlink for libcudart.so"
    rm /opt/conda/lib/libcudart.so
    ln -s /usr/local/cuda/lib64/libcudart.so.11.7.* /opt/conda/lib/libcudart.so
fi

cd /app/repositories/GPTQ-for-LLaMa && python setup_cuda.py install
cd /app

python server.py --cai-chat --load-in-4bit --listen --listen-port=8888 --model=llama-7b