#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# C9L06003421 : If crash occurs in case of multi-region database, only those regions which were open at
#               the time of crash should participate in the tp_resolve_time calculations

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

BEGIN "Create database and enable journaling with desired settings"
setenv gtm_test_jnl NON_SETJNL
setenv tst_jnl_str "$tst_jnl_str,epoch_interval=1"
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 6
$MUPIP set -region "*" $tst_jnl_str >& jnl_on.out
END

BEGIN "Add 10 transaction in a, b and c regions spanned across 1 seconds"
#When we exit GTM, in each journal file, EOF record will be added around at the same time
foreach name (a b c)
$GTM <<GTMEOF
    for i=1:1:10 tstart  s ^$name(i)=\$j(i,200) tcommit  hang 1
GTMEOF
end
END

# Following sleep will ensure the gap between updates on cleanly terminated database
# and crashed database of 5 epoch interval
sleep 5

BEGIN "Add updates transaction in d region and crash the database"
$GTM <<GTMEOF
    set ^d6=\$j("ddddddddddddddddddddddddddd",200)
    hang 1  ; This hang will ensure that that ^d(6) update is synced in database and journal files when ^d(7) update is tried
    set ^d7=\$j("777",200)
    zsy "$kill9 "_\$j
GTMEOF
END

BEGIN "Add updates transaction in e region and crash the database"
$gtm_exe/mumps -direct <<GTMEOF
    hang 5  ; This hang will ensure that there is gap between updates on datase d.dat and e.dat
    set ^e6=\$j("eee",200)
    hang 1  ; This hang will ensure that the update ^e(6) will be written to database when ^e(7) update is tried
    set ^e7=\$j("777",200)
    zsy "$kill9 "_\$j
GTMEOF
END

# This test does kill -9 followed by a MUPIP JOURNAL -RECOVER. A kill -9 could hit the running GT.M process while it
# is in the middle of executing wcs_wtstart. This could potentially leave some dirty buffers hanging in the shared
# memory. So, set the white box test case to avoid asserts in wcs_flu.c
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 29

BEGIN "Do backward recovery"
$MUPIP journal -recover -backward -verbose "*" >&! RECOVER.log
END

BEGIN "Extract the journal for region d region"
$MUPIP journal -extract -noverify -detail -for -fences=none d.mjl
END

BEGIN "Get time stamp of EOF record in d.mjf and tp_resolve_time calculated during backward recovery"
set eoftime = `$grep "ddddddddddddddddddddddddddd" d.mjf | $tst_awk -F\\ '{print $2;exit}'`

#If eoftime is empty, check the presence of ^d6 key in previous generation journal file
if ( $eoftime == "" ) then
	mv d.mjf d.mjf_bak
	$MUPIP journal -extract -noverify -detail -for -fences=none d.mjl_* >&! journal_extract_dmjl_prevgen.out
	set eoftime = `$grep "ddddddddddddddddddddddddddd" d.mjf | $tst_awk -F\\ '{print $2;exit}'`
	if ( $eoftime == "" ) then
		echo "The ^d6 key is not present in the previous generation journal file "
		echo "TEST-E-NOTFOUND the key ^d6 is not found in the journal file .. exiting .."
		exit
	endif
endif

set tprtime = `$grep Tp_resolve_time RECOVER.log | $tst_awk -F\; '{print $2;exit}' | $tst_awk -F= '{print $2}'`
END

BEGIN "EOF timestamp in c.mjf and tp_resolve time should match"
$GTM <<GTMEOF
    WRITE "EOF time stamp:  $eoftime"
    WRITE "TP Resolve time: $tprtime"
    set eofdays=\$piece("$eoftime",",",1)
    set eofsec=\$piece("$eoftime",",",2)
    set tprtdays=\$piece("$tprtime",",",1)
    set tprtsec=\$piece("$tprtime",",",2)
    set daydiff=eofdays-tprtdays
    set eofdiff=eofsec-tprtsec
    if ((\$FNUMBER(daydiff,"-")>1)!(\$FNUMBER(eofdiff,"-")>5)) WRITE "Mismatch in timestamp"
    else  WRITE "Timestamp match"
GTMEOF
END

$gtm_tst/com/dbcheck.csh
