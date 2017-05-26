d002556 ;
	quit
init	;
	set unix=$zversion'["VMS"
	; since GTM V4 in VMS has a record-header of 7 bytes which is 1 byte lesser than GTM V4 in Unix, we need one more
	; character in the VMS subscript to test the max_record_length case
	if unix  set subs="""ABCDEFG"",""HIJKLMNOP"",1,""QRSTUVWXY"","
	if 'unix set subs="""ABCDEFGH"",""HIJKLMNOP"",1,""QRSTUVWXY"","
	quit
	;
mkdb1	;
	do init
	s x=1
	f i=1:4:12 do
	. if x=0 do
	. . X "Set ^a("_subs_"i)="""""
	. X "Set ^a("_subs_"i+1)="""""
	. X "Set ^a("_subs_"i+2)=$j(i+2,452)"
	. X "Set ^a("_subs_"i+3)=$j(i+3,452)"
	. S x=0
	quit

mkdb2	;
	do init
	f i=1:2:8 do
	. X "Set ^a("_subs_"i)="""""
	. X "Set ^a("_subs_"i+1)=$j(i+3,453)"
	. S x=0
	quit

mkdb3	;
	do init
	s alpha="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	k ^a
	if unix  set len=223
	if 'unix set len=224
	f i=1:3:26 do
	. X "Set ^a("_subs_""""_$E(alpha,i)_""")="""" "
	. set str=$j(i+1,len)
	. X "Set ^a("_subs_""""_$E(alpha,i+1)_""")=str "
	. set str=$j(i+2,len)
	. X "Set ^a("_subs_""""_$E(alpha,i+2)_""")=str "
	. S x=0
	quit

mkdb4	;
	do mkdb3
	quit

