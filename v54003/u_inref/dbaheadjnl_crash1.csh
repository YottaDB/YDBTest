#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2011, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# crash: 	If database/journaling is crashed, backward recovery should continue.(eov_tn < curr_tn)

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

#TEST BEGINS#
BEGIN "Create big.dat with journaling enabled:"
	setenv gtmgbldir big.gld
	$gtm_dist/mumps -run GDE << GDE_EOF
	change -segment DEFAULT -file=big.dat
GDE_EOF
	$GDE exit
	$MUPIP create
	$MUPIP set -journal=enable,on,before,file=big.mjl,epoch_interval=1 -reg "*"
END

BEGIN "Populate big database "
	$gtm_dist/mumps -direct << GTM_EOF
	for i=1:1:100000 set ^x(i)=\$j(0,200)
GTM_EOF
END

# Get the since time from the journal extract for backward recovery.
BEGIN "Get the timestamp of fisrt epoch written to journal:"
	$MUPIP journal -extract -noverify -detail -for -fences=none big.mjl
	$head big.mjf | $grep EPOCH | $tst_awk -F "\\" '{print $2}' >&! since_timestamp.txt
	$tail big.mjf | $grep EPOCH | $tst_awk -F "\\" '{print $2}' >&! before_timestamp.txt
	set since_ts = `cat since_timestamp.txt`
	set before_ts = `cat before_timestamp.txt`
	$gtm_dist/mumps -direct << GTM_EOF >&! since_date.txt
	write \$zd("$since_ts","DD-MON-YEAR 24:60:SS");
GTM_EOF
	$gtm_dist/mumps -direct << GTM_EOF >&! before_date.txt
	write \$zd("$before_ts","DD-MON-YEAR 24:60:SS");
GTM_EOF
	set since = `$grep "^[0-9]" since_date.txt`
	set before = `$grep "^[0-9]" before_date.txt`
END

#CASE	 : CRASH and (db->jnl_eovtn < jfh->eov_tn < db->eov_tn) is true
#VERDICT : Continue
BEGIN

BEGIN "CRASH database while updating it"
	$gtm_dist/mumps -direct << GTM_EOF
	for i=1:1:100000 set ^x(i)=\$j(1,200)
	zsy "$kill9 "_\$j
GTM_EOF
END

# This test does kill -9 followed by a MUPIP JOURNAL -RECOVER. A kill -9 could hit the running GT.M process while it
# is in the middle of executing wcs_wtstart. This could potentially leave some dirty buffers hanging in the shared
# memory. So, set the white box test case to avoid asserts in wcs_flu.c
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29

BEGIN "get jnl_eovtn and curr_tn from database file header"
        $DSE dump -file -all >&! dbheader.txt
        $grep "jnl solid tn" dbheader.txt >&! jnlepochtn.txt
        set jnl_eovtn = `cat jnlepochtn.txt | $tst_awk '{print $8}'`
        $grep "Current transaction" dbheader.txt >&! currtn.txt
        set curr_tn = `cat currtn.txt | $tst_awk '{print $3}'`
END

BEGIN "Recover should be succssful: db->jnl_eovtn <= jfh->eov_tn < db->curr_tn"
	echo jnl_eovtn = $jnl_eovtn
	echo curr_tn = $curr_tn
        echo "$MUPIP journal -recover -backward -verbose -since=$since -before=$before * >&! RECOVER.log"
        $MUPIP journal -recover -backward -verbose -since=\"$since\" -before=\"$before\" "*" >&! RECOVER.log

	$grep '%GTM-S-JNLSUCCESS, Recover successful' RECOVER.log >&! success.log
	if ( ! $status ) then
		echo "Recovery is successful"
	endif
END
