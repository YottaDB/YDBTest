;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
;
; Direct mode cases for the r208/tstart_dm_args-ydb1326 subtest, run by r208/u_inref/ydbfuzzdm.csh
;
ydb1326dm
	quit

tpindjob
	;inp:"tstart @""job"" do x"
	;inp:"trollback"
	;inp:"write ""$tlevel="",$tlevel,!"
	;has:$tlevel=0
tpindrest
	;inp:"set v=""job"",job=1"
	;inp:"tstart (job) set job=2 trestart:$trestart<1"
	;inp:"write ""TSTART (job), after TRESTART: $trestart="",$trestart,"" job="",job,!"
	;inp:"tcommit"
	;inp:"set job=1"
	;inp:"tstart @v set job=2 trestart:$trestart<1"
	;inp:"write ""TSTART @v, after TRESTART: $trestart="",$trestart,"" job="",job,!"
	;inp:"tcommit"
	;has:TSTART (job), after TRESTART: $trestart=1 job=1
	;has:TSTART @v, after TRESTART: $trestart=1 job=1
tptid
	;inp:"set t=""AB"""
	;inp:"tstart ():transactionid=t_""CD"" write ""transaction id="",$view(""TRANSACTIONID"",1),!"
	;inp:"trollback"
	;has:transaction id=ABCD
