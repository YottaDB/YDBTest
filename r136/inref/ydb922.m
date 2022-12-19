;#################################################################
;#								#
;# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
setx ;
 for i=1:1:20 set ^x(i)=$justify(i,10)
 for i=1:2:20 kill ^x(i)
 quit
 ;
sety ;
 for i=1:1:20 set ^y(i)=$justify(i,10)
 for i=1:2:20 kill ^y(i)
 quit
 ;
maintest ;
 write "# Ingesting journal data",!
 do INGEST^%YDBJNLF("mumps.mjl","One")
 write "# Printing %YDBJNLF database file name",!
 write $zpiece($$^%PEEKBYNAME("gd_segment.fname","YDBJNLF"),$zchar(0)),!
 write "# Printing ; pieces 1-3 from ^%ydbJNLF global",!
 write "# These are journal file name, journal file format, and database file name",!
 write $zpiece(^%ydbJNLF("One"),";",1,3),!
 write "# Printing records in ^%ydbJNLFTYPE1",!
 new start,v set (start,v)=$name(^%ydbJNLFTYPE1("One"))
 for  set v=$query(@v) quit:v=""  quit:$name(@v,1)'=start  write $zpiece(@v,"\",1),": ",$zpiece(@v,"\",13,15),!
 write "# Global ^%ydbJNLFACTIVE does not exist, as nobody has the current journal file open",!
 write "$data of ^%ydbJNLFACTIVE: ",$data(^%ydbJNLFACTIVE),!
 write "# Global ^%ydbJNLFCOMPLETE showing previous processes having the global file open",!
 new i,count set (i,count)=0
 for  set i=$order(^%ydbJNLFCOMPLETE("One",i)) quit:'i  if $increment(count)
 write "Count of processes which accessed the database should be 2: ",count,!
 new prev set prev=$ZPIECE(^%ydbJNLF("One"),";",4)
 write "# Previous journal file is "_prev,!
 write "# Ingesting previous journal file",!
 DO INGEST^%YDBJNLF(prev)
 write "# Printing ; pieces 1-3 from ^%ydbJNLF global",!
 write "# These are journal file name, journal file format, and database file name",!
 write $zpiece(^%ydbJNLF(prev),";",1,3),!
 write "# Printing records in ^%ydbJNLFTYPE1",!
 new start,v set (start,v)=$name(^%ydbJNLFTYPE1(prev))
 for  set v=$query(@v) quit:v=""  quit:$name(@v,1)'=start  write $zpiece(@v,"\",1),": ",$zpiece(@v,"\",13,15),!
 quit
 ;
purgetest
 new prev set prev=$ZPIECE(^%ydbJNLF("One"),";",4)
 write "$DATA before purging: ",$data(^%ydbJNLF(prev)),!
 do PURGE^%YDBJNLF(prev)
 write "$DATA after purging: ",$data(^%ydbJNLF(prev)),!
 quit
