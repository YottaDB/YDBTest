#!/usr/local/bin/tcsh -f
#
# WARNING! Test is currently DISABLED as it exposed some buggage in rundown operations
# on R/O databases. Test is also incomplete as some form of validation should occur
# on an extract from syslogN.txt. Since test is not working, that validation has not
# yet been completed nor has a reference file been created. When GTM-7386 is completed,
# this test can be completed and enabled.
#

#
# Create R/O database, access w/mumps process, then kill -9 the process to leave the
# IPCs orphaned. Try to clean them up two ways - via targeted rundown and with an
# argumentless rundown
#
unsetenv gtm_usesecshr		# Make sure not tracking db initialization
$gtm_tst/com/dbcreate.csh .
$GTM << EOF			# Put a little bit of content into DB
Set ^a(1)=42
EOF
$gtm_com/IGS $gtm_dist/gtmsecshr "STOP"	# Make sure secshr not running so we can start it
chmod 444 mumps.dat		# DB is read-only now
set syslog_time1 = `date +"%b %e %H:%M:%S"`
echo
$echoline
echo "# R/O DB rundown via targeted rundown by region"
$echoline
$GTM << EOF
Set x=^a(1)
Set x=\$ZSigproc(\$Job,9)	; Kill ourselves leaving IPCs orphaned
EOF
#
# First attempt - targeted rundown by region
#
setenv gtm_usesecshr 1		# *ALWAYS* use secshr for lock wakeups, IPC cleanups, etc.
$MUPIP rundown -reg DEFAULT
#
# Check syslog content
#
set syslog_time2 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_time1" "$syslog_time2" syslog1.txt
#
# Validate was rundown correctly. Use ftok checker for this validation.
#
$gtm_dist/mumps -run checkftok
if (0 != $status) then
    cp mumps.dat mumps1.dat
    chmod 644 mumps.dat
    $gtm_dist/mupip rundown -file mumps.dat >& mumps1_rundown.txt
    chmod 444 mumps.dat
endif
#
# Second attempt - targeted rundown by file
#
echo
$echoline
echo "# R/O DB rundown via targeted rundown by file"
$echoline
$GTM << EOF
Set x=^a(1)
Set x=\$ZSigproc(\$Job,9)	; Kill ourselves leaving IPCs orphaned
EOF
$MUPIP rundown
set syslog_time3 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_time2" "$syslog_time3" syslog2.txt
#
# Validate was rundown correctly. Use ftok checker for this validation.
#
$gtm_dist/mumps -run checkftok
if (0 != $status) then
    cp mumps.dat mumps2.dat
    chmod 644 mumps.dat
    $gtm_dist/mupip rundown -file mumps.dat >& mumps2_rundown.txt
    chmod 444 mumps.dat
endif
#
# Third attempt - argumentless rundown
#
echo
$echoline
echo "# R/O DB rundown via argumentless rundown"
$echoline
$GTM << EOF
Set x=^a(1)
Set x=\$ZSigproc(\$Job,9)	; Kill ourselves leaving IPCs orphaned
EOF
$MUPIP rundown
set syslog_time4 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_time3" "$syslog_time4" syslog3.txt
#
# Validate was rundown correctly. Use ftok checker and integ for this final validation.
#
$gtm_dist/mumps -run checkftok
if (0 != $status) then
    cp mumps.dat mumps3.dat
    chmod 644 mumps.dat
    $gtm_dist/mupip rundown -file mumps.dat >& mumps3_rundown.txt
    chmod 444 mumps.dat
endif
$gtm_tst/com/dbcheck.csh
