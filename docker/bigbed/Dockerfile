FROM phusion/baseimage
MAINTAINER Dan Leehr <dan.leehr@duke.edu>

# fetchChromSizes can use mysql, wget, or FTP
RUN apt-get update && apt-get install -y \
  wget

RUN mkdir /bigbed

WORKDIR /bigbed

# Fetch tools from hgdownload
RUN curl -SLO http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/bedToBigBed
RUN curl -SLO http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/fetchChromSizes
RUN curl -SLO http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/hubCheck
RUN chmod +x /bigbed/*
ENV PATH /bigbed:$PATH
