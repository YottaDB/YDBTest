;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Script to generate valid object files, truncate them to random sizes and verify that a particular operation
; (such as an invocation, explicit ZLINK, or implicit ZLINK triggered by a ZRUPDATE) results in INVOBJFILE error.
truncate
	new i,fail,maxObjectSize,minObjectSize,maxTruncateRatio,minTruncateRatio,count,operation,objSize,truncObjSize,error

	set fail=0

	; Get the limits set in the environment.
	set maxObjectSize=$ztrnlnm("max_object_size")
	set minObjectSize=$ztrnlnm("min_object_size")
	set maxTruncateRatio=$ztrnlnm("max_truncate_ratio")
	set minTruncateRatio=$ztrnlnm("min_truncate_ratio")

	; Get the arguments passed to the routine.
	set count=+$piece($zcmdline," ",1)
	set operation=$piece($zcmdline," ",2)

	; For the ZRUPDATE case, make sure we are subscribed to the current directory.
	set:("zrupdate"=operation) $zroutines=".* "_$zroutines

	; Loop the requested number of times.
	for i=1:1:count do
	.	; Randomly pick initial and truncated object file sizes based on the test's constraints.
	.	set objSize=$random(maxObjectSize-minObjectSize+1)+minObjectSize
	.	set truncObjSize=objSize*(1-(($random(maxTruncateRatio-minTruncateRatio+1)+minTruncateRatio)/100))\1
	.
	.	; Generate the object file.
	.	do ^genobj(operation_"Obj"_i,objSize)
	.
	.	; For the ZRUPDATE case, link in the untampered object.
	.	zlink:("zrupdate"=operation) "zrupdateObj"_i_".o"
	.
	.	; Truncate the object file.
	.	if $&relink.truncateFile(operation_"Obj"_i_".o",truncObjSize)
	.
	.	; For the ZRUPDATE case, up the object's cycle.
	.	zrupdate:("zrupdate"=operation) "zrupdateObj"_i_".o"
	.
	.	; Perform the requested operation and remember the error.
	.	set error=""
	.	do
	.	.	new $etrap
	.	.	set $etrap="set error=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""""
	.	.	if ("invoke"=operation) do
	.	.	.	do @("^invokeObj"_i)
	.	.	else  if ("zlink"=operation) do
	.	.	.	zlink "zlinkObj"_i_".o"
	.	.	else  if ("zrupdate"=operation) do
	.	.	.	do @("^zrupdateObj"_i)
	.
	.	; In case of no or wrong error, print a failure message.
	.	if ("INVOBJFILE"'=error) do
	.	.	write "TEST-E-FAIL, The "_operation_" of object file "_operation_"Obj.o (truncated from "_objSize_" to "_truncObjSize_" bytes) should have caused INVOBJFILE error, "
	.	.	write "but "_$select(""=error:"no error",1:"'"_error_"'")_" was given.",!
	.	.	set fail=1

	zhalt fail
