FROM python:3.8-slim

RUN apt-get update && apt install -y procps g++ && apt-get clean

WORKDIR /opt/analysis

COPY environment.yml /opt/analysis/environment.yml

# Install miniconda to /miniconda
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /miniconda && \
    rm ~/miniconda.sh
ENV PATH="/miniconda/bin:${PATH}"

# Update conda and install sourmash_plugin_branchwater from conda-forge
RUN conda update -y conda && \
    conda install -y -c conda-forge sourmash_plugin_branchwater

# Install any needed packages specified in environment.yml
RUN pip install --no-cache-dir -r environment.yml

CMD ["bash"]