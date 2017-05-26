#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# make directory length as >240 char based on the user's current directory string length.
#
# C9J05-009999 - [SE] test that dbg mode $ZSEARCH does not explode with non-existant directory.
#

# Debug (and UNIX) only issue so gets bogus TR #
$gtm_dist/mumps -run ^C9J05009999A

if ( "os390" == $OSTYPE ) then
	# z/OS has a max path of 255 characters
	@ dirln=211 - `echo $tst_working_dir|wc -c`
else
	@ dirln=212 - `echo $tst_working_dir|wc -c`
endif
@ i=1
set long_dir=$tst_working_dir/long_dir
while($i < $dirln)
set long_dir=$long_dir"r"
@ i = $i + 1
end
set longer_dir=$long_dir/longer_named_subdirectory
set outfile = $tst_working_dir/fail.txt

$gtm_tst/$tst/u_inref/check_dir.csh  $tst_working_dir $outfile

mkdir $long_dir
cd $long_dir
echo $long_dir
echo $long_dir |wc|$tst_awk '{print "No of letters in path: "$3}'
$gtm_tst/$tst/u_inref/check_dir.csh $long_dir $outfile

mkdir $longer_dir
cd $longer_dir
echo $longer_dir
echo $longer_dir |wc|$tst_awk '{print "No of letters in path: "$3}'
$gtm_tst/$tst/u_inref/check_dir.csh $longer_dir  $outfile
