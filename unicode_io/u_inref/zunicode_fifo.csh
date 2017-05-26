#!/usr/local/bin/tcsh -f
$switch_chset UTF-8 
# If this subtest is modified then a corresponding change to unicode_fifo.csh may be required
# increase gtm_non_blocked_write_retries so fifo test will still pass with non-blocking writes
setenv gtm_non_blocked_write_retries 1000

source $gtm_tst/com/dbcreate.csh mumps 1 
$GTM << aaa
write "do ^zunicodefifo(""UTF-8"")",!
do ^zunicodefifo("UTF-8")
h
aaa
#
$GTM << aaa
write "do ^zunicodefifo(""UTF-16"")",!
do ^zunicodefifo("UTF-16")
aaa
#
$GTM << aaa
write "do ^zunicodefifo(""UTF-16LE"")",!
do ^zunicodefifo("UTF-16LE")
aaa
#
$GTM << aaa
write "do ^zunicodefifo(""UTF-16BE"")",!
do ^zunicodefifo("UTF-16BE")
aaa
#
$GTM << aaa
write "do ^zunicodefifo(""M"")",!
do ^zunicodefifo("M")
aaa
#
$gtm_tst/com/dbcheck.csh
