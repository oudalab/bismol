#!/bin/bash

# Run the database 
/etc/init.d/postgresql start

# Checks to see if the database is installed if not, it installs it
checkdb () {
  local dbexists=$(su postgres -c "psql -lqt | cut -d \| -f 1 | grep $PGDATABASE | wc -l" )
  if [[ $dbexists = 1 ]]; then
    return 0
  else
    return 1
  fi
}

  if `checkdb`; then
    # database exists
    # $? is 0
    echo "******DATABASE FOUND******"
  else
    echo "******CREATING DATABASE******"
    su postgres -c "createdb -O postgres --encoding=UTF-8 --template=template0 --locale=en_US.UTF-8 peptodb"
    #psql -d docker -f /peptodb.sql

    #psql <<- EOSQL
    #CREATE ROLE $PGUSER WITH LOGIN ENCRYPTED PASSWORD '${PGPASSWORD}' CREATEDB;
    #EOSQL

    #psql <<- EOSQL
    #   CREATE DATABASE $PGDATABASE WITH OWNER $PGUSER TEMPLATE template1 ENCODING 'UTF-8';
    #EOSQL

    #psql <<- EOSQL
    #   GRANT ALL PRIVILEGES ON DATABASE $PGDATABASE TO $PGUSER;
    #EOSQL
    #fi
    echo "Adding tables"
    su postgres -c "psql -d $PGDATABASE -f /peptodb.sql"

    echo ""
    echo "******DATABASE CREATED******"
  fi
