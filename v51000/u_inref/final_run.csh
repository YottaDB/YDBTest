#! /usr/local/bin/tcsh -f
#
# dbcreate.csh called by createdb_start_updates.csh.
echo "# Check for a normal backup now. It should succeed"
mkdir online4
$MUPIP backup -online "*" ./online4 >&! online4.out
$grep "BACKUP COMPLETED" online4.out
if !($status) then
        echo "PASS! BACKUP successfull"
else
        echo "TEST-E-ERROR BACKUP failed"
endif
stopsubtest
$gtm_tst/com/dbcheck.csh

