#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTMDE-201386 - Test the following release note
*****************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637465)

> The VIEW command for "NOISOLATION" handles various edge
> cases and reports a VIEWARGTOOLONG error when a list of
> global names exceeds 1024 bytes. Previously, some
> malformed global names could cause a segmentation
> violation (SIG-11) and using a string over 1024 bytes
> would cause a GTM assertion failure.

Actually, the errors are not SIGSEGV (SIG11), details below.

Errors in pro mode:

> # Perform a VIEW/NOISOLATION command with malformed global name
> global name: glb12345678901234567890123456789012
> *** buffer overflow detected ***: terminated
> %GTM-F-KILLBYSIGSINFO1, GT.M process 64533 has been killed by a signal 6 at address 0x00007F0E3B699A1B (vaddr 0x000004270000FC15)
> #
> # Perform a VIEW/NOISOLATION command with arg too long
> arg length: 1025
> %GTM-F-GTMASSERT2, GT.M V7.0-001 Linux x86_64 - Assert failed /Distrib/YottaDB/V70001/sr_port/view_arg_convert.c line 277 for expression (SIZEOF(global_names) > parm->str.len)

Errors in dbg mode:

> # Perform a VIEW/NOISOLATION command with malformed global name
> global name: glb12345678901234567890123456789012
> %GTM-F-ASSERT, Assert failed in /Distrib/YottaDB/V70001/sr_port/gtm_memcpy_validate_and_execute.c line 36 for expression (((char *)(target) > (char *)(src)) ? ((char *)(target) >= ((char *)(src) + (len))) : ((char *)(src) >= ((char *)(target) + (len))))
> #
> # Perform a VIEW/NOISOLATION command with arg too long
> arg length: 1025
> %GTM-F-GTMASSERT2, GT.M V7.0-001 Linux x86_64 - Assert failed /Distrib/YottaDB/V70001/sr_port/view_arg_convert.c line 277 for expression (SIZEOF(global_names) > parm->str.len)

Notice that GT.M and YottaDB handle too long argument differently:
- GT.M throws VIEWARGTOOLONG error if it's longer than 1024 characters,
- YottaDB produces no error.
The test ignores VIEWARGTOOLONG error, so it will pass with GT.M as well.

See also:
  https://gitlab.com/YottaDB/DB/YDBTest/-/issues/580
CAT_EOF
echo ""

setenv ydb_msgprefix "GTM"

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log
$gtm_dist/mumps -run vatl1^gtmde201386
echo ""
$gtm_dist/mumps -run vatl2^gtmde201386
$gtm_tst/com/dbcheck.csh >& dbcheck.log
