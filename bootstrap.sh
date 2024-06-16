#!/usr/bin/env bash

############
#install all required libraries
############
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt -y install python3-pip python3-dev libpq-dev postgresql postgresql-contrib postgresql-client nginx curl

############
# create the DB and other DB settings
# refer to postgres.sh file for changing settings
############

./postgres.sh

#install pip and virtualenv
sudo -H pip3 install --upgrade pip
sudo -H pip3 install virtualenv

############
# Make changes here to point to the appropriate directory where the git project is cloned
#mkdir install
#cd install

virtualenv venv
source venv/bin/activate
#pip install django gunicorn psycopg2-binary
pip install -r requirements.txt

# this will not be required as the git project is cloned
#replace the below with git clone commands (either before or after creating virtual env)
#django-admin startproject mysite

deactivate
##############
#set up gunicorn
##############

#change these values as per the project gunicorn settings
SOCK_NAME="traq\.sock"
SOCK_FILE_NAME="traq\.socket"
USER="vagrant"
WORK_DIR="/vagrant/mysite"
GUNICORN_DIR="/vagrant/venv/bin/gunicorn"
PROJECT_NAME="mysite\.wsgi"

export SOCKNAME
export SOCK_FILE_NAME
export USER
export WORK_DIR
export GUNICORN_DIR
export PROJECT_NAME

#replace the gunicorn template with the above values
sed -i "s|gunicorn.sock|$SOCK_NAME|g" /vagrant/gunicorn.socket

sed -i "s|gunicorn.socket|$SOCK_FILE_NAME|g" /vagrant/gunicorn.service
sed -i "s|USER|$USER|g" /vagrant/gunicorn.service
sed -i "s|WORKDIR|$WORK_DIR|g" /vagrant/gunicorn.service
sed -i "s|GUNICORNDIR|$GUNICORN_DIR|g" /vagrant/gunicorn.service
sed -i "s|gunicorn.sock|$SOCK_NAME|g" /vagrant/gunicorn.service
sed -i "s|myproject2.wsgi|$PROJECT_NAME|g" /vagrant/gunicorn.service


#replace the below value with the project socket and service file name
SOCKET_FILE=traq.socket
SERVICE_FILE=traq.service
#replace the below value with the socket name without the .socket extension
SOCK_PROCESS=traqdev

#copy the templates with replaced values to the systemd folders
sudo cp /vagrant/gunicorn.socket /etc/systemd/system/$SOCKET_FILE
sudo cp /vagrant/gunicorn.service /etc/systemd/system/$SERVICE_FILE
sudo systemctl start $SOCKET_FILE
sudo systemctl enable $SERVICE_FILE
sudo systemctl restart $SOCK_PROCESS

################
#set up nginx
################
#change these values as per the project nginx settings
LISTEN_PORT="8000"
SERVER_NAME="localhost"
ROOT_DIR="/vagrant/mysite"

#replace the nginx template with the above values
sed -i "s|80|$LISTEN_PORT|g" /vagrant/mysite.nginx
sed -i "s|localhost|$SERVER_NAME|g" /vagrant/mysite.nginx
sed -i "s|ROOTDIR|$ROOT_DIR|g" /vagrant/mysite.nginx
sed -i "s|mysite.sock|$SOCK_NAME|g" /vagrant/mysite.nginx

#replace the below value with the nginx site-available file name
SITES_AVAIL=mysite

#copy the templates with replaced values to the systemd folders
sudo cp /vagrant/mysite.nginx /etc/nginx/sites-available/$SITES_AVAIL
sudo ln -s /etc/nginx/sites-available/$SITES_AVAIL /etc/nginx/sites-enabled
sudo systemctl restart nginx
sudo ufw allow 'Nginx Full'


################

