#!/bin/bash

# Workaround for issue: https://github.com/qwopqwop200/GPTQ-for-LLaMa/issues/31
# sed -i 's/if checkpoint\.endswith/if checkpoint\.as_posix\(\).endswith/' /app/repositories/GPTQ-for-LLaMa/llama.py

if [ ! -e "/opt/conda/lib/libcudart.so" ] ; then
    echo "Fixing symlink for libcudart.so"
    rm /opt/conda/lib/libcudart.so
    ln -s /usr/local/cuda/lib64/libcudart.so.11.7.* /opt/conda/lib/libcudart.so
fi
cd /app/repositories/GPTQ-for-LLaMa && python setup_cuda.py install
cd /app

python server.py --cai-chat --load-in-4bit --listen --listen-port=8888 --model=llama-7b