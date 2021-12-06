# tensorflow_from_source_docker
Docker file to build tensorflow from source inside docker, helps with cpus that dont have avx, avx2, sse, or kvm and vmware shared cpus

##### clone and create base bazel dockerimage:
```bash
# clone into a version of your desire, ofc this wont probably be without bugs as 2.2.0 was tested with this config
git clone -b v2.2.0 --recursive https://github.com/tensorflow/tensorflow.git && cd tensorflow && git checkout v2.2.0
# tf provides some docker files that reduce building complexity
cd tensorflow/tools/dockerfiles/
# here we create a local image that has bazel and stuff to create tf,
# note that if u checkout in the wrong branch everything will be messed up, and the build will fail, probably due to bad bazel version
# this is the default way of creating the image, although on older versions there is support for python2  which we don't want
# docker build -f ./dockerfiles/devel-cpu.Dockerfile -t tf .
# for tf 2.2 use this to build for python3.
docker build -f ./dockerfiles/devel-cpu.Dockerfile -t tf . --build-arg _PY_SUFFIX=3
```

##### CRITICAL NOTE!: the numpy version must be changed to 1.18.5 from the base dockerfile
##### otherwise the build will fail at like 80%
##### in tensorflow/tensorflow/tools/dockerfiles/dockerfiles/devel-cpu.Dockerfile:
```Dockerfile
RUN ${PIP} --no-cache-dir install \
    Pillow \
    h5py \
    keras_preprocessing \
    matplotlib \
    mock \
    numpy==1.18.5 \  <-----
    scipy \
    sklearn \
    pandas \
    future \
    portpicker \
    && test "${USE_PYTHON_3_NOT_2}" -eq 1 && true || ${PIP} --no-cache-dir install \
    enum34
```



##### clone tensorflow in the container and build the pip package
(this only applies for my country iran): while building with bazel every dependency is forbidden (403) so shecan is must have, 
add it to the local machine and if the container does not have the same nameservers afterwards,
do a sudo systemctl restart docker
```bash
rm -rf /etc/resolv.conf
cat << EOF >> /etc/resolv.conf


# This file is managed by man:systemd-resolved(8). Do not edit.
#
# This is a dynamic resolv.conf file for connecting local clients directly to
# all known uplink DNS servers. This file lists all configured search domains.
#
# Third party programs must not access this file directly, but only through the
# symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a different way,
# replace this symlink by a static file or a different symlink.
#
# See man:systemd-resolved.service(8) for details about the supported modes of
# operation for /etc/resolv.conf.

nameserver 185.51.200.2
nameserver 178.22.122.100

EOF
```

#### here we got two approaches, either debug in the installation in the container which we'll call method 1
##### method 1
first bash into the container
```bash
docker run -u $(id -u):$(id -g) -v $(pwd):/my-devel -it tf
```
then
```bash
git clone -b v2.2.0 --recursive https://github.com/tensorflow/tensorflow.git && cd tensorflow && git checkout v2.2.0
# limit ram
bazel build -c opt //tensorflow/tools/pip_package:build_pip_package -j 16
```

#### or use the image we just created build another Dockerfile
possibly here we can use AS later for simplicity
##### method 2
```Dockerfile
# the image we just created
FROM tf

# get source for bazel build
RUN git clone -b v2.2.0 --recursive https://github.com/tensorflow/tensorflow.git
WORKDIR /tensorflow 
RUN git checkout v2.2.0
# -j16 is for limiting RAM, very helpful option on low end devices
RUN bazel build -c opt //tensorflow/tools/pip_package:build_pip_package -j 16
```

#### output:
```buildoutcfg
[12,882 / 14,285] Compiling tensorflow/core/kernels/resource_variable_ops.cc; 64s local ... (16 actions, 15 running)
[13,611 / 14,286] Compiling tensorflow/core/kernels/ragged_tensor_to_tensor_op.cc; 52s local ... (16 actions, 15 running)
Target //tensorflow/tools/pip_package:build_pip_package up-to-date:             
  bazel-bin/tensorflow/tools/pip_package/build_pip_package
INFO: Elapsed time: 3215.803s, Critical Path: 176.77s
INFO: 13287 processes: 13287 local.
INFO: Build completed successfully, 14306 total actions
INFO: Build completed successfully, 14306 total actions
```
