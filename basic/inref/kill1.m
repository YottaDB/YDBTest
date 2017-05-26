kill1	; Test of Kill command - may be incomplete
;	File modified by Hallgarth on 16-APR-1986 08:11:21.83
;	File modified by Hallgarth on 16-APR-1986 08:00:22.32
	s x=1,y=3,z=4,r=6
	s ^axx(1)="test",^cxxx(2)="tester",^ax(1,1,1)="^ax(1,1,2)"
	s ^ax(1,1,2)="of things",^ax(1,2,3)="blotto",tty=1,tty2=3,^ax(1,2,2)="^ax(1,2,3)"
	k:r>z @^ax(1,1,1)
	k (tty,tty2)
	zwrite
	k
	zwrite
	k ^axx(1),^cxxx(2)
	k @^ax(1,2,2)
	; test some long name variables
	w "test some long name variables",!
	do setvar
	set tf3456789012345678901234567890t=1 
	set tf3456789012345678901234567890f=0
	zwrite
	zwrite ^a2345678
	zwrite ^a234567890123456789012345678901
	write !
	;
	write "initially, all defined",!
	set vcomp=$$gsetvcomp do ^examine(vcomp,"11,11,11,1,11,11,11,1","initial at "_$ZPOSITION) ; all defined at this point
	set vcomp=$$lsetvcomp do ^examine(vcomp,"11,11,11,1,11,11,11,1","initial at "_$ZPOSITION) ; all defined at this point
	;
	;----------------------------------------------------
zkill	write "zkill...",!
	zkill ^a2345678(1),^a234567890123456789012345678901(1)
	zkill a2345678(1),a234567890123456789012345678901(1)
	set vcomp=$$gsetvcomp do ^examine(vcomp,"11,10,11,1,11,10,11,1","ZKILL global at"_$ZPOSITION)
	set vcomp=$$lsetvcomp do ^examine(vcomp,"11,10,11,1,11,10,11,1","ZKILL local at "_$ZPOSITION)
	; postconditional
	do setvar ; to re-initialize all globals
	zkill:tf3456789012345678901234567890t ^a2345678(1,2)
	zkill:tf3456789012345678901234567890f ^a234567890123456789012345678901(1,2)
	set vcomp=$$gsetvcomp do ^examine(vcomp,"11,11,10,1,11,11,11,1","postconditionals at "_$ZPOSITION)
	; naked indicator
	do setvar ; to re-initialize all globals
	set ^a234567890123456789012345678901(1,2,1)=1 ; to set up the naked indicator
	zkill ^(3) ; naked indicator to point to ^a234567890123456789012345678901(1,2,3)
	set vcomp=$$gsetvcomp do ^examine(vcomp,"11,11,11,1,11,11,11,0","naked indicator at "_$ZPOSITION)
	; indirection
	do setvar ; to re-initialize all globals
	set ^indir1="^a2345678(1)",indir2="a234567890123456789012345678901",com1="zkill a2345678(1,2)"
	zkill @^indir1,@indir2
	xecute com1
	set vcomp=$$gsetvcomp do ^examine(vcomp,"11,10,11,1,11,11,11,1","indirection at "_$ZPOSITION)
	set vcomp=$$lsetvcomp do ^examine(vcomp,"11,11,10,1,10,11,11,1","indirection at "_$ZPOSITION)
zwithdraw ;----------------------------------------------------
	write "zwithdraw...",!
	do setvar ; to re-initialize all globals
	;
	zwithdraw ^a2345678(1,2),^a234567890123456789012345678901(1,2)
	zwithdraw:tf3456789012345678901234567890t a2345678(1,2),a234567890123456789012345678901(1,2)
	set vcomp=$$gsetvcomp do ^examine(vcomp,"11,11,10,1,11,11,10,1","ZWITHDRAW global at "_$ZPOSITION)
	set vcomp=$$lsetvcomp do ^examine(vcomp,"11,11,10,1,11,11,10,1","ZWITHDRAW local at "_$ZPOSITION)
	; naked indicator
	do setvar ; to re-initialize all globals
	set ^a234567890123456789012345678901(1,1)=1 ; to set up the naked indicator
	zwithdraw ^(2) ; naked indicator to point to ^a234567890123456789012345678901(1,2)
	set vcomp=$$gsetvcomp do ^examine(vcomp,"11,11,11,1,11,11,10,1","naked indicator at "_$ZPOSITION)
	; indirection
	do setvar ; to re-initialize all globals
	set ^indir1="^a2345678(1)",indir2="a234567890123456789012345678901",com1="zwithdraw a2345678(1,2)"
	zwithdraw @^indir1,@indir2
	xecute com1
	set vcomp=$$gsetvcomp do ^examine(vcomp,"11,10,11,1,11,11,11,1","indirection at "_$ZPOSITION)
	set vcomp=$$lsetvcomp do ^examine(vcomp,"11,11,10,1,10,11,11,1","indirection at "_$ZPOSITION)
kill	;----------------------------------------------------
	write "kill...",!
	do setvar ; to re-initialize all globals
	;
	kill ^a2345678(1),^a234567890123456789012345678901(1)
	kill ^a2345678(1),^a234567890123456789012345678901(1)	; repeat
	kill a2345678(1),a234567890123456789012345678901(1)
	kill:tf3456789012345678901234567890f ^a2345678
	set vcomp=$$gsetvcomp do ^examine(vcomp,"1,0,0,0,1,0,0,0","KILL global at "_$ZPOSITION)
	set vcomp=$$lsetvcomp do ^examine(vcomp,"1,0,0,0,1,0,0,0","KILL local at "_$ZPOSITION)
	;
	do setvar ; to re-initialize all globals
	kill ^a2345678
	kill:tf3456789012345678901234567890t a2345678,a234567890123456789012345678901
	kill ^a2345678901234567890123456789012 ; should not error out, and kill ^a234567890123456789012345678901
	set vcomp=$$gsetvcomp do ^examine(vcomp,"0,0,0,0,0,0,0,0","KILL global at "_$ZPOSITION)
	set vcomp=$$lsetvcomp do ^examine(vcomp,"0,0,0,0,0,0,0,0","KILL local at "_$ZPOSITION)
	do ^examine($DATA(^a2345678901234567890123456789),"1","shorter globals at "_$ZPOSITION)
	;
	do setvar ; to re-initialize all globals
	kill (a2345678,errcnt) ;save errcnt since it shows whether there were errors
	set vcomp=$$lsetvcomp do ^examine(vcomp,"11,11,11,1,0,0,0,0","exclusive KILL at "_$ZPOSITION)
	; indirection
	do setvar ; to re-initialize all globals
	set ^indir1="^a2345678(1,2)",indir2="a234567890123456789012345678901",com1="kill a2345678(1,2)"
	kill @^indir1,@indir2
	xecute com1
	set vcomp=$$gsetvcomp do ^examine(vcomp,"11,1,0,0,11,11,11,1","indirection (gbls) at "_$ZPOSITION)
	set vcomp=$$lsetvcomp do ^examine(vcomp,"11,1,0,0,0,0,0,0","indirection (lcls) at "_$ZPOSITION)
	;
	; naked indicator
	do setvar ; to re-initialize all globals
	set ^a234567890123456789012345678901(1,1)=1 ; to set up the naked indicator
	kill ^(2) ; naked indicator to point to ^a234567890123456789012345678901(1,2)
	set vcomp=$$gsetvcomp do ^examine(vcomp,"11,11,11,1,11,11,0,0","naked indicator at "_$ZPOSITION)
	if ""=$get(errcnt) write "PASS",!
	else  write "TEST-E-FAIL, there were some errors",!
	quit
setvar	; set local and global variables
	set ^a2345678="a8"
	set ^a2345678(1)="a8(1)"
	set ^a2345678(1,2)="a8(1,2)"
	set ^a2345678(1,2,3)="a8(1,2,3)"
	set ^a234567890123456789012345678901="a31"
	set ^a234567890123456789012345678901(1)="a31(1)"
	set ^a234567890123456789012345678901(1,2)="a31(1,2)"
	set ^a234567890123456789012345678901(1,2,3)="a31(1,2,3)"
	set ^a2345678901234567890123456789="a29"
	set ^a2345678901234567890123456789012="a32"
	set a2345678="la8"
	set a2345678(1)="la8(1)"
	set a2345678(1,2)="la8(1,2)"
	set a2345678(1,2,3)="la8(1,2,3)"
	set a234567890123456789012345678901="la31"
	set a234567890123456789012345678901(1)="la31(1)"
	set a234567890123456789012345678901(1,2)="la31(1,2)"
	set a234567890123456789012345678901(1,2,3)="la31(1,2,3)"
	set a2345678901234567890123456789="la29"
	set a2345678901234567890123456789012="la32"
	quit
gsetvcomp() ; set vcomp for globals
	set vcomp=$data(^a2345678)_","
	set vcomp=vcomp_$data(^a2345678(1))_","
	set vcomp=vcomp_$data(^a2345678(1,2))_","
	set vcomp=vcomp_$data(^a2345678(1,2,3))_","
	set vcomp=vcomp_$data(^a234567890123456789012345678901)_","
	set vcomp=vcomp_$data(^a234567890123456789012345678901(1))_","
	set vcomp=vcomp_$data(^a234567890123456789012345678901(1,2))_","
	set vcomp=vcomp_$data(^a234567890123456789012345678901(1,2,3))
	quit vcomp
lsetvcomp() ;set vcomp for locals
	set vcomp=$data(a2345678)_","
	set vcomp=vcomp_$data(a2345678(1))_","
	set vcomp=vcomp_$data(a2345678(1,2))_","
	set vcomp=vcomp_$data(a2345678(1,2,3))_","
	set vcomp=vcomp_$data(a234567890123456789012345678901)_","
	set vcomp=vcomp_$data(a234567890123456789012345678901(1))_","
	set vcomp=vcomp_$data(a234567890123456789012345678901(1,2))_","
	set vcomp=vcomp_$data(a234567890123456789012345678901(1,2,3))
	quit vcomp
