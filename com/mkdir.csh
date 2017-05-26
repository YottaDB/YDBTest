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

set dirstat=1 ; set attempts=5
set curdir = $PWD
set destdir = "$1"
while ($dirstat && $attempts)
	cd $curdir
	if (-d $destdir) rm -rf $destdir
	\mkdir $destdir
	cd $destdir
	pwd >& /dev/null
	set dirstat = $status
	@ attempts--
end
cd $curdir

if !($attempts) then
	exit 1
endif
