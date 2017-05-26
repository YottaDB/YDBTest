tstidev	;
	; Test device indirection

	Write "tstidev starting",!
	Set unix=$ZVersion'["VMS"
	Set x="tstopen.file"
	Set x2="tstidev.file"
	Set nullaccess=""
	If unix Set rwx="RWX"
	Else    Set rwx="RWED"
	Set y="(Newversion:Stream:Owner="""_rwx_""":Group=nullaccess:World=nullaccess)"
	Set clsrnm="@clsrnm2"
	Set clsrnm2="(Rename=""tstidev.file"")"
	Set z="(Delete)"

	; make sure tstidev.file is gone
	If unix Do 
	. Open x2:@"@y"
	. Close x2:@z
	Else  Do
	. Open x2:@y
	. Close x2
	. ZSystem "Delete "_x2_".*"

	Open x:@y
	Use x
	Write "testing 1 2 3 4",!
	Close x:@clsrnm
	Use $P

	Set a="f"
	Set @a@(1)="(Newversion:Stream)"
	If f(1)'="(Newversion:Stream)" Write "Wrong value here !!",!
	Open x2:@(@a@(1))
	Use x2
	Write "testing 4 3 2 1",!
	Close x2

	Open x2:(Readonly)
	Use x2
	Read p
	Use $P
	If p'="testing 4 3 2 1" Write "Bad read value",!
	Close x2:@"(Delete)"

	If 'unix Do  
	. Open x2:(Readonly)
	. Use x2
	. Read p
	. Use $P
	. If p'="testing 1 2 3 4" Write "Bad read value b#1",!
	. Close x2:Delete

	; Now do it all over with global variables
	
	Set ^x="tstopen.file"
	Set ^x2="tstidev.file"
	Set ^nullaccess=""
	Set ^y="(Newversion:Stream:Owner="""_rwx_""":Group=^nullaccess:World=^nullaccess)"
	Set ^clr="(X=0:y=0:Clearscreen:X=^xx:Y=^yy)"
	Set ^clsrnm="@^clsrnm2"
	Set ^clsrnm2="(Rename=""tstidev.file"")"
	Set ^xx=5,^yy=15
	Set ^z="(Delete)"

	; make sure tstidev.file is gone
	Open ^x2:@"@^y"
	Close ^x2:@^z

	Open ^x:@^y
	Use ^x
	Write "testing 1 2 3 4",!
	Close x:@^clsrnm
	Use $P

	Set ^a="^f"
	Set @^a@(1)="(Newversion:Stream)"
	If ^f(1)'="(Newversion:Stream)" Write "Wrong value here 2 !!",!
	Open ^x2:@(@^a@(1))
	Use ^x2
	Write "testing 4 3 2 1",!
	Close ^x2
	Open ^x2:(Readonly)
	Use ^x2
	Read ^p
	Use $P
	If ^p'="testing 4 3 2 1" Write "Bad read value 2",!

	Close ^x2:@"(Delete)"

	If 'unix Do  
	. Open ^x2:(Readonly)
	. Use ^x2
	. Read ^p
	. Use $P
	. If ^p'="testing 1 2 3 4" Write "Bad read value b#2",!
	. Close ^x2:Delete

	Write "Done!",!
	Quit

