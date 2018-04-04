#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright 2013, 2014 Fidelity Information Services, Inc	#
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
#;;;sdseek.csh
#;;;Test the unix seek behavior of the sequential device with both M and unicode tests
#;;;This work was done under the GTM-7809
#;;;
$switch_chset M

# Create one-region gld and associated .dat file
$gtm_tst/com/dbcreate.csh mumps 1

$gt_cc_compiler -o echoback -I$gtm_tst/$tst/inref -I$gtm_dist $gtm_tst/$tst/inref/echoback.c
rm -f echoback.o

$echoline
echo "**************************** gtm7964 ****************************"
$echoline
$gtm_dist/mumps -run gtm7964
$echoline

# the following command enters mumps with $PATH undefined and then tries to open a pipe with the parse parameter
# prior to gtm-7964 this caused a signal 11.  After this JI it issues the following:
# %YDB-E-DEVOPENFAIL, Error opening PP
# %YDB-I-TEXT, $PATH undefined, Invalid command string: cat
# The new information in the text message is that $PATH is undefined so parse_pipe() can't find cat
# If the parse device parameter is omitted the underlying exec of a shell to execute the command
# string will initialize PATH resulting in cat being found.
echo 'For each shell unsetenv PATH and use %XCMD to open a pipe with command=cat and read/write to it.'
echo 'Expect it to fail with the parse device parameter.'
# save the path to the shells
set ksh_path=`which ksh`
    set shells="/usr/local/bin/tcsh /bin/sh /bin/csh $ksh_path"
# save the shell paths for reference in case of some error
echo $shells > shells
foreach SH ($shells)
	set SHELL=$SH:t
	echo "Shell = $SHELL"
	echo "With parse device parameter:"
	# create P1 so XCMD line is not so long
	setenv P1 "$SH"'":comm="cat":parse)::"pipe" use "PP" write "PASS",! read x use '
	(unsetenv PATH ; $gtm_exe/mumps -run %XCMD 'open "PP":(shell="'$P1'$p write x,!')
	echo "Without parse device parameter:"
	# create P2 so XCMD line is not so long
	setenv P2 "$SH"'":comm="cat")::"pipe" use "PP" write "PASS",! read x use '
	(unsetenv PATH ; $gtm_exe/mumps -run %XCMD 'open "PP":(shell="'$P2'$p write x,!')

end
$gtm_tst/com/dbcheck.csh
