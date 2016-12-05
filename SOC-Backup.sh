#!/bin/bash
# wvera@suse.com
# Simple, rustic and graceless script to backup SUSE OpenStack Cloud (SOC)
# Tested in SOC5 and SOC6

# Define vars
SOCController="controller1"
BackupPath="SOC-BACKUPS"
BackupDate="$(date +%m-%d-%Y-%H%M)"

mkdir -p ${BackupPath}/${BackupDate}

# Trying to determine which SOC version is installed
SOCVersion="$(zypper se -i -t product | awk '/cloud/ {print}' | cut -d"|" -f3 | sed "s/ //g")"
if [ "$(echo "${SOCVersion: -1}")" -eq "5" ];then
     echo "Backing up \"SUSE OpenStack Cloud 5\""
     # Dirty way to invoke crowbar-backup in non-interactive mode
     sleep 2 | echo "y" | crowbar-backup backup ${BackupPath}/${BackupDate}/SOC-Admin-backup-${BackupDate}.tar.gz
  elif
     [ "$(echo "${SOCVersion: -1}")" -eq "6" ];then
  echo "Backing up \"SUSE OpenStack Cloud 6\""
     crowbarctl backup create ${BackupDate}
     crowbarctl backup download ${BackupDate} ${BackupPath}/${BackupDate}/SOC-Admin-backup-${BackupDate}.tar.gz
  else
     echo "No SOC installations found"
fi

# Exporting proposals in YAML file
/usr/bin/crowbar batch export > ${BackupPath}/${BackupDate}/Crowbar-proposals-export-${BackupDate}.yaml

# DB Backup, the correct way, according with the official documentation:
# https://www.postgresql.org/docs/9.6/static/backup-dump.html
ssh $SOCController "sudo -i -u postgres  pg_dumpall > SOC-DB-backup-${BackupDate}.sql"
scp $SOCController:/root/SOC-DB-backup-${BackupDate}.sql ${BackupPath}/${BackupDate}/
ssh $SOCController "rm /root/SOC-DB-backup-${BackupDate}.sql"

# Backup cookbooks in "/opt/dell/chef/cookbooks/"
# Maybe we should be a little paranoid and back up the whole path "/opt/dell"?
tar -C / -cPzf  ${BackupPath}/${BackupDate}/cookbooks-backup.${BackupDate}.tar.gz /opt/dell/chef/cookbooks/
