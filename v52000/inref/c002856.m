;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c002856	;	Test that incorrect usages of ISV/FCNs ALWAYS generate object code
 ;
 ; --------------------------------------------------------------------------------------------
 ; Stefan's testcase (#1)
 ; --------------------------------------------------------------------------------------------
 ;
 set $zy=$p(%z,"[",2)-1
 ;
 ; --------------------------------------------------------------------------------------------
 ; Stefan's testcase (#2)
 ; --------------------------------------------------------------------------------------------
 ;
 for  quit:$zpriv(r1wait)   ; On Unix, this will generate a FNOTONSYS error
 ;. for  quit:$zascii(r1wait)  ; On VMS,  this will generate a FNOTONSYS error - [no longer generates error - leave in to preserve reference file linenumbers]
 ;
 ; --------------------------------------------------------------------------------------------
 ; VA's testcase
 ; --------------------------------------------------------------------------------------------
 ;
 i '$zpriv("SYSLCK")  ; On Unix, this will generate a FNOTONSYS error
 ;i '$zascii("SYSLCK") ; On VMS,  this will generate a FNOTONSYS error - [no longer generates error - leave in to preserve reference file linenumbers]
 ;
 ; --------------------------------------------------------------------------------------------
 ; Iselin's testcase (#1 and #2)
 ; --------------------------------------------------------------------------------------------
 ;
 q $zsqr($$var(.arr))
 N N S $ZE="",$ZT="ChkBad" q $ZU(12,R,2)
 ;
 ; --------------------------------------------------------------------------------------------
 ; Iselin's testcase (#3)
 ; To test source_error_found is not set (incorrectly) (in stx_error.c) in case of a IS_STX_WARN type of parse error
 ; --------------------------------------------------------------------------------------------
 ;
 i %ZNOGTM s %=$zu(132) d $zu(69,55,1) i %'=1 d terminate("Error switching principal %device to socket")
 ;
 ; --------------------------------------------------------------------------------------------
 ; Testcase from mugj and mvts test
 ; To test shift_gvrefs is not reset (incorrectly) to FALSE (in stx_error.c) in case of a IS_STX_WARN type of parse error
 ; --------------------------------------------------------------------------------------------
 ;
 S V="M"?@($MN("A")?.N)
 ;
 ; --------------------------------------------------------------------------------------------
 ; Do miscellaneous tests of invalid ISV/FCN/DEVICEPARAMETERs (usages from test system)
 ; --------------------------------------------------------------------------------------------
 ;
 I $MN>50 W #
 e  i %ZNOGTM s %device=$ZU(53)
 i %ZNOGTM  use %device:(::"S":$C(28):packSz:packSz) i 1
 f i=1:1:($MN(7)+1) s glob=glob_$MN(x,$MN(52)+1)
 do ^a($MN(strt,$MN(206,240)),9,"a")
 Use $MN
 i $MN(%lnam)+$MN(%sub1)+$MN(%sub2)>%maxkey q
 s locstr=locstr_"a"_$MN(nowexam,6,$MN(nowexam,"a")-7)
 X "a"_subs_"a""a"_$MN(alpha,i)_"a""a""a""a"
 i kills<kil,'$MN(3) s count=count-1,kills=kills+1 k ^a(sub2) s:'$MN(@glob) globals=globals-1
 write $MN($MN(1000),1000000),!
 D:$MN(@^a1A(@A))=1 98+1^a@@^a1A(1),AT^a1IDDO1:@C(1),AT+1^a1IDDO1:@C(2)
 G:$MN(@^a1A(@A))=1 192+1^a@@^a1A(1):"a",AT^a1IDGOB:@C(1),AT+1^a1IDGOB:1
 K:$MN("a")>2 ^a1 S VCOMP=VCOMP_$MN(^a1)
 N @$MN("a","a","a")
 MERGE ^a($MN("a",25))=^a
 N:$MN(A) A,D
 Open $MN:::"a"
 Q $MN(E="a":"a",1:$$MNV($MN(E,2,$MN(E)))_$MN(E,1))
 Quit:$MN>anchor
 Set:'$MN cnt=cnt+1 Xecute:'$MN act
 W $MN(00.999999999)
 W ?20,$MN(I*20/20*.1,8,2),?34,$MN(I*20/10,8,2),!
 c:$MN(ifl)'="a" ifl
 ZM +$MN
 d @$MN
 f  q:$MN(actual("a",i))'=1 d
 k:$MN(id)'[0 id s idok=0 q
 q +$MN(%range*$&RAND(.%qrszqrs),"a")
 tcommit:$MN=2
 trollback:$MN
 u $MN:(NOPASTHRU)
 view "a":$MN(2)
 zsy $MN($MN["a":"a"_$$MNUNC^a%DH($MN),1:"a"_$MN)
 zkill ^a8($MN($$MNUNC^a%HD("a"),$$MNUNC^a%HD("a")))
 zgoto $MN
 ;
 ; --------------------------------------------------------------------------------------------
 ; Test that only the first of LABELEXPECTED errors in one M line is printed as an error.
 ; --------------------------------------------------------------------------------------------
 ;
 i 0 s %=$zu(132) d $zu(69) d $zu(69)
 ;
 ; --------------------------------------------------------------------------------------------
 ; Test that all INVFCN errors in one M line are printed.
 ; --------------------------------------------------------------------------------------------
 ;
 i 0 s %=$zu(132) s %=$zu(132) s %=$zu(132) s %=$zu(132)
 ;
