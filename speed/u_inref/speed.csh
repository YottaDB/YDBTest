#!/usr/local/bin/tcsh -f
# Notes:
# 	1) spdata is called for some intialization for the test preparation.
# 	2) For Local variable you cannot exit after any operation, because all memory will be 
# 		lost after a GT.M halt. So all operations are done without a rundown. 
# 	3) For Global variable speed always rundown is done (by halt). 
# 		This gaurantees that shared memory of a previous operation does not help next operation
#	4) The speed of different operations in different machines varies a lot. 
#		So primsize.m is created based on host name.
#
# $1 = Local or Global or Global+reorg or TP or locks
# $2 = Sequential collating order of Keys or Random order
# $3 = Journal or No journal
# $4 = number of regions
# $5 = number of processes
# $6 = Number of kinds of operations to test (SET is one type, READ is another, $GET is another etc.)
# $7 = Number of repeatation of inner most test loop
#                                                          
set typestr = $1
set jnlstr = $3
set regcnt = $4
set totop = $6
setenv gtm_test_parms "$1 $2 $3 $4 $5 $6 $7"
if ("$typestr" == "LOCKI" || "$typestr" == "ZDSRTST1" || "$typestr" == "ZDSRTST2") then
	setenv prim_root 0
else
	setenv prim_root 1
endif
#
set totrun = $test_speed_runs
@ run = 1	
while ($run <= $totrun)
	setenv cur_run $run
	################################
	# Create Database (and journals)
	################################
	if ("$HOSTOS" == "OSF1") then
		# We recommend pagesize == block size
		$gtm_tst/com/dbcreate.csh mumps $regcnt 150 500 8192 2000 2048 16000
	else
		$gtm_tst/com/dbcreate.csh mumps $regcnt 150 500 4096 2000 2048 16000
	endif
	# Create Journal for JNL tests, replic option would have already created them
	if (!($?test_replic) && ("$jnlstr"  == "JNL")) then
		$gtm_tst/com/jnl_on.csh $test_jnldir
	endif
	if (-f speed.glo) then
		$MUPIP load speed.glo
	endif
	#
	$GTM << xyz
	write "do init^spdata",!  do init^spdata
	h
xyz
	if ($prim_root == 1) then
		# Already init^spdata created size.txt"
		echo "$cur_dir/prime_root `cat size.txt` > primsize.m"
		$cur_dir/prime_root `cat size.txt` > primsize.m
		$GTM << xyz
		write "do ^primsize",! do ^primsize
		write "do initcust^spdata",! do initcust^spdata
		h
xyz
	endif
	############################
	# Driver speed program
	############################
	sync
	$GTM << xyz
	do ^main
	h
xyz
	############################
	if ("$typestr" == "GBLS" || "$typestr" == "GBLREORG" || "$typestr" == "GBLM") then
		# GBL operations
		sync
		if "$typestr" == "GBLREORG" then
			$MUPIP reorg	# DO MUPIP REORG if needed
		endif
		# DO READ and other operations
		@ opno = 2	
		sync
		while ($opno <= $totop)
			$GTM << xyz
			do ^main
			h
xyz
			@ opno = $opno + 1
		end
	endif

	######################################
	# Now calculate results for speed test
	######################################
	$GTM << xyz
	do ^printtim
	h
xyz
	if (-f "*.mje*") cat *.mje* 
	$gtm_tst/com/dbcheck.csh -extract
	\rm -f speed.glo
	$MUPIP extract -select=""^speed"" speed.glo
	@ run = $run + 1
	#
end	# End While
