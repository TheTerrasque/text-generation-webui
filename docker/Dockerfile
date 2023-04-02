FROM continuumio/miniconda3

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

RUN apt-get update && apt-get install -y git software-properties-common build-essential gnupg ninja-build dos2unix && apt-get clean

RUN conda install torchvision torchaudio pytorch-cuda=11.7 cuda -c pytorch  -c nvidia/label/cuda-11.7.1 && conda clean -a

COPY requirements.txt /app/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip pip install -r /app/requirements.txt

COPY extensions/ /app/extensions/
RUN --mount=type=cache,target=/root/.cache/pip pip install -r /app/extensions/google_translate/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip pip install -r /app/extensions/silero_tts/requirements.txt

ENV CONDA_EXE=/opt/conda/bin/conda
ENV CONDA_PREFIX=/opt/conda
ENV CONDA_PYTHON_EXE=/opt/conda/bin/python

RUN mkdir repositories 
#RUN cd repositories && git clone https://github.com/qwopqwop200/GPTQ-for-LLaMa && cd GPTQ-for-LLaMa && git reset --hard aa20d1290b96b20b82f5299602b1663e9458c6cd
#RUN cd repositories/GPTQ-for-LLaMa && pip install -r requirements.txt

# https://github.com/oobabooga/text-generation-webui/issues/716
RUN cd repositories && git clone https://github.com/oobabooga/GPTQ-for-LLaMa.git -b cuda && cd GPTQ-for-LLaMa && git reset --hard 9659310499cc7a0ea5498c1beb47bb228d65d178



COPY . /app
COPY ./docker/run.sh /app/run.sh
RUN dos2unix /app/run.sh

CMD bash run.sh