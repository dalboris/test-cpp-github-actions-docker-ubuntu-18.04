FROM ubuntu:18.04

ARG QT_VERSION=5.12.5

# Install utilities needed for other steps
#
RUN apt-get update && \
    apt-get install -y gpg wget software-properties-common

# Install and Configure Recent Git
#
# Requires: software-properties-common
#
# Note: The last line fixes the following error:
#  "fatal: detected dubious ownership in repository at '/__w/<user>/<repo>'""
#
RUN add-apt-repository ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y git && \
    git config --global --add safe.directory '*'

# Install Recent CMake
#
# Requires: software-properties-common
#
# See documentation at:
# - https://apt.kitware.com/
# - https://askubuntu.com/questions/355565/how-do-i-install-the-latest-version-of-cmake-from-the-command-line
#
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6AF7F09730B3F0A4 && \
    add-apt-repository "deb https://apt.kitware.com/ubuntu/ bionic main" && \
    apt-get update && \
    apt-get install -y cmake

# Install Qt
#
# Requires: wget
#
# Note: we need libgl1-mesa-dev for QtGui, otherwise CMake configure step would fail with:
#   CMake Error at qt/5.12.5/gcc_64/lib/cmake/Qt5Gui/Qt5GuiConfigExtras.cmake:9 (message):
#   Failed to find "GL/gl.h" in "/usr/include/libdrm".
#
RUN apt-get install -y libgl1-mesa-dev && \
    wget --progress=dot:giga https://www.vgc.io/releases/qt/opt-qt-$QT_VERSION-gcc_64.tar.gz && \
    tar -xzf opt-qt-$QT_VERSION-gcc_64.tar.gz -C "/opt" && \
    rm opt-qt-$QT_VERSION-gcc_64.tar.gz

# Install Other Dependencies
#
RUN apt-get install -y build-essential libfreetype6-dev
