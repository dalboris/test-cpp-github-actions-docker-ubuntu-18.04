FROM ubuntu:18.04

ARG QT_VERSION=5.12.5
ARG PYTHON_VERSION=3.7

# Upgrade packages and install dependencies readily available
#
RUN apt update && \
    apt upgrade -y && \
    apt install -y gpg wget software-properties-common build-essential libfreetype6-dev libharfbuzz-dev

# Install and Configure Recent Git
#
# Requires: software-properties-common
#
# Note: The last line fixes the following error:
#  "fatal: detected dubious ownership in repository at '/__w/<user>/<repo>'""
#
RUN add-apt-repository ppa:git-core/ppa && \
    apt install -y git && \
    git config --global --add safe.directory '*'

# Install Recent CMake
#
# Requires: software-properties-common
#
# References:
# - https://apt.kitware.com/
# - https://askubuntu.com/questions/355565/how-do-i-install-the-latest-version-of-cmake-from-the-command-line
#
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6AF7F09730B3F0A4 && \
    add-apt-repository "deb https://apt.kitware.com/ubuntu/ bionic main" && \
    apt install -y cmake

# Install Python 3.7 and set it as preferred alternative
#
# Requires: software-properties-common build-essential
#
# References:
# - https://stackoverflow.com/a/67007852/1951907
#
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-dev python${PYTHON_VERSION}-distutils && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 2

# Install Qt
#
# Requires: wget
#
# Notes:
#
# - We need libgl1-mesa-dev for QtGui, otherwise CMake configure step fails with:
#   CMake Error at qt/5.12.5/gcc_64/lib/cmake/Qt5Gui/Qt5GuiConfigExtras.cmake:9 (message):
#   Failed to find "GL/gl.h" in "/usr/include/libdrm".
#
# - We need libxkbcommon-x11-0 for Qt plugins/platforms/libqxcb.so
#
RUN apt-get install -y libgl1-mesa-dev libxkbcommon-x11-0 && \
    wget --progress=dot:giga https://www.vgc.io/releases/qt/opt-qt-$QT_VERSION-gcc_64.tar.gz && \
    tar -xzf opt-qt-$QT_VERSION-gcc_64.tar.gz -C "/opt" && \
    rm opt-qt-$QT_VERSION-gcc_64.tar.gz
