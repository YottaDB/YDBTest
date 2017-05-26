;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Display permissions of IPCs created by mumps
;
; Normally run as part of v53004/C9C12002191, via test_perms.csh and "IGS mumps.dat GETIPCPERM {user} {group}".
;
; The default behavior is to show the shared memory and semaphore permissions of the database containing ^a.
; If $getipcperm_opt is set to one of {"objdirperm","rctlfileperm","rctlipcperm"}, it calls that routine instead.
getipcperm
	set $ztrap="write $zstatus,! halt"
	if $zversion["Linux" set octperm=1	; ipcs on most systems output -rw-rw--- style, but Linux outputs 660 style
	set a=^a	; Connect to database
	;
	if $ztrnlnm("getipcperm_opt")="objdirperm"  do objdirperm  quit
	if $ztrnlnm("getipcperm_opt")="rctlfileperm"  do rctlfileperm  quit
	if $ztrnlnm("getipcperm_opt")="rctlipcperm"  do rctlipcperm  quit
	;
	set p1="ftok"
	open p1:(shell="/bin/sh":command="$gtm_exe/mupip ftok mumps.dat | $tst_awk '$1 == ""mumps.dat"" {print $3,$6}'":readonly)::"PIPE"
	use p1
	read x
	close p1
	use $principal
	set semid=$piece(x," ",1)
	set shmid=$piece(x," ",2)
	;
	set shmperm=$$shmperm(shmid)
	use $principal
	write "shmperm="_shmperm
	;
	write ";"
	;
	set p3="ipcs2"
	set semipcscmd="$gtm_tst/com/ipcs -sc"
	set semselcmd="$tst_awk '$2 == """_semid_""" {print $4 "","" $6}'"					; HP-UX, AIX, OSF1, Solaris
	if $zversion["Linux" set semselcmd="$tst_awk '$1 == """_semid_""" {print $2 "","" $6}'"
	open p3:(shell="/bin/sh":command=semipcscmd_" | "_semselcmd:readonly)::"PIPE"
	use p3
	read semperm
	close p3
	set:$data(octperm) $piece(semperm,",",1)=$$octtosemperm($piece(semperm,",",1))
	use $principal
	write "semperm="_semperm
	;
	write !
	quit

; Show permissions of this routine's object directory
objdirperm
	zshow "A":rctl
	if $get(rctl("A",7))["rtnname: getipcperm" do
	. set objdir=$piece(rctl("A",1),"Object Directory         : ",2)
	. zsystem "ls -ld "_objdir
	quit

; Show permissions of this routine's relink control file
rctlfileperm
	zshow "A":rctl
	if $get(rctl("A",7))["rtnname: getipcperm" do
	. set ctlfile=$piece(rctl("A",2),"Relinkctl filename       : ",2)
	. zsystem "ls -l "_ctlfile
	quit

; Show permissions of this routine's relink control and object shared memory
rctlipcperm
	zshow "A":rctl
	if $get(rctl("A",7))["rtnname: getipcperm" do
	. set ctlshmid=$piece($piece(rctl("A",5),"Relinkctl shared memory  : shmid: ",2)," ",1)
	. set objshmid=$piece($piece(rctl("A",6),"Rtnobj shared memory # 1 : shmid: ",2)," ",1)
	. set ctlshmperm=$$shmperm(ctlshmid)
	. set objshmperm=$$shmperm(objshmid)
	. write "ctlshmperm="_ctlshmperm_";objshmperm="_objshmperm,!
	quit

; Convert a three character octal string to rwx permissions
octtoshmperm(oct)
	for  quit:$length(oct)'<3  set oct="0"_oct
	quit "--"_$$octdigtoshmperm($extract(oct,1))_$$octdigtoshmperm($extract(oct,2))_$$octdigtoshmperm($extract(oct,3))

; Convert a single character octal string to rwx permissions
octdigtoshmperm(od)
	quit $select(od=0:"---",od=1:"--x",od=2:"-w-",od=3:"-wx",od=4:"r--",od=5:"r-x",od=6:"rw-",od=7:"rwx",1:"?"_od_"?")

; Convert a three character octal string to rax permissions
octtosemperm(oct)
	for  quit:$length(oct)'<3  set oct="0"_oct
	quit "--"_$$octdigtosemperm($extract(oct,1))_$$octdigtosemperm($extract(oct,2))_$$octdigtosemperm($extract(oct,3))

; Convert a single character octal string to rax permissions
octdigtosemperm(od)
	quit $select(od=0:"---",od=1:"--x",od=2:"-a-",od=3:"-ax",od=4:"r--",od=5:"r-x",od=6:"ra-",od=7:"rax",1:"?"_od_"?")

; Get the permissions of the shared memory segment with the given id
shmperm(shmid)
	new pd,shmipcscmd,shmselcmd,shmperm
	set pd="ipcs1"
	set shmipcscmd="$gtm_tst/com/ipcs -mc"
	set shmselcmd="$tst_awk '$2 == """_shmid_""" {print $4 "","" $6}'"					; HP-UX, AIX, OSF1, Solaris
	if $zversion["Linux" set shmselcmd="$tst_awk '$1 == """_shmid_""" {print $2 "","" $6}'"
	open pd:(shell="/bin/sh":command=shmipcscmd_" | "_shmselcmd:readonly)::"PIPE"
	use pd
	read shmperm
	close pd
	set:$data(octperm) $piece(shmperm,",",1)=$$octtoshmperm($piece(shmperm,",",1))
	quit shmperm
