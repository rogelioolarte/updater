#!/bin/bash


# RKHUNTER

echo -e "Checking the database of RKHUNTER ..."
sudo rkhunter --propupd
sudo rkhunter --update
echo -e "In looking up of vulnerabilities ..."
sudo rkhunter --check


# CLAMAV

echo -e "Updating the database of CLAMAV ..."
sudo freshclam
echo -e "Checking the personal folder ..."
clamscan -r /home/nakako
exit 0
