#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2010, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set zstatus=0

# Extract the journal files
foreach db (*.mjl)
	$MUPIP journal -extract -noverify -detail -for -fences=none ${db} >>& detailedextracts.log
	if ( $status ) set zstatus=1
end
if ($zstatus) then
	echo "extract failure, please see detailedextracts.log"
	$tail detailedextracts.log
endif

foreach mjf (*.mjf)
	echo $mjf
	$tst_awk -F "\\" '$0 !~ /(\^fired|"#LABEL"|"#TRHASH"|"[LB]HASH"|"CHSET")/ {sub(/^(0x.* :: |[ ]+)/,"",$1);if($1 ~/(SET|KILL|ZTRIG)/){print $1"/"$(NF-1)"/"$NF};if($1 ~ /LGTRIG/){print $1"/"$NF;};if($1 ~ /ZTWORM/){print $1"/"$NF;};}' $mjf
	# AWK script broken out
	# 0 !~ /(\^fired|"#LABEL"|"#TRHASH"|"[LB]HASH"|"CHSET")/	# skip ^fired & run dependent ^#t subs
	# sub( /^(0x.* :: |[ ]+)/, "", $1); 				# strip off leading detailed info
	# if( $1 ~/(SET|KILL|ZTRIG)/ )	{ print $1"/"$(NF-1)"/"$NF; }	# print SET and KILL with nodeflags
	# if( $1 ~ /ZTWORM/ )		{ print $1"/"$NF; }		# ZTWO
	# if( $1 ~ /LGTRIG/ )		{ print $1"/"$NF; }		# LGTR
	echo "-------------------------------------------------------------"
end


