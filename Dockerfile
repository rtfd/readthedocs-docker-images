# Read the Docs - Environment base
FROM ubuntu:18.04
LABEL mantainer="Read the Docs <support@readthedocs.com>"
LABEL version="5.0.0rc1"

ENV APPDIR /app
ENV LANG C.UTF-8

# UID and GID from readthedocs/user
RUN groupadd --gid 205 docs \
 && useradd  --gid 205 -m --uid 1005 docs

# System dependencies
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -y update \
 && apt-get -y install \
      software-properties-common \
      vim

# Install requirements
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -y install \
      build-essential \
      bzr \
      curl \
      doxygen \
      g++ \
      git-core \
      graphviz-dev \
      libbz2-dev \
      libcairo2-dev \
      libenchant1c2a \
      libevent-dev \
      libffi-dev \
      libfreetype6 \
      libfreetype6-dev \
      libgraphviz-dev \
      libjpeg8-dev \
      libjpeg-dev \
      liblcms2-dev \
      libmysqlclient-dev \
      libpq-dev \
      libreadline-dev \
      libsqlite3-dev \
      libtiff5-dev \
      libwebp-dev \
      libxml2-dev \
      libxslt1-dev \
      libxslt-dev \
      mercurial \
      pandoc \
      pkg-config \
      postgresql-client \
      subversion \
      zlib1g-dev

# pyenv extra requirements
# https://github.com/pyenv/pyenv/wiki/Common-build-problems
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -y install \
      liblzma-dev \
      libncurses5-dev \
      libncursesw5-dev \
      libssl-dev \
      llvm \
      make \
      python-openssl \
      tk-dev \
      wget \
      xz-utils

# Install LateX packages
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -y install \
      fonts-symbola \
      texlive-full

# plantuml: is to support sphinxcontrib-plantuml
# https://pypi.org/project/sphinxcontrib-plantuml/
#
# imagemagick: is to support sphinx.ext.imgconverter
# http://www.sphinx-doc.org/en/master/usage/extensions/imgconverter.html
#
# rsvg-convert: is for SVG -> PDF conversion
# using Sphinx extension sphinxcontrib.rsvgconverter, see
# https://github.com/missinglinkelectronics/sphinxcontrib-svg2pdfconverter
#
# swig: is required for different purposes
# https://github.com/rtfd/readthedocs-docker-images/issues/15
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -y install \
      imagemagick \
      librsvg2-bin \
      plantuml \
      swig

# Install Python tools/libs
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -y install \
      python-pip \
 && pip install -U \
      auxlib \
      virtualenv

# sphinx-js dependencies: jsdoc and typedoc (TypeScript support)
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -y install \
      nodejs \
      npm \
 && npm install --global \
      jsdoc \
      typedoc

USER docs
WORKDIR /home/docs

# Versions, and expose labels for external usage
ENV PYTHON_VERSION_27=2.7.15 \
    PYTHON_VERSION_36=3.6.8 \
    PYTHON_VERSION_37=3.7.2 \
    CONDA_VERSION=4.5.12
LABEL python.version_27=$PYTHON_VERSION_27 \
      python.version_36=$PYTHON_VERSION_36 \
      python.version_37=$PYTHON_VERSION_37 \
      conda.version=$CONDA_VERSION

# Install Conda
RUN curl -O https://repo.continuum.io/miniconda/Miniconda2-${CONDA_VERSION}-Linux-x86_64.sh \
 && bash Miniconda2-${CONDA_VERSION}-Linux-x86_64.sh -b -p /home/docs/.conda/ \
 && rm -f Miniconda2-${CONDA_VERSION}-Linux-x86_64.sh
ENV PATH=$PATH:/home/docs/.conda/bin

# Install pyenv
RUN curl -L https://github.com/pyenv/pyenv/archive/master.tar.gz \
  | tar xz \
 && mv pyenv-master .pyenv
ENV PYENV_ROOT=/home/docs/.pyenv \
    PATH=/home/docs/.pyenv/shims:$PATH:/home/docs/.pyenv/bin

# Install supported Python versions
RUN set -x \
 && pyenv install "${PYTHON_VERSION_27}" \
 && pyenv install "${PYTHON_VERSION_37}" \
 && pyenv install "${PYTHON_VERSION_36}" \
 && pyenv global \
      "${PYTHON_VERSION_27}" \
      "${PYTHON_VERSION_37}" \
      "${PYTHON_VERSION_36}" \
 && true

RUN set -x \
 && cd /tmp \
 && for env in "${PYTHON_VERSION_27}" "${PYTHON_VERSION_37}" "${PYTHON_VERSION_36}"; \
    do   pyenv local "${env}" \
      && pyenv exec pip install --no-cache-dir -U pip \
      && pyenv exec pip install --no-cache-dir --only-binary numpy,scipy \
           matplotlib \
           numpy \
           pandas \
           scipy \
           virtualenv \
    ; done

WORKDIR /

CMD ["/bin/bash"]
