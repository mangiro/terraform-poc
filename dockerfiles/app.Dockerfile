FROM python:3.9.13-slim-buster

# Install system dependencies
RUN apt-get update && apt-get upgrade -y \
  && apt-get install --no-install-recommends -y \
    libcurl4-openssl-dev \
    libssl-dev \
    bash \
    git \
    curl \
    libc-dev \
    gcc \
    make

# Python envs
ENV PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PYTHONDONTWRITEBYTECODE=1

# Pip envs
ENV PIP_NO_CACHE_DIR=1 \
  PIP_DISABLE_PIP_VERSION_CHECK=1 \
  PIP_DEFAULT_TIMEOUT=100

# Poetry envs
ENV POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_CREATE=false \
  POETRY_CACHE_DIR='/var/cache/pypoetry' \
  POETRY_HOME='/usr/local'

# Install poetry
RUN curl -sSL 'https://install.python-poetry.org' | python - \
  && poetry --version

WORKDIR /usr/app

# Project metadata
COPY poetry.lock pyproject.toml /usr/app/

# Install project dependencies
RUN poetry install --no-interaction --no-ansi
