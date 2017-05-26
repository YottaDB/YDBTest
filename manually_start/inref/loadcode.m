loadcode	; Load all modules from shared libraries
	;
	N $ZT S $ZT="U $P ZSH ""*"" B"
	N debug,liblst,loadofiles,myzro,rtn
	S loadofiles=+$P($ZCM," ",1)	; 1 means load from directory not libraries
	S debug=+$P($ZCM," ",2)	; Debug level
	;
	I loadofiles S myzro=". "_$ZDIR_"/o("_$ZDIR_"/r)"
	E  S myzro="." F  S liblst=$ZSEARCH("largelib*.so") Q:""=liblst  D
	.S myzro=myzro_" "_$P(liblst,"/",$L(liblst,"/"))
	S myzro=myzro_" "_$ZTRNLNM("gtm_dist")
	; Set $ZRO to use the shared libraries (yes, it does end up starting with a space, but that's OK)
	S $ZRO=myzro
	;
	; ZLink all routines
	F  S liblst=$ZSEARCH("ldcmds*") Q:""=liblst  D
	.I debug U $P W !,liblst,!
	.O liblst:READONLY U liblst:EXC="G EOF"
	.F  R rtn S rtn=$P($P(rtn,"/",2),".",1) D
	..I 2=debug U $p W rtn,! U liblst
	..I (rtn'="") ZL rtn
EOF	.I $ZS'["EOF" USE $P W !,$ZS,! ZM +$ZS
	.C liblst
	U $P
	Q
