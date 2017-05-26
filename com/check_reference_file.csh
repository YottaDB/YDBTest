#!/usr/local/bin/tcsh -f
# use this script to diff an arbitary output file against a reference file
# usage:
# $gtm_tst/com/check_reference_file.csh ref_file output_file
#
# the exit status will show whether there was a diff or not.
# and the diff will be written into a file in the same directory, in a
# file name as the output file (second argument), but with a .diff extension

if (("" == "$1") || ("" == "$2")) then
	echo "usage:"
	echo "$gtm_tst/com/check_reference_file.csh ref_file output_file"
	exit 1
endif
set reffile = ${1:t:r}.outref	#because outref.awk expects "outref" in the reference file name
set cmpfile = ${1:t:r}.cmp
set diffile = ${2:t:r}.diff
set logfile = ${2:t:r}.log_filter
set logfile_m = ${2:t:r}.log_filter_m
if (-e priorver.txt) then
	set priorver = `cat priorver.txt`
else
	set priorver = "IMPOSSIBLEVERNAME"
endif
cp $1 $reffile
$gtm_tst/com/do_outstream_m_filter.csh $2 $logfile_m
$tst_awk -f $gtm_tst/com/outstream.awk -v priorver=$priorver $logfile_m >&! $logfile 
$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk $logfile $reffile >&!  $cmpfile
\diff  $cmpfile $logfile >&! $diffile
exit $status
