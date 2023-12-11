#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# Release note:'
echo '#'
echo '# ZSHOW "B" output consists of an entryref followed by any associated code with a'
echo '# right angle-bracket delimiter after the entryref. Previously the outbut only'
echo '# contained the entryref. (GTM-9388)'
echo '#'
echo '# The only part of this issue not yet tested is if no associated code is provided'
echo '# (either arg ommitted or arg specified as null). The first form is the most'
echo '# common form of ZBREAK (having an implied "B" command as a default), the second'
echo '# form has no legitimate purpose we can ascertain (the command intercept is done'
echo '# but no code runs so its just an expensive NO-OP), we test it in case it has some'
echo '# unforeseen purpose in the future.'
echo
echo '# Drive gtm9388.m'
$gtm_dist/mumps -run gtm9388

