#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo '# $ZY should not be considered a valid abbreviation'
echo '# This test also checks that no invalid $ZY abbreviations are accepted, but $Z abbreviations are accepted.'
$GTM << 'EOF'
 write "**Testing ISVs**",!!
 write "$ZY shouldn't work."
 write $ZY,!
 write "$ZYRE and $ZYRELEASE should work: ",!
 write $ZYRE,!
 write $ZYRELEASE,!
 write "$ZYR, $ZYREL, $ZYRELE, $ZYRELEAS should give INVSVN errors: ",!
 write $ZYR,!
 write $ZYREL,!
 write $ZYRELE,!
 write $ZYRELEAS,!
 write "$ZYER, $ZYERR and $ZYERROR should work: ",!
 write $ZYER,!
 write $ZYERR,!
 write $ZYERROR,!
 write "$Z should work: ",!
 write $Z,!
 ;
 write !,"**Testing $Z functions**",!!
 write "$ZYH() shouldn't work but $ZYHASH() does",!
 write $ZYH("YottaDB Rocks!"),!
 write $ZYHASH("YottaDB Rocks!"),!
 write "$ZYIS shouldn't work by $ZYISSQLNULL() does",!
 write $ZYIS("YottaDB Rocks!"),!
 write $ZYISSQLNULL("YottaDB Rocks!"),!
 write "$ZYSU and $ZYSUFFIX should both work",!
 write $ZYSU("foo"),!
 write $ZYSUFFIX("foo"),!
 write "$Z() should work",!
 set x=0 write $Z(x)
'EOF'
