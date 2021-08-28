# 4geniac

This repository provides a script to build and push on [4geniac](https://hub.docker.com/u/4geniac) docker hub regristry the containers which are used by [Geniac](https://geniac.readthedocs.io) to build the docker and singularity containers for each tool.

## Usage

The script `generateDistro.sh` allows the generation of the containers for several community-supported Linux distributions which are binary-compatible with Red Hat Enterprise Linux (RHEL). For each Linux distribution version listed in the file `linuxDistroVersion.txt`, it outputs a bash script that can build and push on the `4geniac` docker hub registry following:

* the `distro/version` with a minimal Linux `distro`
* all the possible `distro/version_conda-release`'s where `release` takes all the values listed in the first column of the file `condaRelease.txt`. This tag bootstraps from the `distro/version` tag.
* the `distro/version_sdk-conda-release` with development tools (which are required when a tool is installed from source by geniac, such as gcc, g++, cmake3, etc.) and conda. This tag bootstraps from the `distro/version_conda-release` tag.

Note that any tag already existing on the `4geniac` docker hub registry will be ignored in the output.

```
### For distro/version
bash generateDistro.sh distro > scriptDistro.sh
bash scriptDistro.sh

### For distro/version_conda-release's
bash generateDistro.sh distro+conda > scriptDistroConda.sh
bash scriptDistroConda.sh

### For distro/version_sdk
bash generateDistro.sh distro+sdk > scriptDistroSdk.sh
bash scriptDistroSdk.sh
```

## Resources

* The [geniac documentation](https://geniac.readthedocs.io) provides a set of best practises to implement *Nextflow* pipelines.
* The [geniac](https://github.com/bioinfo-pf-curie/geniac) source code provides the set of utilities.
* The [geniac demo](https://github.com/bioinfo-pf-curie/geniac-demo) provides a toy pipeline to test and practise *Geniac*.
* The [geniac demo DSL2](https://github.com/bioinfo-pf-curie/geniac-demo-dsl2) provides a toy pipeline to test and practise *Geniac* with *Nextflow* DSL2.
* The [geniac template](https://github.com/bioinfo-pf-curie/geniac-template) provides a pipeline template to start a new pipeline.
* The [4geniac](https://hub.docker.com/u/4geniac) docker hub registry with the containers used by *Geniac*.

## Citation

[Allain F, Roméjon J, La Rosa P et al. Geniac: Automatic Configuration GENerator and Installer for nextflow pipelines. Open Research Europe 2021, 1:76](https://open-research-europe.ec.europa.eu/articles/1-76)

