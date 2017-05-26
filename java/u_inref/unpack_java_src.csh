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

# Unpack the Java files from the x.x.x.Test#.java format into respective directories, and strip off
# the part of the name preceding Test#.java.
foreach jsrc ( $gtm_tst/$tst/inref/*.java )
	set dst = `basename $jsrc`
	set dst = ${dst:r}
	set dst = `pwd`/${dst:as;.;/;}.java
	if ( ! ( -d $dst:h ) ) mkdir -p $dst:h
	cp $jsrc $dst
end
