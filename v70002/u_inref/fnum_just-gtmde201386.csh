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

> The \$FNUMBER() and \$JUSTIFY() functions work as expected.
> Previously, results requiring long lengths could result in a
> segmentation violation (SIG-11).

Errors in dbg mode:

> # \$fnumber()
> %GTM-F-KILLBYSIGSINFO1, GT.M process 91438 has been killed by a signal 11 at address 0x00007FB0FEF7E1CA (vaddr 0x000055F76CBA7000)
> %GTM-F-SIGMAPERR, Signal was caused by an address not mapped to an object
>
> # \$justify()
> %GTM-F-KILLBYSIGSINFO1, GT.M process 68240 has been killed by a signal 11 at address 0x00007F1A55494200 (vaddr 0x0000557A92D6172E)
> %GTM-F-SIGMAPERR, Signal was caused by an address not mapped to an object

Errors in pro mode:

> # \$fnumber()
> %GTM-F-KILLBYSIGSINFO1, GT.M process 6956 has been killed by a signal 11 at address 0x00007F928B77D9A4 (vaddr 0x0000564BA8CE3000)
> %GTM-F-SIGMAPERR, Signal was caused by an address not mapped to an object
>
> # \$justify()
> %GTM-F-KILLBYSIGSINFO1, GT.M process 70469 has been killed by a signal 11 at address 0x00007FC00AE59A04 (vaddr 0x000056208FF0C9AE)
> %GTM-F-SIGMAPERR, Signal was caused by an address not mapped to an object

See also:
  https://gitlab.com/YottaDB/DB/YDBTest/-/issues/580
CAT_EOF
echo ""

setenv ydb_msgprefix "GTM"

$gtm_dist/mumps -run fnum^gtmde201386
echo ""
$gtm_dist/mumps -run just^gtmde201386
