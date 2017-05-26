; Test case taken from the JI. It caused MUPIP TRIGGER load to redisplay the "Proceed" prompt
-*
+^MR(acn=:,"name") -command=set -xecute="set:$length($ztvalue)=0 $ecode="",U14: Msgname cannot be empty.,"""  -name=Trigmsgname
+^MR(acn=:,"introducein") -command=set -name=Trigmsgdeprecatein -xecute=<<
  set:'(($ztvalue?1U1N1"."1N1"-"4N1U)!($ztvalue?1U1N1"."1N1"-"4N)) $ecode=",U13: Invalid format of introducein. Correct format is VN.N-NNNNA,"
>>
+^MR(acn=:,"deprecatein") -command=set -name=Trigmsgdeprecatein -xecute=<<
  set:$length($ztvalue)=0 $ztvalue="Not now"
  set:'(($ztvalue?1U1N1"."1N1"-"4N1U)!($ztvalue?1U1N1"."1N1"-"4N)!($ztvalue="Not now")) $ecode=",U13: Invalid format of deprecatein. Correct format is VN.N-NNNNA or Not now,"
>>
