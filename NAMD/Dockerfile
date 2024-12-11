FROM quay.io/jeani/base_ubuntu_mpich_ucx_cuda:latest

# Set environment variables for paths
ENV NAMD_DIR=/opt/namd-build/NAMD_Git-2022-07-21_Source
ENV CHARM_DIR=/opt/namd-build/NAMD_Git-2022-07-21_Source/charm-v7.0.0
ENV FFTW_DIR=${NAMD_DIR}/fftw
WORKDIR /opt/namd-build

# Copy NAMD and Charm sources into the container
COPY ./NAMD_Git-2022-07-21_Source.tar.gz .
COPY ./charm-7.0.0.tar.gz .

# Extract NAMD source
RUN tar -xvzf NAMD_Git-2022-07-21_Source.tar.gz && \
    rm NAMD_Git-2022-07-21_Source.tar.gz

WORKDIR $NAMD_DIR
COPY ./charm-7.0.0.tar.gz .

# Extract and build Charm++
RUN tar -xvzf charm-7.0.0.tar.gz && \
    rm charm-7.0.0.tar.gz && \
    cd $CHARM_DIR && \
    ./build charm++ mpi-linux-x86_64-smp --with-production

# Install FFTW
RUN wget -q --no-check-certificate http://www.fftw.org/fftw-3.3.9.tar.gz && \
    tar -xvzf fftw-3.3.9.tar.gz && \
    cd fftw-3.3.9 && \
    ./configure --enable-float --enable-threads --prefix=$FFTW_DIR CFLAGS="-fPIC" && \
    make -j$(nproc) && make -j$(nproc) install && \
    rm -rf fftw-3.3.9 fftw-3.3.9.tar.gz

# Install TCL
RUN wget http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-linux-x86_64.tar.gz && \
    tar xzf tcl8.5.9-linux-x86_64.tar.gz && \
    mv tcl8.5.9-linux-x86_64 tcl && \
    rm tcl8.5.9-linux-x86_64.tar.gz && \
    wget http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-linux-x86_64-threaded.tar.gz && \
    tar xzf tcl8.5.9-linux-x86_64-threaded.tar.gz && \
    mv tcl8.5.9-linux-x86_64-threaded tcl-threaded && \
    rm tcl8.5.9-linux-x86_64-threaded.tar.gz

# Configure and build NAMD
RUN ./config Linux-x86_64-g++ --charm-arch mpi-linux-x86_64-smp && \
    cd Linux-x86_64-g++ && \
    make -j$(nproc) VERBOSE=1

# Copy the NAMD binary to /usr/local/bin for easy access
RUN cp $NAMD_DIR/Linux-x86_64-g++/namd2 /usr/local/bin

# Set the default entry point to run the NAMD binary
ENTRYPOINT ["/usr/local/bin/namd2"]
