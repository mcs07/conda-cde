#!/usr/bin/env bash

REPO_ROOT=$(cd "$(dirname "$0")/.."; pwd;)

cat << EOF | docker run -i \
                        -v ${REPO_ROOT}:/conda-cde \
                        -a stdin -a stdout -a stderr \
                        condaforge/linux-anvil \
                        bash || exit $?

cp -r /conda-cde/recipes /conda-recipes
export BINSTAR_TOKEN=${BINSTAR_TOKEN}
export CONDA_NPY='19'
export CPU_COUNT=2
export PYTHONUNBUFFERED=1
conda config --add channels conda-forge
conda config --add channels chemdataextractor
conda config --set show_channel_urls True
conda config --set add_pip_as_python_dependency false
conda clean --lock
conda install --yes --quiet -c conda-forge conda-build-all conda-build==2.0.10
conda update --yes --quiet -c conda-forge conda
conda install --yes --quiet -c conda-forge jinja2 anaconda-client
conda info
conda config --get
conda-build-all /conda-recipes --inspect-channels chemdataextractor --upload-channels chemdataextractor --matrix-conditions "numpy >=1.10" "python >=2.7,<3|>=3.4,<3.5|>=3.5,<3.6|>=3.6,<3.7"

EOF
