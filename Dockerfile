FROM continuumio/miniconda3

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

RUN apt-get update && apt-get install -y git software-properties-common gnupg

RUN conda install torchvision torchaudio pytorch-cuda=11.7 git -c pytorch -c nvidia

COPY requirements.txt /app/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip pip install -r /app/requirements.txt

COPY extensions/ /app/extensions/
RUN --mount=type=cache,target=/root/.cache/pip pip install -r /app/extensions/google_translate/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip pip install -r /app/extensions/silero_tts/requirements.txt

COPY . /app
ENV CONDA_EXE=/opt/conda/bin/conda
ENV CONDA_PREFIX=/opt/conda
ENV CONDA_PYTHON_EXE=/opt/conda/bin/python
#CMD deepspeed --num_gpus=1 server.py --deepspeed --auto-devices --cai-chat --load-in-8bit --listen --listen-port=8888
CMD python server.py --auto-devices --load-in-8bit --listen --listen-port=8888 --model=opt-1.3b