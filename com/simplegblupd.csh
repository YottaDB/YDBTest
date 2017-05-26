#!/usr/local/bin/tcsh -f
# Sample Usage:
# $gtm_tst/com/simplegblupd.csh -instance INST2 -count 40

set opt_array      = ("\-instance" "\-internal" "\-count")
set opt_name_array = ("instance"   "helpercall" "count")
source $gtm_tst/com/getargs.csh $argv 

if (! $?helpercall) then
	# wrapper section:
	if (! -e update_stat.txt) touch update_stat.txt
	set statline = `cat update_stat.txt`
	# create the starting point:
	$MSR RUN $instance "set msr_dont_trace; echo $statline >>! update_statm.txt"
	$MSR RUN $instance "$gtm_tst/com/simplegblupd.csh $argv -internal" > simplegblupd_dbg.log
	$tail -n 1 simplegblupd_dbg.log >! update_stat.txt
	cat simplegblupd_dbg.log
else
	# actual call:
	$convert_to_gtm_chset update_statm.txt
	$GTM << EOF >&! simplegblupd.log
do ^simplegblupd($count)
halt
EOF
cat simplegblupd.log
cat update_statm.txt	# this has to be the last line of output
endif
#do ^simplegblupd($cnt,$stpnt,$stval)
