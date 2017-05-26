per02397	; Test for PER 002397
	New
	Do begin^header($TEXT(+0))

	Set %DA="18SEP1992"
	Do %B06V
	Do ^examine(%DN,55413,"PER 002397")
	If errcnt=0 Write "   PASS - PER 002397",!

	Do end^header($TEXT(+0))
	Quit

; DO NOT MODIFY THIS TEST BEYOND THIS POINT!!!
; THE TEST IS SENSATIVE TO CHANGES IN THE RELATIVE
; POSITION OF STATEMENTS.

%CEL	;
%SO	;
%B06CC	;
	Q
%B06V	;;ALPHA TO NUMERIC
	S %A="*",%DF=$P(^ASW("AB06L000"),%A,1)
%B06VS	I $D(^ASW("AB06L000","USER"))#10 G @("%B06VS^"_^ASW("AB06L000","USER"))
	S %A="*",%DN=0,%J=^ASW("AB06L000",%DF),%DL=$P(%J,%A,3),%J=$P(%J,%A,2),%J="S %H=%DA'?"_%J X %J I %H G %B06Z:'$D(^ASW("AB06L000","FP")),%B06VW
	I %DL'="" S %DZ=$P(%DA,%DL,1),%N=$P(%DA,%DL,2),%YY=$P(%DA,%DL,3) G %B06VV
	S %DZ=$E(%DA,1,2) S:$L(%DA)=6 %N=$E(%DA,3,4),%YY=$E(%DA,5,6) S:$L(%DA)=7 %N=$E(%DA,3,5),%YY=$E(%DA,6,7)
	S:$L(%DA)=8 %N=$E(%DA,3,4),%YY=$E(%DA,5,8) S:$L(%DA)=9 %N=$E(%DA,3,5),%YY=$E(%DA,6,9)
	I $L(%YY)>2 I %YY>2599 G %B06Z
%B06VV	S:$L(%YY)=2 %YY="19"_%YY S %DZ=+%DZ,%YF=%YY S:$L(%YY)>2 %YY=%YY#100 F %J=0:1:12 S %DM(%J)=$P("31-28-31-30-31-30-31-31-30-31-30-31","-",%J)
	S %DM(2)=%DM(2)+'(%YY#4) I %N?3A S %N=$F("JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC ",%N)\4
	S:'$D(%DM(+%N)) %N=1,%DZ=0 I '%DZ!'%N!(%DM(+%N)<%DZ) S %DN=0 G %B06Z
	S %H=0 F %J=1:1:(%YF-1841) S %H=(%J#4=0)+365+%H
	F %J=1:1:%N-1 S %H=%H+%DM(%J)
	S %DN=%H+%DZ 
	S:%DN=21609 %DN=0 
	S:%DN>21609 %DN=%DN-1 G %B06Z
	;;
	; Alternative input types.
	; Check for "T"oday,"T"oday+,"T"oday-
%B06VW	I $E(%DA)="T" S %DN=+$H+$P(%DA,"T",2) D %B06I G %B06VWE
	; First character must be numeric
	I $E(%DA)'?1N S %DN=0 G %B06Z
	; Has only the day number been entered ?
	I %DA?1.2N S %D(%D)=%DA D %B06IT S %DA=$E(100+%D(%D),2,3)_$E(%DA,3,99) D %B06V G %B06VWE:%DN,%B06Z
	; Has a valid entry format been used ?
%B06VW1	S %J2=0,%DF="" F %J=0:1 S %DF=$O(^ASW("AB06L000",%DF)) Q:%DF=""!(%DF'?1N.N)  S %H=$P(^ASW("AB06L000",%DF),%A,2),%H1="S %J1=%DA?"_%H X %H1 Q:%J1
	I +%DF S %DFZ=%DF D %B06VS,%B06I G %B06VWE
	; Now strip any remaining delimiters
	S %DX=" -/\" F %J=1:1:$L(%DX) I $F(%DA,$E(%DX,%J)) S %DA=$E(%DA,1,$F(%DA,$E(%DX,%J))-2)_$E(%DA,$F(%DA,$E(%DX,%J)),255),%J=%J-1,%J2=1
	; If delimiters have been stripped, re-check for valid formats
	G %B06VW1:%J2
	; Check for a valid "short form". Ie 2N3U or 4N
%B06VW2	I %DA?2N3U S %D(%D)=%DA D %B06IT S %DA=%D(%D)_$E(%DA,6,9) D %B06V G %B06VWE:%DN,%B06Z
	I %DA?4N,+$E(%DA,3,4),+$E(%DA,3,4)'>12 S %D(%D)=%DA,%DA=$E(%DA,1,2)_$P("JAN*FEB*MAR*APR*MAY*JUN*JUL*AUG*SEP*OCT*NOV*DEC",%A,+$E(%DA,3,4)) G %B06VW2
%B06VWE	S %HL=24,%T=%DA,%X=30 D %CEL,%SO I $D(%D) S %D(%D)=%DA
	G %B06Z
	;;
%B06F	;;NUMERIC TO EXPANDED ALPHA
	I $D(^ASW("AB06L000","USER"))#10 G @("%B06F^"_^ASW("AB06L000","USER"))
	S %DA="",%S=1,%A="*",%DA="",%DF=22,%DL="" D %B06CC
%B06FF	S %DA=$P("Thursday*Friday*Saturday*Sunday*Monday*Tuesday*Wednesday",%A,%DN#7+1)_" "_+%DZ
	S %J="th" S:+%DZ#10=1&(%DZ'=11) %J="st" S:+%DZ#10=2&(%DZ'=12) %J="nd" S:+%DZ#10=3&(%DZ'=13) %J="rd"
	S %DA=%DA_%J_". of "_$P("January*February*March*April*May*June*July*August*September*October*November*December",%A,+%N)_", "_%YY
	G %B06Z
	;;
%B06IT	;;TODAY'S DATE
	S %DN=+$H G %B06I
	;;
%B06I	;;NUMERIC TO ALPHA
	I $D(^ASW("AB06L000","USER"))#10 G @("%B06I^"_^ASW("AB06L000","USER"))
	S %A="*",%S=0,%DA="",%DF=$P(^ASW("AB06L000"),%A,1),%DL=$P(^ASW("AB06L000",%DF),%A,3) S:$D(^ASW("AB06L000","FP")) %DF=2,%DL="" I %DN'?1N.N!(+%DN=0) G %B06Z
%B06IC	G %B06CC
	;;
%B06M	;; Stored (valid) alpha to numeric, any format, needed for m/sql
	;; Returns %DN and %DN(1)=day(NN), %DN(2)=month(NNAAA), %DN(3)=year(NNNN)
	I %DA?6.8N S (%DZ,%DN(1))=$E(%DA,1,2),%N=3,%YY=$E(%DA,5,8),%DF=0 G %B06MM
	F %N=2:1 Q:$E(%DA,%N)'?1N
	S %DF=%DA?.E3A.E,(%DZ,%DN(1))=$E(%DA+100,2,3),%N=$E(%DA,%N)?1P+%N,%YY=$E(%DA,$L(%DA)-3,11) S:%YY'?4N %YY=$E(%YY,3,4)
%B06MM	S %J="JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC"
	I %DF S %N=$E(%DA,%N,%N+2),%DN(2)=$E($F(%J,%N)\4+100,2,3)_%N,%N=+%DN(2)
	I '%DF S %N=$E($E(%DA,%N,%N+1)+100,2,3),%DN(2)=%N_$P(%J," ",+%N)
	S:%YY<100 %YY=19_%YY S %DN(3)=%YY,%YY=%YY-1840-(%N<3)
	S %DN=(%YY\4*1461)+(%YY#4*365)-$P("1 -30 307 276 246 215 185 154 123 93 62 32"," ",%N)+%DZ,%DN=%DN+(%DN<21609)
	G %B06Z
	;;
%B06Z	K %DF,%DL,%DZ,%YY,%H,%J,%DM,%R,%LY,%N,%S,%YF,%A Q
