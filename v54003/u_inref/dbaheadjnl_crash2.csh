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

BEGIN "Create small.dat database big.dat with journaling enabled:"
foreach dbname (small big)
	setenv gtmgbldir $dbname.gld
	$gtm_dist/mumps -run GDE << GDE_EOF
	change -segment DEFAULT -file=$dbname.dat
GDE_EOF
	$GDE exit
	$MUPIP create
	$MUPIP set -journal=enable,on,before,file=$dbname.mjl,epoch_interval=1 -reg "*"
end
END

BEGIN "Fill the small database with data"
	setenv gtmgbldir small.gld
	$gtm_dist/mumps -direct << GTM_EOF
	for i=1:1:50000 set ^x(i)=\$j(i,10)
GTM_EOF
END

BEGIN "Get the eov from journal file header"
        $MUPIP journal -show=header -backward small.mjl >&! jnlheader.txt
        set eov_tn = `$grep "End Transaction" jnlheader.txt | $tst_awk -F '[' '{print $2}' | $tst_awk -F ']' '{print $1}'`
END

BEGIN "Fill the big database with data"
	setenv gtmgbldir big.gld
	$gtm_dist/mumps -direct << GTM_EOF
	for i=1:1:100000 set ^x(i)=\$j(i,200)
GTM_EOF
END

BEGIN "get jnl_eovtn and curr_tn from database file header"
        $DSE dump -file -all >&! dbheader.txt
        $grep "jnl solid tn" dbheader.txt >&! jnlepochtn.txt
        set jnl_eovtn = `cat jnlepochtn.txt | $tst_awk '{print $8}'`
        $grep "Current transaction" dbheader.txt >&! currtn.txt
        set curr_tn = `cat currtn.txt | $tst_awk '{print $3}'`
END

# Take a backup of database and jnl files
cp small.mjl small.mjl_bak; cp big.mjl big.mjl_bak
cp small.dat small.dat_bak; cp big.dat big.dat_bak

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

#CASE	 : CRASH and (db->jnl_eovtn < jfh->eov_tn < db->eov_tn) is not true
#VERDIC	 : Dont continue

mv big.dat_bak small.dat  # db jnl-fname points to big.mjl
mv small.mjl_bak big.mjl  # Make jnl->eov_tn less than db->jnl_eovtn

#point gld to small.dat
setenv gtmgbldir small.gld
BEGIN "Database CRASH"
	$gtm_dist/mumps -direct << GTM_EOF
	zsy "$kill9 "_\$j
GTM_EOF
END

# This test does kill -9 followed by a MUPIP JOURNAL -RECOVER. A kill -9 could hit the running GT.M process while it
# is in the middle of executing wcs_wtstart. This could potentially leave some dirty buffers hanging in the shared
# memory. So, set the white box test case to avoid asserts in wcs_flu.c
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29

BEGIN "Recover should fail: jfh->eov_tn < db->curr_tn BUT db->jnl_eovtn > jnl->eov_tn"
	echo "curr_tn = $curr_tn"
	echo "eov_tn = $eov_tn"
	echo "jnl_eovtn = $jnl_eovtn"
        echo "$MUPIP journal -recover -backward -verbose -since=$since -before=$before * "
        $MUPIP journal -recover -backward -verbose -since=\"$since\" -before=\"$before\" "*"
END
