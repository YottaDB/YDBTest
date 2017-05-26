#!/usr/local/bin/tcsh -f
#
#############################################################################################
#											    #
# The script is used for two purposes						    	    #
# * To calculate the value of blks2upgrd from dse dump OR				    #
# * To check blks2upgrad value of a given database against either of four scenarios as	    #
#	total - freeblocks	(to give second argument as default)			    #
#	total - freeblocks - 1	(to give second argument as +1)				    #
#	total - freeblocks + 1	(to give second argument as -1)				    #
#	0			(to give second argument as 0)				    #
# The script can be called either with no arguments or with two arguments		    #
# If called with no argument								    #
#	calculates blks2upgrade value from dse dump (as indicated by the name of the script)#
# If called with two arguments								    #
#	checks blks2upgrd value as against the second argument value			    #
#											    #
# output:										    #
# $calculated -- containing tot-free || tot-free+1 || tot-free-1			    #
# $blkstoupgrade_hex -- hex value for blks2upgrd field in dse dump			    #
# $blkstoupgrade_dec -- decimal value for blks2upgrd field in dse dump			    #
#											    #
#############################################################################################
#
if ( 1 == $#argv ) then
	echo 'Pls. specify $2 if you choose to give $1 as "check" or "nocheck"'
	echo "Usage:"
	echo "get_blks_to_upgrade.csh <check/nocheck> <value to compare/value to receive>"
	exit 1
endif
source $gtm_tst/com/get_dse_df.csh "" "newlog"
if ( 0 == $#argv ) then
	setenv blkstoupgrade_hex `$tst_awk ' /Blocks to Upgrade/ {print $8}' dse_df.log | cut -c3-`
	setenv blkstoupgrade_dec `$DSE eval -d -n=$blkstoupgrade_hex|& grep "Dec"|$tst_awk '{print $4}'`
	exit 1
endif
# claculate hex info on free & total blocks here
set freeblks=`$tst_awk ' /Free blocks/ {print $6}' dse_df.log|cut -c3-`
set totblks=`$tst_awk ' /Total blocks/ {print $7}' dse_df.log|cut -c3-`
if ( 0 != $2 ) then
	#calculate decimal value here
	set free_dec=`$DSE eval -h -n=$freeblks|& grep "Dec"|$tst_awk '{print $4}'`
	set tot_dec=`$DSE eval -h -n=$totblks|& grep "Dec"|$tst_awk '{print $4}'`
	if ( "-1" == $2 ) then
		setenv temp `expr $tot_dec - $free_dec - 1`
	else if ( "+1" == $2 ) then
		setenv temp `expr $tot_dec - $free_dec + 1`
	else if ( "default" == $2 ) then
		setenv temp `expr $tot_dec - $free_dec`
	endif
	set count=`$DSE eval -d -n=$temp|& grep "Hex"|$tst_awk '{print $2}'|wc -m`
	set tempval=`$DSE eval -d -n=$temp|& grep "Hex"|$tst_awk '{print $2}'`
	# this loop is to make the string length of the calculated variable match the dse dump output
	while ( $count < 9 )
		set tempval="0"$tempval
		set count=`expr $count + 1`
	end
else
	set tempval="00000000"
endif
setenv calculated $tempval
if ( "check" == $1 ) then
	if( $calculated != `$tst_awk ' /Blocks to Upgrade/ {print $8}' dse_df.log|cut -c3-` ) then
		echo "calculated = "$calculated
		echo "tot_blks = "$totblks
		echo "free_blks = "$freeblks
		echo "upgrade = "`$tst_awk ' /Blocks to Upgrade/ {print $8}' dse_df.log|cut -c3-`
		echo "TEST-E-ERROR. bks_to_upgrade incorrect"
	else
		echo ""
		echo "bks_to_upgrade value check PASS"
		echo ""
	endif
endif
#
