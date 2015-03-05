#!/bin/bash

# Script to set up a Django project on Vagrant.

# Installation settings

PROJECT_NAME=$1

DB_NAME=$PROJECT_NAME
VIRTUALENV_NAME=$PROJECT_NAME
PGSQL_VERSION='9.4'

SECRET_KEY=$2
PROD_DB_PASSWORD=$3
DEV_DB_PASSWORD=$4
TEST_DB_PASSWORD=$5

PROD_DB_USER=$DB_NAME'_prod_user'
PROD_DB=$DB_NAME'_prod'
DEV_DB_USER=$DB_NAME'_dev_user'
DEV_DB=$DB_NAME'_dev'
TEST_DB_USER=$DB_NAME + 'test_user'
TEST_DB=$DB_NAME'_test'

PROJECT_DIR=/home/vagrant/$PROJECT_NAME
VIRTUALENV_DIR=/home/vagrant/.virtualenvs/$PROJECT_NAME
LOCAL_SETTINGS_PATH="/$PROJECT_NAME/settings/local.py"

# Need to fix locale so that Postgres creates databases in UTF-8
cp -p $PROJECT_DIR/etc/install/etc-bash.bashrc /etc/bash.bashrc
locale-gen en_US.UTF-8
dpkg-reconfigure locales

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Install essential packages from Apt
apt-get update -y
# Python 2 dev packages
apt-get install -y build-essential python python-dev python-virtualenv python-pip virtualenvwrapper
# Python 3 dev packages
apt-get install -y python3 python3-dev python3-virtualenv python3-pip python3-virtualenv
# Dependencies for image processing with Pillow (drop-in replacement for PIL)
# supporting: jpeg, tiff, png, freetype, littlecms
# (pip install pillow to get pillow itself, it is not in requirements.txt)
apt-get install -y libjpeg-dev libtiff-dev zlib1g-dev libfreetype6-dev liblcms2-dev
# Git (we'd rather avoid people keeping credentials for git commits in the repo, but sometimes we need it for pip requirements that aren't in PyPI)
apt-get install -y git
# Extra packages used for Django
apt-get install -y libyaml-dev node-less redis-server yui-compressor nginx

# Postgresql
if ! command -v psql; then
    apt-get install -y postgresql libpq-dev
    cp $PROJECT_DIR/etc/install/pg_hba.conf /etc/postgresql/$PGSQL_VERSION/main/
	service postgresql reload
fi

# Setup nginx user
mkdir -p /webapps/virtualenvs
groupadd webapps
useradd -g webapps -M -d /webapps -s webapps
passwd -d webapps
chown -R webapps:webapps /webapps
chown -R 775 /webapps

# bash environment global setup
cp -p $PROJECT_DIR/etc/install/bashrc /home/vagrant/.bashrc

# ---

# postgresql setup for project
createuser -l -P -S -d $PROD_DB_USER <<< $PROD_DB_PASSWORD
createuser -l -P -S -d $DEV_DB_USER <<< $DEV_DB_PASSWORD
createuser -l -P -S -d $TEST_DB_USER <<< $TEST_DB_PASSWORD
createdb -U$PROD_DB_USER $PROD_DB
createdb -U$DEV_DB_USER $DEV_DB
createdb -U$TEST_DB_USER $TEST_DB

# Pretty psqlrc
cp -p $PROJECT_DIR/etc/install/bashrc /home/vagrant/.psqlrc

# virtualenv setup for project
su - vagrant -c "/usr/bin/virtualenv -p `which python3` $VIRTUALENV_DIR && \
    echo $PROJECT_DIR > $VIRTUALENV_DIR/.project && \
    $VIRTUALENV_DIR/bin/pip install -r $PROJECT_DIR/requirements.txt"

echo "workon $VIRTUALENV_NAME" >> /home/vagrant/.bashrc

# Set execute permissions on manage.py, as they get lost if we build from a zip file
chmod a+x $PROJECT_DIR/manage.py

# Django project setup
su - vagrant -c "source $VIRTUALENV_DIR/bin/activate && \
	cd $PROJECT_DIR && ./manage.py syncdb --noinput && ./manage.py migrate && \
	./manage.py collectstatic <<< yes"

# Add settings/local.py to gitignore
if ! grep -Fqx $LOCAL_SETTINGS_PATH $PROJECT_DIR/.gitignore
then
    echo $LOCAL_SETTINGS_PATH >> $PROJECT_DIR/.gitignore
fi
