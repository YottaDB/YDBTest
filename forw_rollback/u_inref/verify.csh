#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of default verify behavior for various MUPIP JOURNAL commands; Test of REPLSTATEOFF/MUPJNLINTERRUPT messages
#
setenv gtm_test_spanreg 0			# JNLDBSEQNOMATCH error checking section of the test assumes ^a* maps to AREG and ^b* maps to BREG
source $gtm_tst/com/gtm_test_setbeforeimage.csh	# needed since this test does backward rollback
echo "Generate few updates in a replicated environment"
$gtm_tst/com/dbcreate.csh mumps
# Take backup of db for forward rollback
mkdir bak_forw; $MUPIP backup -nonewjnlfiles -online "*" bak_forw >& backup.out
$GTM << GTM_EOF
	for i=1:1:100 set ^x(i)=\$j(i,20)
	view "FLUSH"
GTM_EOF
# Take backup of db (for backward rollback) and mjl (for backward and forward rollback and recover)
$gtm_tst/com/backup_dbjnl.csh bak_back '*.gld *.dat *.mjl*' cp nozip
$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/backup_dbjnl.csh bak_final '*.gld *.dat *.mjl*' cp nozip

# Test that -NOVERIFY is default for MUPIP JOURNAL -ROLLBACK -FORWARD
# Test that -NOVERIFY is default for MUPIP JOURNAL -RECOVER -FORWARD
# Test that -VERIFY is default for MUPIP JOURNAL -RECOVER -FORWARD -NOCHECKTN
# Test that -VERIFY is default for MUPIP JOURNAL -RECOVER -BACKWARD
# Test that -VERIFY is default for MUPIP JOURNAL -ROLLBACK -BACKWARD
# Test that -VERIFY is default for MUPIP JOURNAL -EXTRACT
# Test that -VERIFY is default for MUPIP JOURNAL -SHOW
foreach direction ("forward" "backward")
	foreach action ("rollback" "recover" "extract" "show")
		foreach qual ("" "-verify" "-noverify" "-nochecktn")
			if (("$qual" == "-nochecktn") && (("$direction" != "forward") || ("$action" != "recover"))) then
				continue
			endif
			echo " --> Testing VERIFY status for mupip journal -$action -$direction $qual" | sed 's/ $//g'
			if (("$action" == "rollback") || ("$action" == "recover")) then
				if ("$direction" == "forward") then
					cp bak_forw/mumps.dat .
				else
					cp bak_back/mumps.dat .
				endif
				cp bak_back/mumps.mjl .
			else
				cp bak_final/mumps.dat .
				cp bak_final/mumps.mjl .
			endif
			set logfile = ${direction}_${action}$qual.out
			$MUPIP journal -$action -$direction $qual "*" >& $logfile
			@ exit_status = $status
			if ($exit_status) then
				echo "TEST-E-FAIL : MUPIP journal -$action -$direction $qual failed. See $logfile"
			endif
			$grep "Verify successful" $logfile
			if (("$action" == "recover") && ("$direction" == "backward")) then
				echo "# Previous action would have errored out with MUUSERLBK due to crashed mjl."
				$gtm_tst/com/check_error_exist.csh $logfile "MUUSERLBK" "MUNOACTION"
				echo "# Retry with non-crashed mjl"
				echo " --> Retrying VERIFY status for mupip journal -$action -$direction $qual" | sed 's/ $//g'
				cp bak_back/mumps.dat .
				cp bak_final/mumps.mjl .
				set logfile = ${direction}_${action}${qual}_2.out
				$MUPIP journal -$action -$direction $qual "*" >& $logfile
				@ exit_status = $status
				if ($exit_status) then
					echo "TEST-E-FAIL : Retry of MUPIP journal -$action -$direction $qual failed. See $logfile"
				endif
				$grep "Verify successful" $logfile
			endif
		end
	end
end
#
echo "# Test of REPLSTATEOFF error"
cp bak_forw/mumps.dat .
cp bak_back/mumps.mjl .
$MUPIP journal -rollback -backward "*"	# BYPASSOK("-rollback")

echo "# Test of MUPJNLINTERRUPT error from forward rollback"
cp bak_forw/mumps.dat .
$DSE change -file -location=3cc -value=1	# 0x3cc is offset of "csd->recov_interrupted"
$MUPIP journal -rollback -forward "*"	# BYPASSOK("-rollback")

echo "# Test of JNLDBSEQNOMATCH error"
setenv gtm_test_jnlfileonly 0	# Since the test cuts journal files with noprevlink
unsetenv gtm_test_jnlpool_sync	# ditto
$gtm_tst/com/dbcreate.csh mumps 3
# Do some updates
$gtm_exe/mumps -run %XCMD 'for i=1:1:10 s (^a(i),^b(i),^c(i))=1'
set bkupdir1 = backupdir1 ; mkdir $bkupdir1
$MUPIP backup "*" -online -newjnlfiles=noprevlink $bkupdir1 >&! mupip_backup1.out
# Do some updates - no updates to ^a
$gtm_exe/mumps -run %XCMD 'for i=11:1:20 s (^b(i),^c(i))=1'

echo "# Switch journal files and cut previous journalfile link"
$MUPIP set $tst_jnl_str -reg "*" >&! mupip_setjnl1.out
# Doing the -noprevjnlfile command twice to verify the fix to print NULL when prevlink is already NULL
foreach jnlfile (a.mjl b.mjl mumps.mjl)
	$MUPIP set -jnlfile $jnlfile -noprevjnlfile -bypass >>&! jnlfile_noprevlink.out
	$MUPIP set -jnlfile $jnlfile -noprevjnlfile -bypass
end
# Do more updates - no updates to ^a
$gtm_exe/mumps -run %XCMD 'for i=21:1:30 s (^b(i),^c(i))=1'

echo "# Shut down replication servers, but have journaling on"
$gtm_tst/com/RF_SHUT.csh "on"
$gtm_tst/com/dbcheck.csh -extract -noshut

echo '# Copy *.dat from $bkupdir1'
$gtm_tst/com/backup_dbjnl.csh 'save1' '*.dat' 'mv'
cp $bkupdir1/*.dat .

echo "# Expect JNLDBTNNOMATCH error first when rollback -forward is attempted with -nochain"
$MUPIP journal -rollback -forward -nochain b.mjl	# BYPASSOK("-rollback")
echo "# Fix TN to match so we can exercise the JNLDBSEQNOMATCH error"
set curr_tn = `$MUPIP journal -show=header -forward -noverify b.mjl | & grep "Begin Transaction" | sed 's/.*\[0x//g;s/]//g;s/^0*//g'`
$DSE << DSE_EOF
find -reg=BREG
change -file -current_tn=$curr_tn
DSE_EOF

echo ""	# $DSE above leaves the cursor at the end of a line instead of the beginning of a fresh line
$MUPIP journal -rollback -forward -nochain b.mjl	# BYPASSOK("-rollback")
echo "# Expect JNLDBSEQNOMATCH error for the below rollback -forward, since journal backlinks are cut"
$MUPIP journal -rollback -forward b.mjl			# BYPASSOK("-rollback")
