#! /usr/local/bin/tcsh -f
#
#dbcreate.csh called by createdb_start_updates.csh.
echo "The following backup should run successfully"
mkdir online4
$MUPIP backup -online "*" ./online4 >&! online4.out
$grep "BACKUP COMPLETED" online4.out
if !($status) then
        echo "PASS! BACKUP successfull"
else
        echo "TEST-E-ERROR BACKUP failed"
endif
# it takes a little extra seconds to reset the file headers after the backup
# so do a buffer flush before taking the dump output
$DSE << dse_eof >&! buffer_flush.out
buffer_flush
find -reg=BREG
buffer_flush
find -reg=CREG
buffer_flush
find -reg=DEFAULT
buffer_flush
quit
dse_eof
$DSE << dse_eof >&! dse_dump.out
dump -file -all
find -reg=BREG
dump -file -all
find -reg=CREG
dump -file -all
find -reg=DEFAULT
dump -file -all
quit
dse_eof
#
echo "We expect all the following fields to be zero to confirm a successfull backup"
$grep "Backup_errno" dse_dump.out |$tst_awk '{print "Backup_errno "$6}'
$grep "Shmpool blocked" dse_dump.out |$tst_awk '{print "Shmpool blocked "$3}'
$grep "Backup blocks" dse_dump.out |$tst_awk '{print "Backup blocks "$6}'
#
# Stop the bg processes AND wait for all GT.M processes to die down
# Note that stopping and waiting is done in two separate GT.M processes since the first one does database updates
# while the second one relies on the fact that the process has done NO database references/updates.
stopsubtest
$gtm_tst/com/dbcheck.csh
#                                                                                                                 

