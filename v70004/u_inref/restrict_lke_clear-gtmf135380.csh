#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
Release note (http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-004_Release_Notes.html#GTM-F135380) says:

> The LKECLEAR keyword in the GT.M restrictions file prevents
> the use of the LKE CLEAR command by unauthorized users,
> while the LKE keyword prevents any unauthorized use of the
> LKE utility. Previously the only way to restrict the use of
> LKE was by setting the authorizations on the executable; there
> was no way to allow the use of LKE while blocking the use of
> LKE CLEAR. (GTM-F135380)
CAT_EOF
echo ''

# debug feature for test, leave it empty for production
set only=""

setenv ydb_msgprefix "GTM"

echo '# prepare read-write $gtm_dist directory'
set old_dist=$gtm_dist
source $gtm_tst/com/copy_ydb_dist_dir.csh ydb_temp_dist
setenv gtm_dist $ydb_dist
chmod -R +wX ydb_temp_dist

#### echo "# disable huge pages"
#### source $gtm_tst/com/disable_hugepages.csh

echo "# create database"
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out

# set ^state to 0: it means that LOCK is still inactive
$gtm_dist/mumps -run %XCMD 'set ^state=0'

set maxi=20
echo "# Start background process (LOCK ^global(1)..^global($maxi))"
# - perform some LOCK commands on ^global (number: arg)
# - set ^state to 1: LOCK is activated
# - print string with PID (to be used at cleanup)
($gtm_dist/mumps -run main^gtmf135380 $maxi >>&pid.out &)

# wait for background process to perform PID printing and LOCKs
$gtm_dist/mumps -run %XCMD 'for  quit:^state>0  hang 0.1'

# get PID of background process
set pid=`cat pid.out | cut -d':' -f2`

# get user's principal GID
set gid=`id -gn`

# set existing GID which the actual user is not member of
# (may vary by distro, usually it's "root")
set uid=`id -un`
set exgid=`cat /etc/group | grep -v $uid | head -1 | cut -d":" -f1`

# initialize automatic test ID
@ t = 1
echo ''

if ( "$only" == "$t" || "$only" == "" ) then
	echo "# -------- case $t --------"
	rm -rf $ydb_dist/restrict.txt
	echo "# restrict.txt does not exist"
	echo "# not executing LKE"
	echo "# attempt to lock ^global($t), which is locked"
	$gtm_dist/mumps -run locked^gtmf135380 $t
	echo ""
endif
@ t += 1

# The foreach loop is iterating test "commands". A command contains
# exactly three fields, which are separated with "/" ("f1/f2/f3/f4"):
#   f1:
#     restrict.txt attribute:
#     - "ro": read-only (this is the normal case)
#     - "rw": the user has read-write rights, restrict.txt has no effect
#     - "rm": do not create restrict.txt
#   f2:
#     - restrict.txt contents, lines are separated with ";" (max. 3)
#     - if it's empty, restrict.txt will be not created
#     - $gid is the actual user's group ID
#     - @t is the numero of the test
#   f3:
#     LKE command, e.g. "-SHOW ALL"
#   f4:
#     - arg1 for the M program, can be "cleared" or "locked", which is the
#       desired state of the lock on ^global(numero)
#     - arg2 is always the numero of the test
#
foreach test ( \
	"ro/LKE/CLEAR -NOINTERACTIVE -LOCK=^global(@t)/locked" \
	"ro/LKECLEAR/CLEAR -NOINTERACTIVE -LOCK=^global(@t)/locked" \
	"ro/LKE;LKECLEAR/CLEAR -NOINTERACTIVE -LOCK=^global(@t)/locked" \
	\
	"ro/LKE:$exgid/CLEAR -NOINTERACTIVE -LOCK=^global(@t)/locked" \
	"ro/LKECLEAR:$exgid/CLEAR -NOINTERACTIVE -LOCK=^global(@t)/locked" \
	"ro/LKE:$exgid;LKECLEAR:$exgid/CLEAR -NOINTERACTIVE -LOCK=^global(@t)/locked" \
	\
	"ro/LKE:$gid/CLEAR -NOINTERACTIVE -LOCK=^global(@t)/cleared" \
	"ro/LKECLEAR:$gid/CLEAR -NOINTERACTIVE -LOCK=^global(@t)/cleared" \
	"ro/LKE:$gid;LKECLEAR:$gid/CLEAR -NOINTERACTIVE -LOCK=^global(@t)/cleared" \
	\
	"ro/LKE:$gid;LKECLEAR:$exgid/CLEAR -NOINTERACTIVE -LOCK=^global(@t)/locked" \
	"ro/LKE:$exgid;LKECLEAR:$gid/CLEAR -NOINTERACTIVE -LOCK=^global(@t)/locked" \
	\
	"rm//CLEAR -NOINTERACTIVE -LOCK=^global(@t)/cleared" \
	"ro/HALT/CLEAR -NOINTERACTIVE -LOCK=^global(@t)/cleared" \
	"ro/LKECLEAR:$exgid/EXIT/locked" \
	)

	if ( "$only" == "$t" || "$only" == "" ) then

		echo "# -------- case $t --------"
		set test=`echo $test | sed "s/\@t/$t/"`

		# create restrict.txt
		set f1=`echo $test | cut -d'/' -f1`
		set f2=`echo $test | cut -d'/' -f2`
		# Adding fake first field for cut(1)
		# If the input contains no delimiter:
		# - it returns the whole line for all fields,
		# - with -s option, it skips the line (returns empty)
		set restr1=`echo ';'$f2 | cut -d';' -f2`
		set restr2=`echo ';'$f2 | cut -d';' -f3`
		set restr3=`echo ';'$f2 | cut -d';' -f4`
		rm -rf $ydb_dist/restrict.txt
		if ( "$f1" != "rm" ) then
			if ( "$restr1" != "" ) then
				echo $restr1 >> $ydb_dist/restrict.txt
			endif
			if ( "$restr2" != "" ) then
				echo $restr2 >> $ydb_dist/restrict.txt
			endif
			if ( "$restr3" != "" ) then
				echo $restr3 >> $ydb_dist/restrict.txt
			endif
		endif
		if ( -f "$ydb_dist/restrict.txt" ) then
			if ( "$f1" == "ro") then
				chmod a-w $ydb_dist/restrict.txt
				echo "# restrict.txt (read-only):"
			else
				chmod +w $ydb_dist/restrict.txt
				echo "# restrict.txt (read-write):"
			endif
			cat $ydb_dist/restrict.txt \
				| sed "s/$gid/##GID##  # substituted/g" \
				| sed "s/$exgid/##EXGID##  # substituted/g"
		else
			echo "# restrict.txt does not exist"
		endif

		# execute LKE command
		set f3=`echo $test | cut -d'/' -f3`
		echo "# execute LKE command: $f3"
		strace -s 999 -o strace_$t.outx $ydb_dist/lke $f3 >& lke_cmd_$t.outx
		cat lke_cmd_$t.outx | $gtm_dist/mumps -run filtlke^gtmf135380 "$f2"

		# check for syslog errors
		#
		# Notices:
		#   Instead of actual syslog, strace output is examined. As far as we
		#   know, this is the only way to separate LKE syslog entries created
		#   in different sessions (when the test runs parallel):
		#   - Actual session's LKE should be identified by PID. This does not
		#     work, because LKE forks a logger thread, and it has different
		#     PID. This PID is only +1 greater than original LKE PID, but
		#     we can't rely on it, because other session might issue a fork()
		#     at the same time, so the system will give the +1 PID for this
		#     process.
		#   - On the same host, some lock mechanism should be used:
		#     lock -> execute LKE -> unlock. On Unix systems, locks can be
		#     implemented with files (`mv`, aka. `rename()` is atomic), but
		#     lock initialization is difficult, e.g. when there's no file yet
		#     to mv.
		#
		echo "# checking strace output for errors in syslog messages"
		cat strace_$t.outx \
			| $gtm_dist/mumps -run procst^gtmf135380

		# execute M program with arg
		set lbl=`echo $test | cut -d'/' -f4`
		echo "# attempt to lock ^global($t), which is $lbl"
		$gtm_dist/mumps -run $lbl^gtmf135380 $t
		echo ''

	endif  # if $only == $t

	@ t += 1
end  # while test cases

# Develop-time check
if ( "$t" > "$maxi" ) then
	echo "TEST-E-INTERNAL: not enough locks, bump value of constant maxi above $t"
endif

echo "# ---- cleanup ----"

echo "# send stop request to background process"
$gtm_dist/mumps -run %XCMD 'set ^state=2 hang 1'

echo "# wait background process to finish"
($gtm_tst/com/wait_for_proc_to_die.csh $pid >>&waitforproc.log)

echo "# attempt to lock ^global($t), got released when bacground process has terminated"
$gtm_dist/mumps -run cleared^gtmf135380 $t

echo "# shutdown database"
setenv gtm_dist $old_dist
setenv ydb_dist $old_dist
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
