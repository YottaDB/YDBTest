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
ydb935(flaskport)
 do ^job("main^ydb935",10,""""_flaskport_"""")
 quit
 ;
main(flaskport)
 new start,end
 set start=$$h2s($horolog)
 new i for i=1:1:100 do  quit:(end-start>9)
 . ; Random name
 . new c1,c2,c3
 . set c1=$zchar($random(26)+65)
 . set c2=$zchar($random(26)+65)
 . set c3=$zchar($random(26)+65)
 . new name set name=c1_c2_c3
 . ;
 . ; Random age
 . new age set age=$random(130)
 . ;
 . ; Random Sex
 . new sex set sex=$select($random(1):"F",1:"M")
 . ;
 . zsystem "curl -sS -H 'Content-Type: application/json' -X POST localhost:"_flaskport_"/random_set -d '{ ""name"": """_name_""", ""age"": """_age_""", ""sex"": """_sex_""" }'"
 . zsystem "curl -sS -H 'Content-Type: application/json' -X GET localhost:"_flaskport_"/random_get"
 . set end=$$h2s($horolog)
 quit
  ;
h2s(%) ;Convert $H to seconds.
  quit 86400*%+$P(%,",",2)
