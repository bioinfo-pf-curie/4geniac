ARG DISTRO

FROM ${DISTRO}

ARG GIT_COMMIT
ARG BUILD_DATE

LABEL org.opencontainers.image.title="${DISTRO}" \
      org.opencontainers.image.authors="4geniac" \
      org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}"\
      org.opencontainers.image.source="https://github.com/bioinfo-pf-curie/4geniac"

RUN dnf install -y epel-release \
        langpacks-en glibc-langpack-en glibc-locale-source \
        procps-ng \
        which findutils \
        wget && \
    dnf clean all && \
    localedef --no-archive -i en_US -f UTF-8 en_US.UTF-8

