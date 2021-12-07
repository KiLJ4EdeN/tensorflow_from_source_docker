FROM tf

RUN git clone -b v2.2.0 --recursive https://github.com/tensorflow/tensorflow.git
WORKDIR /tensorflow
# some how numpy might get bugged here, if u got the numpy not installed error, install it here again
RUN git checkout v2.2.0
RUN bazel build -c opt //tensorflow/tools/pip_package:build_pip_package -j 16
# # build from the release branch
# RUN ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
# RUN pip install /tmp/tensorflow_pkg/tensorflow-version-tags.whl