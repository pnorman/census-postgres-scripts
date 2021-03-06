#!/bin/bash

# Make a data directory in ephemeral stoage
sudo mkdir -p /mnt/tmp
sudo chown ubuntu /mnt/tmp

# Grab the 2009 ACS 1 year
cd /mnt/tmp
mkdir -p acs2009_1yr
cd acs2009_1yr
sudo apt-get -y install unzip
curl -O "http://www2.census.gov/acs2009_1yr/summaryfile/Entire_SF/20091YRSF.zip"
unzip 20091YRSF.zip
curl -O "http://www2.census.gov/acs2009_1yr/summaryfile/UserTools/merge_5_6.txt"
mv merge_5_6.txt Sequence_Number_and_Table_Number_Lookup.txt
