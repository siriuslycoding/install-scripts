#!/bin/bash

############
#set up db name, user, password,etc
############

#change these values as per your db settings
# for local dev set up - use ip address = 0.0.0.0/0
DB_NAME=traqdev
DB_PASSWORD=r1verlearning
DB_ROLE=traqdevrole
ENCODING=utf8
IP_ADDRESS=0.0.0.0/0

export DB_NAME
export DB_PASSWORD
export DB_ROLE
export ENCODING
export IP_ADDRESS

#execute DB commands
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
sudo -u postgres psql -c "CREATE USER $DB_ROLE WITH PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "ALTER ROLE $DB_ROLE SET client_encoding TO '$ENCODING';"
sudo -u postgres psql -c "ALTER ROLE $DB_ROLE SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "ALTER ROLE $DB_ROLE SET timezone TO 'UTC';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_ROLE;"
sudo -u postgres psql -c "CREATE EXTENSION adminpack;"

#check that the version of postgres is 12. If not change the directory below to the right version 
echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/12/main/postgresql.conf
echo "host    all     all             $IP_ADDRESS                 md5" | sudo tee -a /etc/postgresql/12/main/pg_hba.conf
