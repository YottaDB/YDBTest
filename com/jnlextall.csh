#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# $1 - pattern e.g. "mumps" means extract all files of the form "mumps.mjl*"
# $2 - additional parameters to mupip journal -extract : e.g. "-full"
#

@ exit_status = 0
set filecnt = ( $1*.mjl* )
echo "Extracting $#filecnt files of type $1*.mjl*"
foreach file ($1*.mjl_* $1*.mjl $1*.mjl.gz)
	if ( ${file:e} == "gz" ) then
		echo "Unzipping $file"
		gunzip $file
		set file = ${file:r}
	endif
	set destfile = ${file:s/mjl/mjf/}
	echo "	Extracting :  $file ----> $destfile"
	set mjfname = $file:r
	$MUPIP journal -extract -noverify -detail -for -fences=none $2 $file
	if ($status != 0) then
		echo "Error while extracting journal file $file (status = $status)"
		@ exit_status++;
	else if (${mjfname}.mjf != $destfile) then
		mv ${mjfname}.mjf $destfile
	endif
end
exit $exit_status
