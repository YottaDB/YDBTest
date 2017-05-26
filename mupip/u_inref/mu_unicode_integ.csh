#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
$switch_chset UTF-8

# switch_chset is done before calling the subtests containing unicode characters
# If this is not done, the subtests fail to understand the unicode characters properly in HP-UX and solaris

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

$gtm_tst/$tst/u_inref/mu_unicode_integ_base.csh
