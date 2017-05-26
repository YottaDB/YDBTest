#! /usr/local/bin/tcsh -f
#######################################################################################################
# mu_bkup_change_permission.csh
# The test is for MUPIP BACKUP with multiple regions with enough data in the files so that we have time
# to "mess with them" a bit and cause errors.
# We will do an online MUPIP backup when the updates are going on and those processes tries to copy the
# dirty blocks into a temporary file when the shared memory segments are already FULL.
# At this point we will change the permission of those temporary files
# and cause the MUPIP backup to fail.We will then restart the backup to be sucessfull.
#######################################################################################################
#
alias stopfindfile 'touch ./baktmp/endloop.txt; $lsof >>&! lsof1.outx ; $ps >>&! ps1.outx ; date >&! date1.outx; sleep 2'
alias stopsubtest '$gtm_exe/mumps -run stop^largeupdates; $gtm_exe/mumps -run wait^largeupdates; unsetenv GTM_BAKTMPDIR' 
echo "# mupip online backup test for large databases and improper temp file handling"
echo "# The below backup should fail"
#
source $gtm_tst/$tst/u_inref/retry_driver.csh "mu_bkup_change_permission"
