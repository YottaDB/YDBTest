;#################################################################
;#								#
;# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
setx ; Code to set data for future journal extraction
 new i
 tstart ():transactionid="batch"
 if $ztrigger("item","+^x(sub=:) -command=Set -xecute=""set ^y(sub)=$ZTVALUE""")
 if $ztrigger("item","+^x(sub=:) -command=kill -xecute=""kill ^y(sub)""")
 for i=1:1:3 set $zpiece(^x(i),i,999999)=i
 tcommit
 tstart ():transactionid="batch"
 kill ^x(1)
 kill ^x(2)
 tcommit
 quit
 ;
dataSummary ; Code to summarize the data
 new counts,label,offset,recordsize
 set (label,offset,recordsize)=""
 for  set label=$order(^%ydbJNLFTYPE1(label)) quit:label=""  do
 . for  set offset=$order(^%ydbJNLFTYPE1(label,offset)) quit:offset=""  do
 .. for  set recordsize=$order(^%ydbJNLFTYPE1(label,offset,recordsize)) quit:recordsize=""  do
 ... if $increment(counts($zpiece(^%ydbJNLFTYPE1(label,offset,recordsize),"\",1),$zpiece(^%ydbJNLFTYPE1(label,offset,recordsize),"\",13)))
 ;
 write "Events by global",!
 write ?3,"Event",?10,"Global",?18,"Count",!
 new event,global
 set (event,global)=""
 for  set event=$order(counts(event)) quit:event=""  do
 . for  set global=$order(counts(event,global)) quit:global=""  do
 .. write ?3,event,?10,global,?18,counts(event,global),!
 quit
