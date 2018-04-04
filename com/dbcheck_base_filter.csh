#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
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
# dbcheck.csh : verifies data base integrity
#

#==============================
# Process arguments first
#==============================
if ($1 == "-nosprgde") then
	set okforsprgde = 0
	shift
else
	set okforsprgde = 1
endif

if (!($?acc_meth)) setenv acc_meth "BG"
if (!($?GDE))  then
   if (!($?gtm_exe)) then
      if ($?gtm_dist) then
         setenv gtm_exe $gtm_dist
      else
         echo Please define \$gtm_exe (or \$gtm_dist)
         exit 1
      endif
   endif
   setenv GDE "$gtm_exe/mumps -run GDE"
endif
# $gtm_exe's existence is sure at this point
if (!($?MUPIP)) then
   setenv MUPIP "$gtm_exe/mupip"
endif

if (!($?gtmgbldir)) then
  setenv gtmgbldir "mumps.gld"
endif

if ($?tst_offline_reorg == 1) then
        $MUPIP reorg >>&! offline_reorg.out
        if ($status) then
                echo "TEST FAILED in MUPIP REORG!"
        endif
        $grep "GTM-F" offline_reorg.out
        $grep "GTM-E" offline_reorg.out
endif

if ( $?HOSTOS == "0" )  setenv HOSTOS `uname -s`

# The below script sets online_noonline_specified and online_noonline to be used below
source $gtm_tst/com/set_online_for_dbcheck.csh $argv

# It is an error if the calling script wanted to do an INTEG -FILE but also has passed -[NO]ONLINE along with it
if (("$1" != "-online") && ("$1" != "-noonline") && ("TRUE" == "$online_noonline_specified")) then
	echo "TEST-E-DBCHECK: [NO]ONLINE qualifiers not supported INTEG -FILE"
	exit 1
endif

echo $MUPIP

if (-e tmp.mupip) cp tmp.mupip tmp.mupip_`date +%y_%m_%d_%H_%M_%S`
if (("$1" != "") && ("FALSE" == "$online_noonline_specified")) then
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 $1.dat # do rundown if needed before requiring standalone access
	echo "$MUPIP integ $1.dat"
	$MUPIP integ $1.dat >& tmp.mupip
else
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
	echo "$MUPIP integ -REG *"
	$MUPIP integ -REG $online_noonline "*" >& tmp.mupip
endif
if (("$2" == "-noskipregerr")) then
	mv tmp.mupip tmp.mupip.skipreg
	sed '/MUNOTALLINTEG/d' tmp.mupip.skipreg > tmp.mupip
endif

set stat=1
set error_free = `$tst_awk '/No errors detected by integ./ {count=count+1} END {print count}' tmp.mupip`
set no_regions = `$gtm_tst/com/get_reg_list.csh count`
if ("$error_free" == "$no_regions") then
  #if there are "No errors .." as many as the regions, it must be ok
  echo "No errors detected by integ."
  set stat=0
endif

# Now eliminate the kill in progress or abandoned-kill related (possibly!) errors
if ($stat) then
  $grep -E '^ +[0-9A-F:]+ +[0-9A-F]+ +[a-zA-Z. ]+$' tmp.mupip | $grep -v "Block incorrectly marked busy" | $grep -v "Local bit map incorrect" | $grep -v "Master bit map shows this map full, agreeing with disk local map" > error.mupip
  # furthermore check errors not related to integrity of the blocks (like "Database is flagged corrupt")
  # eliminate DBMRKBUSY DBLOCMBINC DBMBPFLDLBM MUKILLIP (and INTEGERRS)
  # also eliminate DBBTUWRNG if you see MUKILLIP or DBMRKBUSY
  # they are YDB-W- but, eliminate them anyway
  $grep ".-[EF]-" tmp.mupip | $grep -E "MUKILLIP|KILLABANDONED|DBMRKBUSY" >! /dev/null
  if ($status) then
	mv tmp.mupip tmp.mupip_orig
  	$grep -v -E "DBBTUWRNG" tmp.mupip_orig >! tmp.mupip
	# this does not do the same checking VMS does, ideally it should:
	# per region, eliminate any DBBTUWRNG warnings AFTER MUKILLIP|KILLABANDONED|DBMRKBUSY.
	# Any other DBBTUWRNG warnings should be caught.
	# this is not the case now.
	# The best solution would be to use the same filter.awk for both unix and vms, of course.
  endif
  setenv filtererrs "MUKILLIP|KILLABANDONED|DBMRKBUSY|DBLOCMBINC|DBMBPFLDLBM|INTEGERRS"
  if ("$2" == "-noskipregerr") then
  	setenv filtererrs "$filtererrs|MUNOTALLINTEG"
  endif
  $grep ".-[EF]-" tmp.mupip | $grep -v -E "$filtererrs"  >> error.mupip
  if (-z error.mupip) then
      echo "No errors detected by integ."
      set stat=0
   else
      set stat = 1
   endif
endif

if ($stat) then
	# Integ failed. print the entire tmp.mupip
	\cat tmp.mupip
	cp tmp.mupip mupip.err
else
	# Integ did not fail. But check if there are any unreported messages
	# mupip integ reports "No errors detected by integ." even though it sees the following errors. Lets report them
	$grep "Free blocks counter in file header:" tmp.mupip
	set ostat = $status
	if (! $ostat) then
		echo "Though mupip integ reported clean, one or more of the regions printed the above message(s)"
		set mupip_err_file = mupip.err_`date +%y%m%d_%H%M%S`
		cp tmp.mupip $mupip_err_file
		echo "Check the file $mupip_err_file"
	endif
endif

# Generate .sprgde files if appropriate
if ($okforsprgde) then
	$gtm_tst/com/gensprgde.csh
	if ($status) then
		# An error occurred during .sprgde file generation. Exit dbcheck with error status.
		exit -1
	endif
endif

exit $stat
