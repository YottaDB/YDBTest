#!/usr/local/bin/tcsh
# Usage: simpleinstanceupdate.csh count [LARGE]
#
# The updates will be of the form SET ^GBL("INSTANCEx",i)=i, where x is the
# instance no, and i is just a counter (per instance). Let's keep writing the
# value of this counter to a file (simpleinstanceupdate_counter.txt) so that
# consecutive updates from the same instance can keep counting up.
#
# Note that while the routine is not perfectly "safe", i.e. there might be a
# discrepancy between the counter noted in the file and the counter used for
# the global if the routine did crash in between the writing of the file and
# set'ing the global, there will not be any problems because of the way this
# script is used.In all the subtests this script is used, the server is crashed
# after the updates are completed, i.e. this routine completes and exits.  One
# thing to note is not to use any globals in this routine (other than the one
# we are set'ing), so that we do not increment the seqno inadvertently (and we
# do not send settings about this instance to the other instances).
#
if ("V4" == `echo $gtm_exe:h:t|cut -c1-2`) then
	set mrout="simple"
	cp $gtm_tst/com/simpleinstanceupdate.m simple.m
else
	set mrout="simpleinstanceupdate"
endif
set largeorsmall = 0
if ("LARGE" == "$2") set largeorsmall = 1
$GTM << EOF |& cat
set instancename="$gtm_test_cur_pri_name"
set noofupdates=$1
do ^$mrout($largeorsmall)
halt
EOF
