
FROM ubuntu:wily
MAINTAINER cgrant@ou.edu

# Help https://docs.docker.com/engine/installation/linux/ubuntulinux/
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# Install Postgres
# Help: https://docs.docker.com/engine/examples/postgresql_service/
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb https://apt.postgresql.org/pub/repos/apt/ wily-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN echo "deb https://apt.dockerproject.org/repo ubuntu-wily main" > /etc/apt/sources.list.d/docker.list

RUN apt-get install -y apt-transport-https
RUN apt-get update && apt-get install -y python-software-properties software-properties-common postgresql-9.5 postgresql-client-9.5 postgresql-contrib-9.5 postgresql-contrib-9.5 postgresql-plpython3-9.5 postgresql-9.5-postgis-scripts postgresql-hll postgresql-client-common postgresql-server-dev-9.5 postgresql-common
# Install python
RUN apt-get install -y python-pip python3 python-tweepy python-matplotlib-data python-numpy python-pandas python-psycopg2 python3-setuptools

RUN apt-get install -y python3-pip

RUN pip3 install tweepy psycopg2

# Copy over a keyword file
COPY ingestor/key-words.json /key-words.json
# Copy python file
COPY ingestor/gettweets.py /gettweets.py

# Set the default command to run when starting the container
# Start the ingestor
CMD ["python3", "/gettweets.py"]


