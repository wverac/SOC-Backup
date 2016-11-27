#!/bin/bash
# wvera@suse.com
# Backup SOC5: Crowbar (admin), DB, proposals and cookbooks path.

BackupPath="SOC-BACKUPS"
BackupDate="$(date +%m-%d-%Y-%H%M)"
SOCController="control-1"

mkdir -p ${BackupPath}/${BackupDate}
cd ${BackupPath}/${BackupDate}

/usr/sbin/crowbar-backup backup SOC5-Admin-BACKUP-$(date +%m-%d-%Y-%H%M%S).tar.gz
crowbar batch export > Crowbar-Export-$(date +%m-%d-%Y-%H%M%S).yaml
ssh $SOCController "sudo -i -u postgres  pg_dumpall > SOC-DB-BACKUP-$(date +%m-%d-%Y-%H).sql"
scp $SOCController:/root/SOC-DB-BACKUP-$(date +%m-%d-%Y-%H).sql .
tar czvf opt-dell-$(date +%m-%d-%Y-%H%M%S).tar.gz /opt/dell/
