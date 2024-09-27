# Docker for Official Python wrapper for OpenFHE

A simple image based on Debian slim that can be used to run the official Python wrapper for OpenFHE.

# Build the docker image:

Default config:

```env
IMAGE=openfhe-sdk-python
OPENFHE_TAG=v1.2.1
OPENFHE_SDK_PYTHON_TAG=v0.8.9
```

To build the image use the following command:

```docker
source .env
docker build --no-cache --build-arg OPENFHE_TAG=${OPENFHE_TAG} --build-arg OPENFHE_SDK_PYTHON_TAG=${OPENFHE_SDK_PYTHON_TAG} . -t ${IMAGE}:${OPENFHE_TAG}
```

Or just execute the build script:

```bash
./build.sh
```

# Run a terminal inside a container from the image:

```docker
docker run -it <container-name> /bin/bash
```

Replace the <container-name> with the name that you see when you use the command "docker run -d -p 8888:8888 openfhe-docker".This takes you to a terminal interface inside the container which has all the dependencies installed.

You can now clone a github repo that depends on OpenFHE and run the code.


# Why use this image and not the Official Python wrapper for OpenFHE ?

- It based on Debian instead on ubuntu so the size is smaller 
- You can choose what is the version of OpenFHE you want to use

