;
; Run mupip ftok in a PIPE and parse the output to verify if rundown has correctly
; rundown the database.
;
; Note this subtest currently disabled due to issues with GTM-7386. See u_inref/rorundown.csh for more info.
;
	Set TAB=$ZChar(9)
	Do CommandToPipe("$gtm_dist/mupip ftok mumps.dat",.results)	
	;
	; We expect 3 output lines from mupip ftok. Sample output shown below:
	;
	;                File  ::             Semaphore Id  ::         Shared Memory Id  ::                FileId
	;---------------------------------------------------------------------------------------------------------------
	;           mumps.dat  ::    14811140 [0x00e20004]  ::     7471112 [0x00720008]  ::  0x004001000000000002fc0000000000000000000000000000
	;
	If (3'=results(0)) Do
	. Write "CHECKFTOK - FTOK command results not expected - results follow",!
	. ZWrite results
	. ZHalt 1
	;
	; Parse 3rd line - semaphore and sharedmem ids should be -1 if properly cleared from DB.
	;
	Set line=results(3)
	Do EliminateExtraWhiteSpace(.line)
	Set semid=$ZPiece(line," ",4)
	Set shmid=$ZPiece(line," ",7)
	If ((-1'=semid)!(-1'=shmid)) Do
	. Write "FAIL - mumps.dat was not correctly run down",!
	. ZHalt 1
	Write "Database was successfully rundown",!
	Quit

;
; Routine to execute a command in a pipe and return the executed lines in an array (taken from gtmpcat.m)
;
CommandToPipe(cmd,results)
	New pipecnt,pipe,saveIO
	Kill results
	Set pipe="CmdPipe"
	Set saveIO=$IO
	Open pipe:(Shell="/bin/sh":Command=cmd)::"PIPE"
	Use pipe
	Set pipecnt=1
	For  Read results(pipecnt) Quit:$ZEOF  Set pipecnt=pipecnt+1
	Close pipe
	Set results(0)=pipecnt-1
	Kill results(pipecnt)
	Use saveIO
	Quit

;
; Eliminate multiple sequential white space chars to promote parsing with $Piece (taken from gtmpcat.m)
;
EliminateExtraWhiteSpace(str)
	New lastch,sp,len,newstr
 	Set str=$Translate(str,TAB," ")	; Convert tabs to spaces first
	Set len=$ZLength(str)
	Set lastch=1,newstr=""
	For  Quit:lastch>len  Do
	. Set sp=$ZFind(str," ",lastch)
	. If (0<sp) Do
	. . Set newstr=newstr_$ZExtract(str,lastch,sp-1)
	. . For lastch=sp:1:len+1 Quit:(" "'=$ZExtract(str,lastch))	; Going to plus 1 terminates the loop
	. Else  Set newstr=newstr_$ZExtract(str,lastch,len),lastch=len+1 
	Set str=newstr
	Quit
