;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

ydb1097	;
	set case=0
	for userWritePerm=0,1 do
	. for groupReadPerm=0,1 do
	. . for otherReadPerm=0,1 do
	. . . write "# Test case "_$incr(case)_" : Routine object directory has userWritePerm=",userWritePerm,", groupReadPerm=",groupReadPerm,", otherReadPerm=",otherReadPerm,!
	. . . ;
	. . . ; "user" should have Read and Execute permissions or else we would get other errors
	. . . ; so we only vary the Write permissions for "user"
	. . . set userReadPerm=1
	. . . set userExecutePerm=1
	. . . set userPerm=$$mergePerm(userReadPerm,userWritePerm,userExecutePerm)
	. . . ;
	. . . set groupWritePerm=groupReadPerm	; this is not randomized because in "gtm_permissions.c", we check
	. . .					; for either read or write permissions to be set and if so treat it
	. . .					; as the same (see "file_group_perms = (0060 & st_mode);" line there).
	. . . set groupExecutePerm=$random(2)
	. . . set groupPerm=$$mergePerm(groupReadPerm,groupWritePerm,groupExecutePerm)
	. . . ;
	. . . set otherWritePerm=otherReadPerm	; this is not randomized for the same reasons as "groupWritePerm" above
	. . . set otherExecutePerm=$random(2)
	. . . set otherPerm=$$mergePerm(otherReadPerm,otherWritePerm,otherExecutePerm)
	. . . ;
	. . . set perm="0"_userPerm_groupPerm_otherPerm
	. . . set xstr="chmod "_perm_" ."
	. . . set ^chmod(case)=xstr
	. . . write "Relinkctl file permissions : Expected = -rw-"_$select(groupWritePerm:"rw-",1:"---")_$select(otherWritePerm:"rw-",1:"---")
	. . . write " : Actual = "
	. . . zsystem xstr
	. . . zsystem "$gtm_dist/mumps -run run^ydb1097"
	quit

mergePerm(user,group,other)	;
	quit (user*4)+(group*2)+other

run	;
	kill v
	set $zroutines=".*"
	zshow "a":v
	; The "sed" usage below is to remove the trailing "." in the permissions bit seen in RHEL/SELinux systems
	zsystem "ls -l "_$piece(v("A",2)," : ",2)_" | awk '{print $1}' | sed 's/\.$//g'"
	quit

