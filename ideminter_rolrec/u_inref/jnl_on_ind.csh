#!/usr/local/bin/tcsh -f
#################################################
# jnl_on_ind.csh [1]
# To turn journaling on with different settings for each region.
#$1 is whether we should have some regions with 5 min. epoch or not

if (! $?jnldir) set jnldir = "."

# if  the first argument is 1, have two regions with 5 min epoch:
set test_fivemin_epoch = ""
if ( "1" == $1) set test_fivemin_epoch = "270 270" # 30 is added below.

set GDE = "$gtm_exe/mumps -run GDE"
echo GDE is $GDE
$GDE << GDE_EOF>&! gde.out
show -map
quit
GDE_EOF

#Below are the allowed values for various settings, we will pick up randomly accross the range (though not necessarily a uniform random for some)
#(all in 512-byte blocks)
#		Default 	Min		Max	   Will use
#Autoswitch :	8386560		16384		8388607	-> [2**14,2**23)
#Allocation :	2048		200		8388607	-> less than or equal to Autoswitch
#Extension  :	2048		0		65535	-> 0 or randomly chosen in the range [1,65535]
#AlignSize  :	2048		4096		4194304	-> [2**12, 2**22] r1+r2
#Epoch	    :    					-> [30,150] # two regions will have 300 for interrupted_recover
#
# where there is a note r1+r2, it means it is a non-uniform random, i.e. 2**r1+r2 (where r1 is a random and r2 is a random ([0,r1))


echo "####################################################################"
date
echo "REG XXX:    	ASWITCH	ALLOC	EPOCH	ALIGN" >>! jnl_settings.txt

# keep random number lists:
#so the values for one option (say, alignsize) are random from the same seed.
set rand1list = (`$gtm_exe/mumps -run rand 9 8`)			# autoswitchlimit
set epochlist = ($test_fivemin_epoch `$gtm_exe/mumps -run rand 121 8`)	# epoch
set rand3list = (`$gtm_exe/mumps -run rand 11 8`)			# alignsize
set count = 1
# ':' is a sign of GT.CM region (lester:/testarea4/...)
foreach x (`$grep "FILE" gde.out | $tst_awk '{print $NF}' | grep -v ":" | $tst_awk -F. '{print $1}' | sort -u`)
	echo "--------------------"
	echo File $x.dat "---> "journal file $jnldir/${x}.mjl
	@ rand1 = $rand1list[$count] + 14 # [14,22]
	@ aswitch1 = `$gtm_exe/mumps -run exp $rand1`	# 2**$rand1
	@ rand2 = `$gtm_exe/mumps -run rand $aswitch1`	# [0,2**$rand1-1]
	@ aswitch = $aswitch1 + $rand2			# [2**14,2**23)
	@ alloc = `$gtm_exe/mumps -run rand $aswitch`
	if ($alloc <= 20000) then
		@ alloc = $aswitch		# Special case testing
		@ exten = 0
	else
		@ exten = $aswitch - $alloc
		@ exten = `$gtm_exe/mumps -run rand $exten`	
		@ exten = $exten + 1				
		if ($exten > 65535)  @ exten = 65535
	endif
	@ epoch = $epochlist[$count] + 30 	# [30,150]
	@ rand3 = $rand3list[$count] + 12 	# [12, 22]
	@ align = `$gtm_exe/mumps -run exp $rand3`	# [2**12, 2**22]
	echo "REG ${x}: aswitch=$aswitch alloc=$alloc exten=$exten epoch=$epoch align=$align" >>jnl_settings.txt
	setenv tst_jnl_str_full "$tst_jnl_str,autoswitchlimit=$aswitch,alloc=$alloc,extension=$exten,align=$align,epoch=$epoch"
	echo "JOURNAL OPTIONS: $tst_jnl_str_full"
	echo "$MUPIP set -file ${x}.dat ${tst_jnl_str_full},file=$jnldir/${x}.mjl"
	$MUPIP set -file ${x}.dat ${tst_jnl_str_full},file=$jnldir/${x}.mjl
	@ count = $count + 1
end
