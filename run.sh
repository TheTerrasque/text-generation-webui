#!/bin/bash

# Workaround for issue: https://github.com/qwopqwop200/GPTQ-for-LLaMa/issues/31
# sed -i 's/if checkpoint\.endswith/if checkpoint\.as_posix\(\).endswith/' /app/repositories/GPTQ-for-LLaMa/llama.py

cd /app/repositories/GPTQ-for-LLaMa && python setup_cuda.py install
cd /app

python server.py --cai-chat --load-in-4bit --listen --listen-port=8888 --model=llama-13b