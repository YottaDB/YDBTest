;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper for the r208/ydbenv_gde_err-ydb1355 subtest
ydb1355
	quit

show	; Show the regions of the global directory $ydb_gbldir, and the key size and null subscripts setting
	; of each region named in the command line. %PEEKBYNAME reads these from the global directory without
	; opening any database file, as %YDBENV does.
	new i,nullsubs,region,regions
	set regions="",region=""
	for  set region=$view("gvnext",region) quit:""=region  set regions=regions_" "_region
	write "Regions :",regions,!
	for i=1:1:$length($zcmdline," ") set region=$piece($zcmdline," ",i) do:$length(region)
	. if '$find(regions_" "," "_region_" ") write region," : does not exist",! quit
	. set nullsubs=$$^%PEEKBYNAME("gd_region.null_subs",region)
	. write region," : key size ",$$^%PEEKBYNAME("gd_region.max_key_size",region)
	. write ", null subscripts ",$select(0=nullsubs:"NEVER",1=nullsubs:"ALWAYS",1:"EXISTING"),!
	quit
