#!/usr/local/bin/tcsh -f
source $gtm_tst/com/dbcreate.csh mumps 5 255 4096 8192

# Testing the trigger command file parsing
# trigvn -command=cmd[,...] -xecute=strlit [-[z]delim="expr]" [-pieces=[lvn=]int1[:int2][;...]] [-options=[isolation][,consistencycheck]]
# trigvn	:
# 	Null Subscripts		^trigvn
#	Ranges			^trigvn(:) , ^trigvn(:2;5:) , ^trigvn(:"b";"m":"x")
#	Multiple Ranges		^trigvn(0,:,:) , ^trigvn(";":":";5:)
#				^trigvn(:,55;66;77:,:) , ^trigvn(2:,:"m";10;20;25;30;35;44;50,:)
#	Allow LVNs		^trigvn(tvar=:,tvar2="a":"z",tvar3=:10;20)
#
# -command=	S[ET],K[ILL],ZTK[ill],ZK[ill],ZW[ithdraw]
# 	Set only
# 	Kill only
# 	Set and Kill type
#
# -xecute=	"do ^twork"
# 		"do tsubrtn^twork"
# 		"do ^twork()"
# 		"do tsubrtn^twork()"
# 		"do ^twork(lvnname)"
# 		"do tsubrtn^twork(""5"",5)"
#
# -[z]delim=
# 	Single character	,
# 	Multiple characters	~"`
# 	With $[Z]Char		\$zchar(126)_\$char(96) aka ~`
# 	W/nonprinting $[z]char	\$zchar(9)_\$char(254)_""""
# 	Unicode character	\$char(8364)_\$char(36)_`
# 	\$zchar on Unicode chars	\$zchar(8364)_\$zchar(65284) 1st bytes of the euro and full dollar
#
# -piece=
# 	single piece	1
# 	multiple pieces	4;5;6  <--- doubles as collapsable
# 	range of piece	1:8
# 	discontiguous	1:3;7:8
# 	collapsable range
# 	with LVN	tlvn=1:3;5:6;7:8
#
# -options=
# 	isolation		i,isolation
# 	noisolation		noi,noisolation
# 	c[onsistencycheck]	c
# 	noc[onsistencycheck]	noc
#
# -name=
# 	allow use of all graphic characters 32-126
# 	allow names up to 28 characters
# 	disallow use of all non-graphic characters 1-31,127-155
#	disallow names over 28 characters

cat > zload.m << MPROG
zload
	set file=\$zcmdline
	open file:readonly
	use file
	for  quit:\$zeof  read line  do
	.	use \$p
	.	set fchar=\$extract(line,1)
	.	if \$select(fchar="-":1,fchar="+":1,1:0)  do
	.	.	set x=\$ztrigger("item",line)
	.	.	if 'x  write "FAILED: ",line,!
	. 	use file
	close file
	quit
show
	use \$p
	if '\$ztrigger("select") write "Select failed",!
	write !
	quit
MPROG
$convert_to_gtm_chset zload.m

echo "======================="
echo "Invalid use of +/-"
set ntest="invalid_plusminus"
cat  > ${ntest}.trg  <<TFILE
-+
+-
+
+^
+ *
-
- *
-^*
-^ *
-^ a
-a^
-a^*
TFILE
$convert_to_gtm_chset ${ntest}.trg
echo "load trigger file by file with ztrigger"
$MUPIP trigger -trig=${ntest}.trg

echo "load trigger file by file with ztrigger"
$gtm_exe/mumps -run %XCMD 'set x=$ztrigger("file","invalid_plusminus.trg")'

echo "load trigger file line by line with ztrigger"
$gtm_exe/mumps -run zload ${ntest}.trg >&! ${ntest}.zloadout
echo "12 triggers should get 12 failures"
$grep -c FAILED ${ntest}.zloadout

$gtm_tst/com/dbcheck.csh -extract
