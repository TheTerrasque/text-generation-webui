FROM continuumio/miniconda3

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

RUN apt-get update && apt-get install -y git software-properties-common build-essential gnupg ninja-build && apt-get clean

#RUN conda install torchvision torchaudio pytorch-cuda=11.7 git -c pytorch -c nvidia 
RUN --mount=type=cache,target=/root/.cache/pip pip install torch==1.12+cu113 -f https://download.pytorch.org/whl/torch_stable.html
RUN conda install cuda -c nvidia/label/cuda-11.3.0 -c nvidia/label/cuda-11.3.1

#RUN wget https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda_11.7.0_515.43.04_linux.run && sh cuda_11.7.0_515.43.04_linux.run --silent && rm cuda_11.7.0_515.43.04_linux.run
#RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/3bf863cc.pub && add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/ /" && add-apt-repository contrib && apt-get update && apt-get install -y cuda && apt-get clean


COPY requirements.txt /app/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip pip install -r /app/requirements.txt

COPY extensions/ /app/extensions/
RUN --mount=type=cache,target=/root/.cache/pip pip install -r /app/extensions/google_translate/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip pip install -r /app/extensions/silero_tts/requirements.txt

ENV CONDA_EXE=/opt/conda/bin/conda
ENV CONDA_PREFIX=/opt/conda
ENV CONDA_PYTHON_EXE=/opt/conda/bin/python

RUN mkdir repositories 
RUN cd repositories && git clone https://github.com/qwopqwop200/GPTQ-for-LLaMa && cd GPTQ-for-LLaMa && DISTUTILS_USE_SDK=1 python setup_cuda.py install

COPY . /app

#CMD deepspeed --num_gpus=1 server.py --deepspeed --auto-devices --cai-chat --load-in-8bit --listen --listen-port=8888
CMD python server.py --auto-devices --load-in-4bit --listen --listen-port=8888 --model=llama-13b