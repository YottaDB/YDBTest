#! /usr/local/bin/tcsh -f
#
#######################################################################################################
# mu_bkup_stop.csh
# The test is for MUPIP BACKUP with multiple regions with enough data in the files so that we have time
# to "mess with them" a bit and cause errors.
# We will do an online MUPIP backup when the updates are going on and those processes tries to copy the
# dirty blocks into a temporary file when the shared memory segments are already FULL.
# At this point we will do a MUPIP stop of the backup which should remove the temp files and
# shut off the backup flag. We will then restart the backup to be sucessfull.
########################################################################################################
#
echo "MUPIP ONLINE BACKUP TEST FOR LARGE DATABASES AND A MUPIP STOP AT HALF WAY STAGE"
echo "TRY THREE TIMES TO CATCH AND STOP THE BACKUP PROCESS"

#
alias stopsubtest '$gtm_exe/mumps -run stop^largeupdates ; $gtm_exe/mumps -run wait^largeupdates ; unsetenv GTM_BAKTMPDIR ; setenv skip_permission_check 0; setenv save_io 0'
source $gtm_tst/$tst/u_inref/retry_driver.csh "mu_bkup_stop"
