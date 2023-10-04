ARG DISTRO

FROM ${DISTRO}

ARG GIT_COMMIT
ARG BUILD_DATE
ARG DISTRO
ARG DISTRO_VERSION

LABEL org.opencontainers.image.title="${DISTRO}" \
      org.opencontainers.image.authors="4geniac" \
      org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}"\
      org.opencontainers.image.source="https://github.com/bioinfo-pf-curie/4geniac"


RUN if [[ $(echo ${DISTRO} | grep redhat) ]]; then dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-${DISTRO_VERSION}.noarch.rpm; else dnf install -y epel-release; fi


RUN dnf install -y diffutils \
        langpacks-en glibc-langpack-en glibc-locale-source \
        procps-ng \
        which findutils \
        wget

RUN dnf clean all && \
    dnf makecache

RUN localedef --no-archive -i en_US -f UTF-8 en_US.UTF-8

