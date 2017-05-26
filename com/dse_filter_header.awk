#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
BEGIN {
	mask = 0;
	mask2 = 0;
}

{
if (NR == 2) { next ;}
if ($0 ~ /^File /) { next ;}
if(mask2 == "line1")
{
	gsub(/^           \|  .  .  . .. /,"           |  .  .  . .. ") ;
	mask2 = 0;
}
if ($0 ~ /^Rec:../)
{
	mask = 1;
#	if ( $0 ~ /Rec:9E  Blk 1F  Off CE  Size E  Cmpc B  Ptr 6  Key .samplegbl/) { mask2 = "head" ;}
#	if ( $0 ~ /Rec:.*E  Blk 1F  Off CE  Size E  Cmpc B  Ptr 6  Key .samplegbl/) { mask2 = "head" ;}
	mask2 = "head"
	print;
	next;
}
if(mask == 1)
{
	gsub("^     ... : . .. .. .. .. ","     ... : | .. .. .. .. ");
	mask = 0;
	if (mask2 == "head") { mask2 = "line1" ;}
}
if($0 ~ "^Block" )
{
	gsub("TN .(.*) V.$","TN ## V#");
}
print;
}
