# Use Julia 1.10 as base image
FROM julia:1.10

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JULIA_PROJECT=/app
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    build-essential \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    libhdf5-dev \
    pkg-config \
    cmake \
    git \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create a Python virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip setuptools wheel

# Install Python scientific computing stack
RUN pip install \
    numpy \
    scipy \
    sympy \
    h5py \
    pyscf \
    openfermion \
    openfermionpyscf \
    cirq==1.2 \
    cirq-ft==1.2 \
    TensorFox

# Install module_sdstate (specific version as required)
RUN pip install module_sdstate==0.1.1

# Set working directory
WORKDIR /app

# Copy all source files first
COPY Project.toml .
COPY Manifest.toml* .
COPY src/ src/
COPY test/ test/
COPY SAVED/ SAVED/
COPY *.jl .
COPY README.md .
COPY LICENSE .

# Set up environment for PythonCall to use our pre-installed Python
ENV PYTHON=/opt/venv/bin/python
ENV PYTHONPATH=/opt/venv/lib/python3.11/site-packages
ENV CONDAPKG_EXE=""
ENV CONDAPKG_BACKEND="Null"
ENV JULIA_PYTHONCALL_EXE=/opt/venv/bin/python

# Create a minimal CondaPkg.toml that does nothing
RUN echo '[deps]' > CondaPkg.toml && \
    echo '[pip.deps]' >> CondaPkg.toml

# Install Julia dependencies and precompile
RUN julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.precompile()"

# Test that QuantumMAMBO loads
RUN julia --project=. -e "using QuantumMAMBO; println(\"QuantumMAMBO.jl loaded successfully!\")"

# Create a convenient run script
RUN echo '#!/bin/bash' > /usr/local/bin/run_mambo.sh && \
    echo 'export PYTHON=/opt/venv/bin/python' >> /usr/local/bin/run_mambo.sh && \
    echo 'export PYTHONPATH=/opt/venv/lib/python3.11/site-packages' >> /usr/local/bin/run_mambo.sh && \
    echo 'export CONDAPKG_EXE=""' >> /usr/local/bin/run_mambo.sh && \
    echo 'export CONDAPKG_BACKEND="Null"' >> /usr/local/bin/run_mambo.sh && \
    echo 'export JULIA_PYTHONCALL_EXE=/opt/venv/bin/python' >> /usr/local/bin/run_mambo.sh && \
    echo 'cd /app' >> /usr/local/bin/run_mambo.sh && \
    echo 'julia --project=. L1.jl "$@"' >> /usr/local/bin/run_mambo.sh && \
    chmod +x /usr/local/bin/run_mambo.sh

# Default command
CMD ["julia", "--project=.", "-e", "using QuantumMAMBO; println(\"QuantumMAMBO.jl environment ready!\")"]

# Expose any ports if needed (for Jupyter notebooks, etc.)
EXPOSE 8888 