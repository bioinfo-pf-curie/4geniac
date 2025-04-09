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
ARG MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-${CONDA_RELEASE}-Linux-x86_64.sh"

RUN wget "${MINIFORGE_URL}" -O miniforge.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
    mkdir -p /usr/local/ && \
    sh miniforge.sh -b -p /usr/local/conda && \
    rm miniforge.sh && \
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

