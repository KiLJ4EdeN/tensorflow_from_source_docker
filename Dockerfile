FROM tf

RUN git clone -b v2.2.0 --recursive https://github.com/tensorflow/tensorflow.git
WORKDIR /tensorflow 
RUN git checkout v2.2.0
RUN bazel build -c opt //tensorflow/tools/pip_package:build_pip_package -j 16
