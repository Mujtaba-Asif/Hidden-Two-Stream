FROM nvidia/cuda:9.0-cudnn7-devel
RUN apt-get update
RUN apt-get install -y software-properties-common && apt-get update
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update

RUN apt-get -qq install -y python3-dev python3-pip libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler libatlas-base-dev unzip zip cmake
RUN apt-get update
RUN apt-get -qq install --no-install-recommends libboost1.58-all-dev libgflags-dev libgoogle-glog-dev liblmdb-dev wget python-pip git-all libzip-dev libblas-dev liblapack-dev

RUN apt-get -qq install libopencv-dev build-essential checkinstall cmake pkg-config yasm libjpeg-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev python-dev python-numpy libtbb-dev libqt4-dev libgtk2.0-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev x264 v4l-utils

RUN apt-get -qq install libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler libatlas-base-dev
RUN apt-get -qq install --no-install-recommends libboost1.58-all-dev
RUN apt-get -qq install libgflags-dev libgoogle-glog-dev liblmdb-dev

# install Dense_Flow dependencies
RUN apt-get -qq install libzip-dev libhdf5-10 libhdf5-serial-dev libhdf5-dev libhdf5-cpp-11 python-protobuf
# RUN PYTHON INSTALL
RUN pip install --upgrade pip setuptools wheel
RUN pip install numpy scipy sklearn scikit-image Pillow h5py joblib protobuf jupyter mkl

RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install numpy scipy sklearn scikit-image Pillow h5py joblib protobuf jupyter mkl

RUN python2 -m pip install ipykernel
RUN python2 -m ipykernel install --user

RUN python3 -m pip install ipykernel
RUN python3 -m ipykernel install --user


#RUN pip3 install torch torchvision
#http://download.pytorch.org/whl/cpu/torch-0.4.1-cp35-cp35m-linux_x86_64.whl torchvision
RUN mkdir -p /workspace/src
#WORKDIR /workspace/src

# Get code

RUN nvcc --version
COPY . /workspace/src
RUN cd /usr/lib/x86_64-linux-gnu && ln -s libhdf5_serial.so.8.0.2 libhdf5.so && ln -s libhdf5_serial_hl.so.8.0.2 libhdf5_hl.so

ENV LIBRARY_PATH=/usr/local/cuda/lib64

RUN git clone --recursive -b 2.4 https://github.com/opencv/opencv opencv-2.4.3 \
    && cd /workspace/src/opencv-2.4.3 \
    && git apply /workspace/src/opencv_cuda9.patch && mkdir build && cd build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE -D WITH_TBB=ON  -D WITH_V4L=ON  -D WITH_CUDA=ON -D WITH_OPENCL=OFF .. && make -j4\
    && cp lib/cv2.so / && cd /workspace/src

RUN make all && make pycaffe && make distribute \
    && cp -r /Hidden-Two-Stream/distribute/python/caffe /usr/lib/python2.7/ \
    && cp -r /Hidden-Two-Stream/distribute/python/caffe /usr/lib/python3.5

ENV LD_LIBRARY_PATH=/workspace/src/build/lib/
WORKDIR /workspace/src
VOLUME /workspace/data /workspace/model /workspace/temp /workspace/processed

RUN ulimit -c unlimited

CMD bash

#CMD jupyter notebook --ip 0.0.0.0 --no-browser --allow-root --NotebookApp.token=''
