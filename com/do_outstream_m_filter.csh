#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

rm -rf awk.o outstream.o	# BYPASSOK

if (("" == "$1") || ("" == "$2")) then
	echo "usage:"
	echo "$gtm_tst/com/do_outstream_m_filter.csh inputfile outputfile"
	exit 1
endif

# if %XCMD doesn't exist, we can't do any filtering.  awk will have to take care of everything
if (! -e $gtm_exe/_XCMD.m) then
	cp $1 $2
	exit 0
endif

$gtm_tst/com/do_m_filtering.csh 'do ^outstream()' $1 >&! $2
