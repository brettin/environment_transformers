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
# pip uninstall deepspeed
# cd Megatron-Deepspeed
# pip install -r requirements.txt
# Successfully installed DeepSpeed-0.5.9+91e1559


cd ..

