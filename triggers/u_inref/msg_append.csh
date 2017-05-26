#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2010, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1

cat > msgappend.m << EOF
msgappend  ;
        write "In parent: Invoke child^msgappend",!
        do child^msgappend
        write "Back to parent from child^msgappend",!
        set s=\$ztrigger("file","b.trg")
        quit
child   ;
        write "In child",!
        set \$etrap="do error^msgappend"
        set s=\$ztrigger("file",\$c(0))
        quit
error   ;
        write "In error",!
        set \$ecode=""
        quit
EOF

$gtm_exe/mumps -run msgappend

$gtm_tst/com/dbcheck.csh -extract
