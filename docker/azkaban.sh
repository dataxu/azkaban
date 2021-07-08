#!/bin/bash
set -e

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Needs azkaban version."
fi

apt-get update
apt-get install mailutils -y
apt-get install telnet -y
apt-get install git -y
apt-get install git-core -y
apt-get install vim -y
apt-get install zip -y
apt-get install s3cmd -y
apt-get install awscli -y
apt-get install postgresql -y

cd /azkaban
./gradlew installDist -x test

mkdir -p /root/.aws/
