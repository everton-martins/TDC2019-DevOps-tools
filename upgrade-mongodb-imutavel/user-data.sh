#!/bin/bash
sudo su -
chown mongod.mongod -R /mongodb
sleep 5
service mongod start

