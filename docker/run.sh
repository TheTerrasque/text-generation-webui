#!/bin/bash

# Workaround for issue: https://github.com/qwopqwop200/GPTQ-for-LLaMa/issues/31
# sed -i 's/if checkpoint\.endswith/if checkpoint\.as_posix\(\).endswith/' /app/repositories/GPTQ-for-LLaMa/llama.py

model="llama-7b"

if [ ! -e "/app/models/$model" ] ; then
    echo "Downloading LLaMa model $model (metadata)"
    if [ ! -e "/app/models/$model-hf" ] ; then
        python download-model.py --text-only decapoda-research/$model-hf
    fi
    mv /app/models/$model-hf /app/models/$model
fi
if [ ! -e "/app/models/$model-4bit.pt" ] ; then
    echo "Downloading LLaMa model $model (weights)"
    wget https://huggingface.co/decapoda-research/$model-hf-int4/resolve/main/$model-4bit.pt -O /app/models/$model-4bit.pt --progress=dot:giga
fi

echo "Fixing LLaMa models (tokenizer)"
cd /app/models
find . -name '*.json' -exec sed -i -e 's/LLaMATokenizer/LlamaTokenizer/g' {} \;

if [ ! -e "/opt/conda/lib/libcudart.so" ] ; then
    echo "Fixing symlink for libcudart.so"
    rm /opt/conda/lib/libcudart.so
    ln -s /usr/local/cuda/lib64/libcudart.so.11.7.* /opt/conda/lib/libcudart.so
fi

cd /app/repositories/GPTQ-for-LLaMa && python setup_cuda.py install
cd /app

python server.py --cai-chat --gptq-bits 4 --listen --listen-port=8889 --model=$model