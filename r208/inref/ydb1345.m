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
; Helper routines for the r208/zcompile_object_badchar-ydb1345 subtest
ydb1345	;
	quit

zc(val)	; ZCOMPILE x.m with -object=val and check that it issues NOTMNAME and produces no object file
	new $etrap,lvl,zs,obj
	set lvl=$zlevel,zs=""
	set $etrap="set zs=$zstatus,$ecode="""" zgoto "_lvl_":done^ydb1345"
	zcompile "-object="_val_" x.m"
done	write $select(zs[",%YDB-E-NOTMNAME,":"PASS",1:"FAIL"),": ZCOMPILE issues "
	write $select(""=zs:"no error",1:$piece($piece(zs,",",3),"-",3)),!
	; Look for an object file other than ydb1345.o (which running this routine creates)
	for  set obj=$zsearch("*.o",1) quit:""=obj  quit:"ydb1345"'=$zparse(obj,"NAME")
	write $select(""=obj:"PASS: no object file was produced",1:"FAIL : "_$zparse(obj,"NAME")_".o was produced"),!
	quit
