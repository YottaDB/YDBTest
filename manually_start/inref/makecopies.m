makecopies	; Create a script to make copies of the source code
		; then execute the script and compile the routines
	N copies,cpfile,debug,ldcmd,libext,ldfile,libinc,libsuf,numlibs,origperlib,osz,rnc,rno,rtnarray,rtncnt,rtnsuf,rtnperlib
	S copies=+$P($ZCM," ",1) S:(2>copies) copies=2 ; no longer used - computed base on need
	S rtnperlib=+$P($ZCM," ",2) S:(1>rtnperlib) rtnperlib=1000	; S:(rtnperlib>ldtocmax) rtnperlib=ldtocmax
	S debug=+$P($ZCM," ",3)	
	W:debug copies," copies of each routine and new library every ",rtnperlib," routines",!
	V "NOLVNULLSUBS"
	F i=1:1 S row=$T(ldopttab+i) Q:""=row  I $ZVER[$P(row,";",2) D  Q
	.S ldcmd=$P(row,";",3),libext=$P(row,";",4),libinc=$P(row,";",5),libincsuf=$P(row,";",6) 
	E  W !,"No table entry for current GT.M version",! Q 
	; compile all original routines
	ZSY "cd o;find ../r -name \*.m -exec $gtm_dist/mumps {} \; >&/dev/null;cd ..;du -sk o >osize.txt"
	O "osize.txt":READONLY U "osize.txt" R osz C "osize.txt" 
	; Get list of routines and finalize number of original routines per library
	F rtncnt=0:1 S rno=$P($ZSEARCH("r/*.m"),".",1) Q:""=rno  S rtnarray($P(rno,"/",$L(rno,"/")))="" 
	S copies=5000000/osz+1\1,numlibs=rtncnt*copies/rtnperlib\1
	S origperlib=rtncnt/numlibs\1
	;
	; Build shell script to make copies of files and list of files for ld
	S cpfile="makecopies.sh" O cpfile:(newversion:OWNER="RWX") U cpfile W "#!/usr/local/bin/tcsh",!
	S rnc="",rtncnt=0,rno="",ldfile="ldcmds"_$I(libsuf)
	O ldfile:newversion 
	F rtnsuf=0:1:copies-1 D
	.F  S rnc=$O(rtnarray(rnc)) Q:""=rnc  D
	..I 0=(($I(rtncnt)+origperlib)#rtnperlib) D cpld(1)
	..S mrtn=rnc_"QWQ"_rtnsuf_".m"
	..U cpfile 
	..W "cp -f r/",rnc,".m o/",mrtn,!,"cd o",!,"$gtm_dist/mumps ",mrtn," >&/dev/null",!,"rm -f ",mrtn,!,"cd ..",!
	..U ldfile W "o/",rnc,"QWQ",rtnsuf,".o",!
	D cpld(2) ; on the last call to cpld ask for twice as many original routines to ensure we get them all
	C ldfile:delete
	Q
cpld(i,cmd) ; Make copies of files, compile them  
	U ldfile
	F rtncnt=rtncnt:1:rtncnt+(origperlib*i) S rno=$O(rtnarray(rno)) Q:""=rno  W "o/",rno,".o",!
	C cpfile,ldfile
	I debug U $P W "Copying and compiling routines with ",!
	ZSY "./"_cpfile
	O cpfile:(newversion:OWNER="RWX") U cpfile W "#!/usr/local/bin/tcsh",!
	; Build shared libraries
	; The ld options should be pulled from a table based upon the platform
	S cmd=ldcmd_" largelib"_libsuf_libext_libinc_ldfile_libincsuf_" >&/dev/null"
	I debug U $P W "Load command is ",cmd,!
	ZSY cmd;,"rm -f o/*.o"
	S ldfile="ldcmds"_$I(libsuf) 
	O ldfile:newversion I debug U $P W "New load file is ",ldfile,!
	Q
ldopttab;system,load command, options, file input cmd note: may need trailing space or not 
	;AIX;$gt_ld_m_shl_linker -brtl -G -bexpfull -bnoentry -b64 -o;.so; -f ; ;
	;Linux IA64;$gt_ld_m_shl_linker -fPIC -shared -o;.so; @; ;
	;HP-UX IA64;$gt_ld_m_shl_linker -b -o;.so; -c ; ;
	;Linux x86_64;$gt_ld_m_shl_linker -fPIC -shared -o;.so; @; ;
	;Solaris SPARC;$gt_ld_m_shl_linker -G -64 -o;.so; `cat ; ` ;
	;Linux S390X;$gt_ld_m_shl_linker -fPIC -shared -o;.so; @; ;
