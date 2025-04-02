# check=skip=InvalidDefaultArgInFrom

ARG DISTRO

FROM ${DISTRO}

ARG DISTRO
ARG GIT_COMMIT
ARG BUILD_DATE

LABEL org.opencontainers.image.title="${DISTRO}" \
      org.opencontainers.image.authors="4geniac" \
      org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}"\
      org.opencontainers.image.source="https://github.com/bioinfo-pf-curie/4geniac"

ARG CONDA_RELEASE
ARG SHA256SUM
ARG MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_RELEASE}-Linux-x86_64.sh"

RUN wget "${MINICONDA_URL}" -O miniconda.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    sha256sum --check --status shasum && \
    mkdir -p /usr/local/ && \
    sh miniconda.sh -b -p /usr/local/conda && \
    rm miniconda.sh shasum && \
    ln -s /usr/local/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /usr/local/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /usr/local/conda/ -follow -type f -name '*.a' -delete && \
    find /usr/local/conda/ -follow -type f -name '*.js.map' -delete && \
    /usr/local/conda/bin/conda clean -afy && \
    ln -s /usr/local/conda/bin/conda /usr/local/bin/conda

SHELL ["/bin/bash", "--login", "-c"]    

RUN conda install -c conda-forge micromamba=2.0.8=0 && \
	conda clean --all -y

ENV PATH=/usr/local/conda/bin:$PATH

