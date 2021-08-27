#! /bin/bash

option=$1
condaVersion=$2
sha256sumConda=$3

set -oue pipefail

#########################
### List of variables ###
#########################

DOCKER_REGISTRY_URL="https://registry.hub.docker.com/v2/repositories/4geniac"
GIT_COMMIT=$(git rev-parse --short HEAD)
LINUX_DISTRO_FILE="linuxDistroVersion.txt"
CONDA_RELEASE_FILE="condaRelease.txt"


#################
### Functions ###
#################
function usage () {
  echo -e "Usage: bash $0 <distro-value>\n\n"
  echo -e "The script generates a script to build and push one of these linux <distro-value>:"
  echo -e "\t- distro: the minimal distro"
  echo -e "\t- distro+conda: the minimal distro with miniconda"
  echo -e "\t- distro+sdk: the minimal distro with developemt tools"
  echo ""
}

function generateDistro () {
  echo "#! /bin/bash"
  echo -e "\nset -oeu pipefail\n"
  
  for distroVersion in $(cat ${LINUX_DISTRO_FILE}); do

    distro=${prefix}${distroVersion%%:*}
    fromDistro=$(echo ${prefix}${distroVersion} | sed -e 's|/.*/|/|g') ### for rockylinux/rockylinux (because there is a slash)
    repo=${distro#4geniac/}
    repo=${repo%/*}
    version=${distroVersion##*:}${suffix}
  
    CURL_CMD=$(echo "curl -L -s --retry 5 --retry-delay 5 ${DOCKER_REGISTRY_URL}/${repo}/tags | jq '.results | .[] | (select(.name==\""${version}"\")) | .name ' | wc -l")
  
    already_exist=$(eval ${CURL_CMD})
  
    echo -e "################################################################################"
    echo -e "### <<< START ${distroVersion}${suffix}"
  
    if [[ ${already_exist} != 1 ]]; then
      echo -e "\necho \"build: 4geniac/${repo}:${version}\"\n"
      echo -e "sudo docker build --no-cache=true \\
         --build-arg DISTRO=\""${fromDistro}"\" \\
         --build-arg BUILD_DATE=\"\$(date --rfc-3339=seconds)\" \\
         --build-arg GIT_COMMIT=\""${GIT_COMMIT}"\" \\
         ${optArgs} \\
         -t 4geniac/${repo}:${version} -f ${template} template"
  
      echo -e "\necho \"push: 4geniac/${repo}:${version}\"\n"
      echo -e "sudo docker push 4geniac/${repo}:${version}\n"
    else
      echo -e "\n# INFO: tag 4geniac/${repo}:${version} already exists on docker hub\n"
    fi
  
    echo -e "###  ${distroVersion}${suffix} END >>>"
    echo -e "################################################################################\n\n"
  
  done

}

###############
### Options ###
###############

case "${option}" in
    
  distro)
    prefix=""
    suffix=""
    template="template/distro.Dockerfile"
    optArgs=""
    generateDistro
    ;;
  distro+conda)
    prefix="4geniac/"
    template="template/distroConda.Dockerfile"
    while read condaVersion; do
      optArgs="--build-arg CONDA_RELEASE=\"${condaVersion% *}\" --build-arg SHA256SUM=\"${condaVersion#* }\""
      suffix="_conda-${condaVersion% *}"
      generateDistro
    done < ${CONDA_RELEASE_FILE}
    ;;
  distro+sdk)
    prefix="4geniac/"
    suffix="_sdk"
    template="template/distroSdk.Dockerfile"
    optArgs=""
    generateDistro
    ;;
  -h|--help)
    usage
    ;;
  *)
      echo -e "ERROR: unknown <distro-value>\n" ; usage; exit 1
      ;;
esac
exit 0

