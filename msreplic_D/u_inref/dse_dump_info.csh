#!/usr/local/bin/tcsh -f
# checks the Zqgblmod seqno value reported by dse dump -file
# note this script acts on one region only (since the calling script has one region only)

#Usage:
#dse_dump_info.csh <expected_value>
# where expected_value is the value expected from the Zqgblmod seqno field of the dse dump -fil.

if ($# != 1) then
	echo "TEST-E-WRONGARGCOUNT"
	exit
endif
if ($?replic_timestamp) then
	set timestamp = $replic_timestamp
else
	set timestamp = `date +%y%m%d_%H%M%S`
endif
$DSE dump -fileheader -all >&! dse_dump_${timestamp}.out
hostname >>&! dse_dump_${timestamp}.out
pwd >>&! dse_dump_${timestamp}.out
set zqgblmod_seqno_line = `$grep Zqgblmod dse_dump_${timestamp}.out`
echo $zqgblmod_seqno_line | $tst_awk '{print $1 " " $2 " " $3}'
set zseqnohex = `echo $zqgblmod_seqno_line| $tst_awk '{print $3}' | sed 's/0x0[0]*\([^$]\)/\1/g'`
                #using sed, we remove all leading zeros (and still end up with a 0 if it was all 0's)
set zseqnodec = `$gtm_tst/com/radixconvert.csh h2d $zseqnohex | $tst_awk '{print $5}'`

if ($1 == $zseqnodec) then
	echo 'The Zqgblmod seqno value is as expected,'" ($1 vs $zseqnodec)"
	exit 0
else
	echo "DSEDUMPINFO-E-UNEXPECTEDVAL Unexpected value. Expected: $1 vs Actual: $zseqnodec (0x$zseqnohex)"
	echo "See the full dse dump -fil output at dse_dump_${timestamp}.out"
	exit 1
endif
