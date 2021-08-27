ARG DISTRO

FROM ${DISTRO}

ARG GIT_COMMIT
ARG BUILD_DATE

LABEL org.opencontainers.image.title="${DISTRO}" \
      org.opencontainers.image.authors="4geniac" \
      org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}"\
      org.opencontainers.image.source="https://github.com/bioinfo-pf-curie/4geniac"

RUN yum install -y \
        epel-release \
        langpacks-en glibc-all-langpacks \
        which \
        wget && \
    yum clean all
