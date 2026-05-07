FROM ubuntu:24.04

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    python3-venv \
    sudo \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install nix
RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes
ENV USER=root
ENV PATH="/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}"

# Configure nix with flakes
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf && \
    echo "trusted-users = root" >> /etc/nix/nix.conf

# Clone librelane
RUN git clone https://github.com/LibreLane/librelane /opt/librelane

# Pre-fetch the shell environment
# We use bash -c so we can source the nix profile
RUN . /root/.nix-profile/etc/profile.d/nix.sh && \
    cd /opt/librelane && \
    nix-shell shell.nix --run "echo 'Librelane Cache Primed'"

# Set up volare and PDK
# Since LibreLane handles PDKs via volare (standard for OpenLane), let's ensure it's provided.
# We will pull sky130A.
RUN . /root/.nix-profile/etc/profile.d/nix.sh && \
    cd /opt/librelane && \
    nix-shell shell.nix --run "pip install volare && volare enable --pdk sky130 --pdk-root /opt/volare"

ENV PDK_ROOT=/opt/volare
ENV PDK=sky130A

WORKDIR /workspace
ENTRYPOINT ["/bin/bash", "-c", ". /root/.nix-profile/etc/profile.d/nix.sh && nix-shell /opt/librelane/shell.nix --run \"$@\"", "--"]
