
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
RUN apt-get install -y python-pip python3 python-tweepy python-matplotlib-data python-numpy python-pandas python-psycopg2

RUN locale-gen "en_US.UTF-8" && dpkg-reconfigure locales

#RUN pg_dropcluster --stop 9.5 main && pg_createcluster --locale en_US.UTF-8 --start 9.5 main

RUN apt-get install -y vim htop


# Create the databse 
#RUN    /etc/init.d/postgresql start &&\
#    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
#    createdb -O docker --encoding=UTF8 docker

RUN echo "local   all             all                                     trust" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "host    all             all             127.0.0.1/32            trust" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf
EXPOSE 5432

# Create the databse 
#RUN    /etc/init.d/postgresql start &&\
#    su postgres -c "createdb -O postgres --encoding=UTF-8 --template=template0 --locale=en_US.UTF-8 peptodb"


#pg_upgradecluster --locale=en_US.utf8 --start 9.5 main

# https://docs.docker.com/engine/userguide/containers/dockervolumes/
#RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql && chown -R postgres /etc/postgresql && chown -R postgres /var/lib/postgresql
#VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

COPY peptodb/pepto.sh /pepto.sh
COPY peptodb/peptodb.sql /peptodb.sql
RUN chown postgres /pepto.sh /peptodb.sql && chmod 777 /pepto.sh /peptodb.sql

#RUN pg_createcluster --locale=en_US.UTF-8 9.5 main --start

# Set the default command to run when starting the container
USER root
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
#RUN bash /pepto.sh
#CMD ["bash", "/pepto.sh", ";", "bash"]
#CMD ["bash", "/pepto.sh", "&"]
#ENTRYPOINT ["bash", "pepto.sh"]
#CMD /pepto.sh 
#ENTRYPOINT bash

#CMD ["bash", "/pepto.sh", ";", "bash"]
# CMD ["/usr/lib/postgresql/9.5/bin/postgres", "-D", "/var/lib/postgresql/9.5/main", "-c", "config_file=/etc/postgresql/9.5/main/postgresql.conf"]


