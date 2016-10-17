
FROM alpine:latest
MAINTAINER cgrant@ou.edu

RUN apk update && apk add ca-certificates bash

RUN apk add git python3-dev gcc g++ make tmux imagemagick-dev freetype-dev make gfortran
# https://github.com/docker-library/python/issues/112
RUN ln -s locale.h /usr/include/xlocale.h
RUN pip3 install --upgrade pip setuptools && pip3 install cython tweepy numpy matplotlib pandas

RUN apk add postgresql-dev && pip3 install --upgrade psycopg2

# Copy over a keyword file
COPY ingestor/key-words.json /key-words.json
# Copy python file
COPY ingestor/gettweets.py /gettweets.py

# Set the default command to run when starting the container
# Start the ingestor
CMD ["python3", "/gettweets.py"]


