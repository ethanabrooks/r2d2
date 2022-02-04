# inspired by https://sourcery.ai/blog/python-docker/
FROM nvidia/cudagl:11.3.1-runtime-ubuntu18.04 as base
ENV LC_ALL C.UTF-8

# no .pyc files
ENV PYTHONDONTWRITEBYTECODE 1

# traceback on segfau8t
ENV PYTHONFAULTHANDLER 1

# use ipdb for breakpoints
ENV PYTHONBREAKPOINT=ipdb.set_trace

# common dependencies
RUN apt-get update -q \
 && DEBIAN_FRONTEND="noninteractive" \
    apt-get install -yq \
      # video recording
      ffmpeg \

      # git-state
      git \

      # EGL for rendering
      libegl-mesa0 \

      # primary interpreter
      python3.8 \

      # required by transformers package
      python3.8-distutils \

      # redis-python
      redis \

 && apt-get clean

FROM base AS python-deps

# build dependencies
RUN apt-get update -q \
 && DEBIAN_FRONTEND="noninteractive" \
    apt-get install -yq \

      # required by poetry
      python3-pip \

      # required for redis
      gcc \

 && apt-get clean

WORKDIR "/deps"

COPY pyproject.toml poetry.lock /deps/
RUN pip3 install poetry && poetry install

#RUN pip3 install poetry \
 #&& poetry install
 ##&& wget "http://www.atarimania.com/roms/Roms.rar" \
 ##&& unrar e Roms.rar \
 ##&& unzip ROMS.zip \
 ##&& /root/.cache/pypoetry/virtualenvs/ppo-K3BlsyQa-py3.8/bin/python -m atari_py.import_roms ROMS/

FROM base AS runtime

WORKDIR "/project"
ENV VIRTUAL_ENV=/root/.cache/pypoetry/virtualenvs/generalization-K3BlsyQa-py3.8/
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
COPY --from=python-deps $VIRTUAL_ENV $VIRTUAL_ENV
COPY . .


ENTRYPOINT ["python"]
