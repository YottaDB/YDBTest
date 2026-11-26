;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
ydb1415reorg	; Called by r208/u_inref/reorg_trunc_killed_gbls-ydb1415.csh
	quit
init	; set a node in each of the globals ^g1 to ^g1000, then kill each global, which leaves
	; an empty tree (a root block and an empty data block) for each global
	new i
	for i=1:1:1000 set @("^g"_i)=i
	for i=1:1:1000 kill @("^g"_i)
	quit
nr	; write the number of non-TP restarts at the first try (NR0) of region DEFAULT
	write $piece($piece($view("GVSTATS","DEFAULT"),"NR0:",2),",",1),!
	quit
