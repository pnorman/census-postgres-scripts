#!/bin/bash

# Clone the import scripts from git
cd /home/ubuntu
sudo apt-get -y install git
git clone git://github.com/censusreporter/census-postgres.git

# Create the schema
cd /home/ubuntu/census-postgres/acs2010_1yr
sed -i '1i SET search_path = acs2010_1yr, public;' *.sql
sudo -u postgres psql -c "DROP SCHEMA IF EXISTS acs2010_1yr; CREATE SCHEMA acs2010_1yr;"

# Create import tables
sudo -u postgres psql -f create_geoheader.sql
sudo -u postgres psql -f geoheader_comments.sql
sudo -u postgres psql -f create_tmp_geoheader.sql
sudo -u postgres psql -f drop_import_tables.sql
sudo -u postgres psql -f create_import_tables.sql

# Correct the directories in the import scripts
sed -i "s/\/<census_upload_root>\/acs2010_1yr\/All_Geographies_Not_Tracts_Block_Groups/\/mnt\/tmp\/acs2010_1yr\/geog/" /home/ubuntu/census-postgres/acs2010_1yr/import_geoheader.sql
sed -i "s/\/<census_upload_root>\/acs2010_1yr\/All_Geographies_Not_Tracts_Block_Groups/\/mnt\/tmp\/acs2010_1yr\/group1/" /home/ubuntu/census-postgres/acs2010_1yr/import_sequences.sql
sed -i "s/\/<census_upload_root>\/acs2010_1yr\/Tracts_Block_Groups_Only/\/mnt\/tmp\/acs2010_1yr\/group2/" /home/ubuntu/census-postgres/acs2010_1yr/import_sequences.sql

# Slurp in the actual data
sudo -u postgres psql -f import_geoheader.sql
sudo -u postgres psql -f import_sequences.sql # This takes ~5 minutes
sudo -u postgres psql -f parse_tmp_geoheader.sql
sudo -u postgres psql -f store_by_tables.sql
sudo -u postgres psql -f insert_into_tables.sql # This takes ~5 minutes
sudo -u postgres psql -f view_stored_by_tables.sql

# Drop temp tables
sudo -u postgres psql -f 04_drop_import_tables.sql
