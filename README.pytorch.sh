#SEE: 	/lus/theta-fs0/software/thetagpu/conda/2021-06-26/
#	/lus/theta-fs0/software/thetagpu/conda/2021-06-28/
#       and newer

BASE_PATH=/lus/theta-fs0/projects/CSC249ADOA01/brettin
NEW_ENV=megatron-deepspeed

DATE=$(date +%Y-%m-%d)
mkdir $BASE_PATH/$DATE
pushd $BASE_PATH/$DATE
mkdir -p /$BASE_PATH/conda_env


module load openmpi/openmpi-4.1.1_ucx-1.11.2_gcc-9.3.0
module load cmake


CUDA_VERSION_MAJOR=11
CUDA_VERSION_MINOR=4
CUDA_VERSION=$CUDA_VERSION_MAJOR.$CUDA_VERSION_MINOR
CUDA_BASE=/usr/local/cuda-$CUDA_VERSION
CUDA_DEPS_BASE=/lus/theta-fs0/software/thetagpu/cuda

CUDNN_VERSION_MAJOR=8
CUDNN_VERSION_MINOR=2
CUDNN_VERSION_EXTRA=4.15
CUDNN_VERSION=$CUDNN_VERSION_MAJOR.$CUDNN_VERSION_MINOR.$CUDNN_VERSION_EXTRA
CUDNN_BASE=$CUDA_DEPS_BASE/cudnn-$CUDA_VERSION-linux-x64-v$CUDNN_VERSION

NCCL_VERSION_MAJOR=2
NCCL_VERSION_MINOR=11.4-1
NCCL_VERSION=$NCCL_VERSION_MAJOR.$NCCL_VERSION_MINOR
NCCL_BASE=$CUDA_DEPS_BASE/nccl_$NCCL_VERSION+cuda${CUDA_VERSION}_x86_64

export CUDA_BASE=$CUDA_BASE
export NCCL_BASE=$NCCL_BASE
export CUDNN_BASE=$CUDNN_BASE

export CUDA_TOOLKIT_ROOT_DIR=$CUDA_BASE
export NCCL_ROOT_DIR=$NCCL_BASE
export CUDNN_ROOT=$CUDNN_BASE


module load conda/2021-11-30 
conda create --prefix $BASE_PATH/conda_env/$NEW_ENV-${DATE} python=3.8
conda activate $BASE_PATH/conda_env/$NEW_ENV-${DATE}

conda install -y numpy ninja pyyaml mkl mkl-include setuptools cmake cffi typing_extensions future six requests dataclasses pytest matplotlib pandas
conda install -y pybind11


PT_REPO_URL=https://github.com/pytorch/pytorch.git
PT_REPO_TAG="v1.9.0"
PT_REPO_TAG="v1.10.0"  # 20211209

git clone --recursive $PT_REPO_URL
cd pytorch
git checkout --recurse-submodules $PT_REPO_TAG
python setup.py bdist 2>&1 | tee setup.log.${DATE}
python setup.py install 2>&1 | tee install.log.${DATE}
cd ..

python -c 'import torch ; print(torch.__version__)'
# 1.10.0a0+git36449ea

