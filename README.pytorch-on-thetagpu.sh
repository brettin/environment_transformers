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


# CUDA path and version information
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


# build and deploy pytorch
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



# build and deploy apex
git clone https://github.com/NVIDIA/apex
cd apex
pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
cd ..
python -c "import apex"


# Build Megatron-Deepspeed
git clone https://github.com/bigscience-workshop/Megatron-DeepSpeed
cd Megatron-DeepSpeed
pip install -r requirements.txt
cd ..

git clone https://github.com/microsoft/deepspeed deepspeed-big-science
#### Stopped here because I noticed that the megatron-deepspeed requirements
#### installed deepspeed. So let's give it a try now, then go to the next step.

cd deepspeed-big-science
git checkout big-science
rm -rf build
DS_BUILD_CPU_ADAM=1 DS_BUILD_AIO=1 DS_BUILD_UTILS=1 pip install -e . --global-option="build_ext" --global-option="-j8" --no-cache -v --disable-pip-version-check


#     Found existing installation: deepspeed 0.5.9+91e1559
#     Uninstalling deepspeed-0.5.9+91e1559:
# 
# Successfully installed deepspeed-0.4.2+c7f3bc5 tensorboardX-1.8

# don't want this. I want the latest deepspeed
pip uninstall deepspeed
cd Megatron-Deepspeed
pip install -r requirements.txt
Successfully installed DeepSpeed-0.5.9+91e1559


cd ..




# THIS IS COMPILING:
module load cmake
module load conda
conda activate megatron-lm-2.2-2 
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}


PT_REPO_URL=https://github.com/pytorch/pytorch.git
PT_REPO_TAG="v1.9.0"
git clone --recursive $PT_REPO_URL
cd pytorch
git checkout --recurse-submodules $PT_REPO_TAG
# can use https://github.com/pytorch/pytorch/archive/refs/tags/v1.8.2.tar.gz

python setup.py bdist
python setup.py install



# THIS SHOULD BE TRIED
# Note, load opencv somehow

module load cmake
module load conda
conda activate megatron-lm-2.2-2 
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}

mkdir -p /raid/scratch/brettin
cd /raid/scratch/brettin

PT_REPO_URL=https://github.com/pytorch/pytorch.git
PT_REPO_TAG="v1.9.0"
git clone --recursive $PT_REPO_URL
git checkout --recurse-submodules $PT_REPO_TAG

CUDA_VERSION_MAJOR=11
CUDA_VERSION_MINOR=3
CUDA_VERSION=$CUDA_VERSION_MAJOR.$CUDA_VERSION_MINOR
CUDA_BASE=/usr/local/cuda-$CUDA_VERSION

CUDA_DEPS_BASE=/lus/theta-fs0/software/thetagpu/cuda

CUDNN_VERSION_MAJOR=8
CUDNN_VERSION_MINOR=2
CUDNN_VERSION_EXTRA=0.53
CUDNN_VERSION=$CUDNN_VERSION_MAJOR.$CUDNN_VERSION_MINOR.$CUDNN_VERSION_EXTRA
CUDNN_BASE=$CUDA_DEPS_BASE/cudnn-$CUDA_VERSION-linux-x64-v$CUDNN_VERSION

NCCL_VERSION_MAJOR=2
NCCL_VERSION_MINOR=9.9-1
NCCL_VERSION=$NCCL_VERSION_MAJOR.$NCCL_VERSION_MINOR
NCCL_BASE=$CUDA_DEPS_BASE/nccl_2.9.9-1+cuda11.0_x86_64

TENSORRT_VERSION_MAJOR=8
TENSORRT_VERSION_MINOR=0.0.3
TENSORRT_VERSION=$TENSORRT_VERSION_MAJOR.$TENSORRT_VERSION_MINOR
TENSORRT_BASE=$CUDA_DEPS_BASE/TensorRT-$TENSORRT_VERSION.Linux.x86_64-gnu.cuda-$CUDA_VERSION.cudnn$CUDNN_VERSION_MAJOR.$CUDNN_VERSION_MINOR

ls $CUDA_BASE
ls $CUDA_DEPS_BASE
ls $CUDNN_BASE
ls $NCCL_BASE
ls $TENSORRT_BASE


export CUDA_TOOLKIT_ROOT_DIR=$CUDA_BASE
export NCCL_ROOT_DIR=$NCCL_BASE
export CUDNN_ROOT=$CUDNN_BASE 

export USE_TENSORRT=ON
export TENSORRT_ROOT=$TENSORRT_BASE
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
#export TENSORRT_LIBRARY=$TENSORRT_BASE/lib/libmyelin.so			<==== this should be evaluated
export TENSORRT_LIBRARY=$TENSORRT_BASE/lib

export TENSORRT_LIBRARY_INFER=$TENSORRT_BASE/lib/libnvinfer.so
export TENSORRT_LIBRARY_INFER_PLUGIN=$TENSORRT_BASE/lib/libnvinfer_plugin.so
export TENSORRT_INCLUDE_DIR=$TENSORRT_BASE/include

python setup.py develop
python setup.py bdist_wheel

git clone https://github.com/NVIDIA/apex
cd apex
pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./

#git clone https://github.com/NVIDIA/Megatron-LM.git
wget https://github.com/NVIDIA/Megatron-LM/archive/refs/tags/v2.2.tar.gz

