#! /bin/bash

#################
### Functions ###
#################
function usage () {
  echo -e "Usage: bash $0 -d <distro-value> [ -r <registry> ] [ -f <false|true> ]\n\n"
  echo -e "The script generates a script to build and push one of these linux <distro-value>:"
  echo -e "\t-d name of the distro among the following possibilities:"
  echo -e "\t\t* distro: the minimal distro"
  echo -e "\t\t* distro+conda: the minimal distro with miniconda"
  echo -e "\t\t* distro+sdk: the minimal distro with development tools"
  echo -e "\t-r docker registry, it should end with a '/' (default is '4geniac/')"
  echo -e "\t-f generate and push the container even if they exist on the registry (default is false)"
  echo ""
}

### push on any other registry (instead of 4geniac on docker hub)
docker_push_folder="4geniac/"
force_mode="false"
mandatory_arg=0

while getopts d:f:r:h: arg_value; do
    case "${arg_value}" in
        d)
            option=${OPTARG}
            mandatory_arg=$((${mandatory_arg} + 1))
            ;;
        f)
            force_mode=${OPTARG}
            ;;
        r)
            docker_push_folder=${OPTARG}
            ;;
        h | *)
            usage "$0" ; exit 1
            ;;
    esac
done
shift $((OPTIND-1))


if [[ ${docker_push_folder: -1} != "/" ]]; then
    echo -e "\nERROR: the value in '-r' option must end with a '/'\n"
    usage "$0"
  exit 1
fi


### check that mandatory variables have been provided
if [[ ${mandatory_arg} -ne 1 ]]; then
  echo -e "\nERROR: '-d' option must be specified\n"
  usage "$0"
  exit 1
fi

##############
### Error  ###
##############

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
    if [[ ${force_mode} == "true" ]]; then
      already_exist=0
    fi
  
    echo -e "################################################################################"
    echo -e "### <<< START ${distroVersion}${suffix}"
  
    if [[ ${already_exist} != 1 ]]; then
      echo -e "\necho \"build: 4geniac/${repo}:${version}\"\n"
      echo -e "sudo docker build --no-cache=true \\
         --build-arg DISTRO=\""${fromDistro}"\" \\
         --build-arg BUILD_DATE=\"\$(date --rfc-3339=seconds)\" \\
         --build-arg GIT_COMMIT=\""${GIT_COMMIT}"\" \\
         ${optArgs} \\
         -t ${docker_push_folder}${repo}:${version} -f ${template} template"
  
      echo -e "\necho \"push: ${docker_push_folder}${repo}:${version}\"\n"
      echo -e "docker push ${docker_push_folder}${repo}:${version}\n"
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
    template="template/distroSdk.Dockerfile"
    while read condaVersion; do
      optArgs="--build-arg CONDA_RELEASE=\"${condaVersion% *}\""
      suffix="_sdk-conda-${condaVersion% *}"
      generateDistro
    done < ${CONDA_RELEASE_FILE}
    ;;
  -h|--help)
    usage
    ;;
  *)
      echo -e "ERROR: unknown <distro-value>\n" ; usage "$0"; exit 1
      ;;
esac
exit 0

