#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# A global reference following a KEY2BIG error should not cause assert failure or core"

$gtm_tst/com/dbcreate.csh mumps 1 -key=15

cat << cat_eof >> key2big.m
key2big ;
        set \$etrap="do etr"
        set ^stop=0
        set ^abcdefghijklmnopqrstuvwxyz(1)=2
        quit
etr     ;
        set \$ecode=""
        set ^stop(1)=543
        zwr ^stop
        halt
cat_eof

$gtm_exe/mumps -run key2big

$gtm_tst/com/dbcheck.csh
