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
# setting up the django project for the product
############
# Make changes here to point to the appropriate directory where the git project is cloned

PROJECT_DIR=sales-order-management
GIT_BRANCH=develop

git clone -b $GIT_BRANCH $GIT_REPO_URL

# go to the django project dir and install venv
cd $PROJECT_DIR
virtualenv venv
source venv/bin/activate
#install the required libs in venv
pip install -r requirements.txt

deactivate
cd ..
##############
#set up gunicorn
##############

#change these values as per the project gunicorn settings
SOCK_NAME="traqdev\.sock"
SOCK_FILE_NAME="traqdev\.socket"
USER="riverlearning"
WORK_DIR="/home/riverlearning/traqdev/sales-order-management"
GUNICORN_DIR="/home/riverlearning/traqdev/sales-order-management/venv/bin/gunicorn"
PROJECT_NAME="salesOrderManagement\.wsgi"

export SOCKNAME
export SOCK_FILE_NAME
export USER
export WORK_DIR
export GUNICORN_DIR
export PROJECT_NAME

#replace the gunicorn template with the above values
sed -i "s|gunicorn.sock|$SOCK_NAME|g" /home/riverlearning/traqdev/gunicorn.socket

sed -i "s|gunicorn.socket|$SOCK_FILE_NAME|g" /home/riverlearning/traqdev/gunicorn.service
sed -i "s|USER|$USER|g" /home/riverlearning/traqdev/gunicorn.service
sed -i "s|WORKDIR|$WORK_DIR|g" /home/riverlearning/traqdev/gunicorn.service
sed -i "s|GUNICORNDIR|$GUNICORN_DIR|g" /home/riverlearning/traqdev/gunicorn.service
sed -i "s|gunicorn.sock|$SOCK_NAME|g" /home/riverlearning/traqdev/gunicorn.service
sed -i "s|myproject2.wsgi|$PROJECT_NAME|g" /home/riverlearning/traqdev/gunicorn.service


#replace the below value with the project socket and service file name
SOCKET_FILE=traqdev.socket
SERVICE_FILE=traqdev.service
#replace the below value with the socket name without the .socket extension
SOCK_PROCESS=traqdev

#copy the templates with replaced values to the systemd folders
sudo cp /home/riverlearning/traqdev/gunicorn.socket /etc/systemd/system/$SOCKET_FILE
sudo cp /home/riverlearning/traqdev/gunicorn.service /etc/systemd/system/$SERVICE_FILE
sudo systemctl start $SOCKET_FILE
sudo systemctl enable $SOCKET_FILE
sudo systemctl restart $SOCK_PROCESS

################
#set up nginx
################
#change these values as per the project nginx settings
LISTEN_PORT="80"
SERVER_NAME="traqdev.riverlearning.in"
ROOT_DIR="/home/riverlearning/traqdev/sales-order-management"

#replace the nginx template with the above values
sed -i "s|80|$LISTEN_PORT|g" /home/riverlearning/traqdev/mysite.nginx
sed -i "s|localhost|$SERVER_NAME|g" /home/riverlearning/traqdev/mysite.nginx
sed -i "s|ROOTDIR|$ROOT_DIR|g" /home/riverlearning/traqdev/mysite.nginx
sed -i "s|mysite.sock|$SOCK_NAME|g" /home/riverlearning/traqdev/mysite.nginx

#replace the below value with the nginx site-available file name
SITES_AVAIL=traqdev

#copy the templates with replaced values to the systemd folders
sudo cp /home/riverlearning/traqdev/mysite.nginx /etc/nginx/sites-available/$SITES_AVAIL
sudo ln -s /etc/nginx/sites-available/$SITES_AVAIL /etc/nginx/sites-enabled
sudo systemctl restart nginx
sudo ufw allow 'Nginx Full'


################

