
FROM alpine:latest
MAINTAINER cgrant@ou.edu

RUN apk update && apk add ca-certificates bash

RUN apk add git python3-dev gcc g++ make tmux imagemagick-dev freetype-dev make gfortran
# https://github.com/docker-library/python/issues/112
RUN ln -s locale.h /usr/include/xlocale.h
RUN pip3 install --upgrade pip setuptools && pip3 install cython tweepy


RUN mkdir -p /data/tweetsdb

# Copy python file
COPY gettweets.py gettweets.py

# Set the default command to run when starting the container
# Start the ingestor
CMD ["python3", "gettweets.py"]


