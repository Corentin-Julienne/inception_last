#!/bin/bash

# simple script used to copy the content of the shared folder into the working directory used to exec 
# inception structure
rm -rf /home/cjulienn/inception
mkdir -p /home/cjulienn/inception
cp -rf /media/sf_inception/* /home/cjulienn/inception
