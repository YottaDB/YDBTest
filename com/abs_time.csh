#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2003, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# The script takes an argument where it redirects the output of date command
date +'%d-%b-%Y %H:%M:%S' > ${1}_abs
date +'%Y.%m.%d.%H.%M.%S.%Z' > $1
echo Time written into ${1}: `cat ${1}` `cat ${1}_abs`
