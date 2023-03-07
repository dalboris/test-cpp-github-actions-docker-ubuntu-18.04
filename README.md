This repository provides a Dockerfile for building a Docker image suitable for
a build of
[`test-cpp-github-actions`](https://github.com/dalboris/test-cpp-github-actions)
on Ubuntu 18.04.

# Prerequisites

1. Create an account on Docker Hub.
   Below, we'll use `<docker-user>` to refer to your Docker username.

2. Install Docker on your local machine, see: https://docs.docker.com/get-docker/

3. (Optional but recommended) Configure the Docker's credentials store for
   more secure login to Docker Hub. See: https://docs.docker.com/engine/reference/commandline/login/#credentials-store

   For example, if your local machine is using Ubuntu, you can for example do something like this:

   ```
   # Install GPG and Pass
   sudo apt install gnupg pass

   # Generate RSA key. When prompted: RSA and RSA, 4096, Your Name <yourname@example.com>
   gpg --full-generate-key

   # Download the Docker Credential Helper to ~/bin and make it executable
   VERSION=v0.7.0
   NAME=docker-credential-pass-$VERSION.linux-amd64
   URL=https://github.com/docker/docker-credential-helpers/releases/download/$VERSION/$NAME
   mkdir -p ~/bin
   cd ~/bin
   wget $URL
   chmod u+x $NAME
   ```

   Then add `~/bin` to your PATH, for example by adding the following to your `~/.bashrc`:

   ```
   export PATH="$HOME/bin:$PATH"
   ```

   Then configure Docker to use the freshly installed credential helper,
   by adding the following to your `~/.docker/config.json`:

   ```
   {
       "credsStore": "pass-v0.7.0.linux-amd64"
   }
   ```

4. Login to Docker via `docker login -u <docker-user>`

# Build the Docker image

```
git clone https://github.com/<github-user>/<repo>.git
cd <repo>
docker build -t <image> .
```

Note: `<image>` can be any name of your choice. You can use the same as `<repo>`.

# Test the Docker image

```
docker run -it <image> /bin/bash
```

This brings you to an interactive Bash session, when you can for example type
`cmake --version` to check that CMake is correctly installed. Type `exit` to end
the session.

# Push the Docker image to Docker Hub

```
docker tag <image> <docker-user>/<image>
docker push <docker-user>/<image>
```

You can check on Docker Hub that the image was correcly uploaded.

# Use the Docker image with GitHub Actions

```
name: Ubuntu 18.04 (Docker Minimal Custom Image)
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    container: <docker-user>/<image>
    steps:

    - uses: actions/checkout@v2

    - name: Build
      working-directory: ${{github.workspace}}
      run: |
        mkdir build
        cd build
        cmake --version
        cmake .. -DCMAKE_BUILD_TYPE=Release
        cmake --build .
```
