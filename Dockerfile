# Stage 1: Build Stage
FROM debian:trixie-slim AS builder

# Set environment variables to non-interactive and other necessary settings
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    PYTHONUNBUFFERED=1

# Define a build argument with a default value
ARG OPENFHE_TAG=main
ARG OPENFHE_SDK_PYTHON_TAG=main

# Install necessary dependencies for OpenFHE and OpenFHE-Python
RUN apt-get update && apt-get install -y \
    autoconf \
    clang \
    cmake \
    git \
    libgoogle-perftools-dev \
    libomp-dev \
    libtool \
    python3-minimal \
    python3-pip \
    python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Set clang as the C and C++ compiler
ENV CC=clang \
    CXX=clang++

# Set up Python virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install Python dependencies
RUN pip install --no-cache-dir pybind11[global]

# Clone and build OpenFHE
RUN git clone https://github.com/openfheorg/openfhe-development.git --branch ${OPENFHE_TAG} \
    && cd openfhe-development \
    && mkdir build \
    && cd build \
    && cmake -DBUILD_UNITTESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_BENCHMARKS=OFF -DWITH_TCM=ON .. \
    && make tcm \
    && make -j$(nproc) \
    && make install

# Clone and build OpenFHE-Python
RUN git clone https://github.com/openfheorg/openfhe-python.git --branch ${OPENFHE_SDK_PYTHON_TAG} \
    && cd openfhe-python \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j$(nproc) \
    && make install

# Install openfhe as a pip package
RUN pip install setuptools wheel
WORKDIR /openfhe-python
RUN python3 setup.py sdist bdist_wheel && pip install dist/openfhe-*.whl

# Stage 2: Runtime Stage
FROM debian:trixie-slim AS runtime

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    LD_LIBRARY_PATH=/usr/local/lib

# Install runtime dependencies using python3-minimal
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgoogle-perftools4t64 \
    libomp5 \
    python3-minimal \
    python3-venv \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Set up Python virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy the virtual environment and installed packages from the builder
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/lib/x86_64-linux-gnu/libgomp.so.1 /usr/lib/x86_64-linux-gnu/libgomp.so.1

## Install JupyterLab within the existing virtual environment
#RUN pip install --no-cache-dir jupyterlab
#
## Expose JupyterLab port
#EXPOSE 8888
#
## Set the working directory
#WORKDIR /workspace
#
## Start JupyterLab without token authentication
#CMD ["jupyter-lab", "--ip=0.0.0.0", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.allow_origin='*'", "--NotebookApp.password=''", "--NotebookApp.password_required=False"]