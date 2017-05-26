 s h1=$h
 ;
 ; w !," expr ? I (N patatom)"
 S X="ABC12ABC12"
 S comp=X?2(5NA)
 d chk(1)
 ;
 ; w !," expr ? I (.N patatom)"
 S X="ABC12"
 S comp=X?2(.A)
 d chk(0)
 ;
 ; w !," expr ? I (N. patatom)"
 S X="ABC12m0008239933"
 S comp=X?2(2.NU)
 d chk(0)
 ;
 ; w !," expr ? I (N.M patatom)"
 S X="AB12m"
 S comp=X?2(1.3AN)
 d chk(1)
 ;
 ; w !," expr ? .I (N patatom)"
 S X="1A1A1A1A1A"
 S comp=X?.4(2"1A")
 d chk(0)
 ;
 ; w !," expr ? .I (.N patatom)"
 S X=""
 S comp=X?.2(.100AP)
 d chk(1)
 ;
 ; w !," expr ? .I (N. patatom)"
 S X="01234567891"
 S comp=X?.4(3.UPN)
 d chk(1)
 ;
 ; w !," expr ? .I (N.M patatom)"
 S X="01 234 567 8 91"
 S comp=X?.5(1.4ANP)
 d chk(1)
 ;
 ;
 ; w !," expr ? I. (N patatom)"
 S X="-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/"
 S comp=X?10.(3P)
 d chk(1)
 ;
 ; w !," expr ? I. (.N patatom)"
 S X=""
 S comp=X?0.(.2L)
 d chk(1)
 ;
 ; w !," expr ? I. (N. patatom)"
 S X="ANN123KL6465465664565654654656K4"
 S comp=X?3.(3.AN)
 d chk(1)
 ;
 ; w !," expr ? I. (N.M patatom)"
 S X="A A A A A A A A A A A A A A A "
 S comp=X?5.(1.3"A ")
 d chk(1)
 ;
 ; w !," expr ? I.J (N patatom)"
 S X=" 0-9"
 S comp=X?2.5(2NP)
 d chk(1)
 ;
 ; w !," expr ? I.J (.N patatom)"
 S X="A"
 S comp=X?9.40(.3A)
 d chk(1)
 ;
 ; w !," expr ? I.J (N. patatom)"
 S X="-=-0"
 S comp=X?1.10(4.E)
 d chk(1)
 ;
 ; w !," expr ? I.J (N.M patatom)"
 S X="K0ADK0ADK0ADK0ADK0ADK0ADK0ADK0ADK0ADK0ADK0ADK0ADK0ADK0ADK0AD"
 S comp=X?10.20(2.4AN)
 d chk(1)
 ;
 ;
 ; w !," expr ? I (N patatom, N patatom)"
 S X="34AND45"
 S comp=X?3(2N,3A)
 d chk(1)
 ;
 ; w !," expr ? I (.N patatom, N patatom)"
 S X="1/343/46"
 S comp=X?5(.3N,1"/")
 d chk(1)
 ;
 ; w !," expr ? I (.N patatom, .N patatom)"
 S X="12345ABCDE1234ABCD123ABC12AB1A"
 S comp=X?9(.5N,.5A)
 d chk(0)
 ;
 ; w !," expr ? I (.N patatom, N. patatom)"
 S X="AS  +   LLLLL------\\\\\"
 S comp=X?6(.3A,4.P)
 d chk(1)
 ;
 ; w !," expr ? I (.N patatom, N.M patatom)"
 S X="****A95+++"
 S comp=X?3(.2AN,2.4P)
 d chk(0)
 ;
 ; w !," expr ? I (N. patatom, N patatom)"
 S X="ABABAABABABABABABABABABAB"
 S comp=X?4(4.A,3"AB")
 d chk(1)
 ;
 ; w !," expr ? I (N. patatom, .N patatom)"
 S X="ABABABABABABABABABABABABABABABABABABABAB"
 S comp=X?4(3.A,.5"AB")
 d chk(1)
 ;
 ; w !," expr ? I (N. patatom, N. patatom)"
 S X="BABABABABABABAB"
 S comp=X?4(4.A,2."AB")
 d chk(0)
 ;
 ; w !," expr ? I (N. patatom, N.M patatom)"
 S X="ABABABABABABABABABABABAB"
 S comp=X?4(7.A,3.4"AB")
 d chk(1)
 ;
 ;
 ; w !," expr ? I (N.M patatom, N patatom)"
 S X="ABABABABABABABABABABABABABABABAB"
 S comp=X?4(2.8A,2"AB")
 d chk(1)
 ;
 ; w !," expr ? I (N.M patatom, .N patatom)"
 S X="0000AA00000AAAAAAAAAAAA055550"
 S comp=X?5(4.10NA,.15A)
 d chk(1)
 ;
 ; w !," expr ? I (N.M patatom, N. patatom)"
 S X="ABABABABABABACABABABAB"
 S comp=X?3(2.10"AB",5.A)
 d chk(1)
 ;
 ; w !," expr ? I (N.M patatom, N.M patatom)"
 S X="ABABABABABABABABABABABABABABABABABAB"
 S comp=X?3(4.10"AB",6.10A)
 d chk(1)
 ;
 ;
 ; w !," expr ? .I (N patatom, N patatom)"
 S X="QIEJjioDIFU"
 S comp=X?.4(4U,3L)
 d chk(1)
 ;
 ; w !," expr ? .I (.N patatom, N patatom)"
 S X="0123123123123"
 S comp=X?.5(.5"123",2N)
 d chk(1)
 ;
 ; w !," expr ? .I (.N patatom, .N patatom)"
 S X="A AAA AA "
 S comp=X?.5(.4A,.4"A ")
 d chk(1)
 ;
 ; w !," expr ? .I (.N patatom, N. patatom)"
 S X="1234SFGHTHJJY5664FDFFFDDFFF4564XGGGGGDD565656GGGGFDFDFDFD444FGGGGGGGGF"
 S comp=X?.1000000(.5N,5.A)
 d chk(1)
 ;
 ; w !," expr ? .I (.N patatom, N.M patatom)"
 S X="ABCDE38495043ABC384949DHFJABCDEF49499JFJFJ"
 S comp=X?.100(.5A,3.10N)
 d chk(1)
 ;
 ; w !," expr ? .I (N. patatom, N patatom)"
 S X="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
 S comp=X?.5(2.A,2"AA")
 d chk(0)
 ;
 ; w !," expr ? .I (N. patatom, .N patatom)"
 S X=""
 S comp=X?.10(0.A,.2N)
 d chk(1)
 ;
 ; w !," expr ? .I (N. patatom, N. patatom)"
 S X="000--1111-6666"
 S comp=X?.5(1."-",3.N)
 d chk(1)
 ;
 ; w !," expr ? .I (N. patatom, N.M patatom)"
 S X="--AADAS474747474         A     0123456789abc12BDBDBDBDD??__BDB_DBDBDDBDB"
 S comp=X?.10(3.PA,2.10N)
 d chk(1)
 ;
 ; w !," expr ? .I (N.M patatom, N patatom)"
 S X="8FDKDS9DFKDS8FK 12345ABCDEFGHIOKJ 123456789456123ACDD"
 S comp=X?.10(3.10AN,1" 12345")
 d chk(1)
 ;
 ; w !," expr ? .I (N.M patatom, .N patatom)"
 S X="D8D8D8D8D8+-*/39NN39=393900"
 S comp=X?.10(3.10AN,.5PN)
 d chk(1)
 ;
 ; w !," expr ? .I (N.M patatom, N. patatom)"
 S X="38323M3-8333333M03*-/400387Q894-6789AD"
 S comp=X?.6(3.10AN,4.PN)
 d chk(0)
 ;
 ; w !," expr ? .I (N.M patatom, N.M patatom)"
 S X="A1A1--AAA-AKK"
 S comp=X?.5(2.5AN,2.5PA)
 d chk(1)
 ;
 ;
 ; w !," expr ? I. (N patatom, N patatom)"
 S X="ABC=====12345=====123=====ABC=====123456789012345ABC"
 S comp=X?3.(3AN,5PN)
 d chk(1)
 ;
 ; w !," expr ? I. (.N patatom, N patatom)"
 S X="A"
 S comp=X?2.(.3"A",3A)
 d chk(1)
 ;
 ; w !," expr ? I. (.N patatom, .N patatom)"
 S X="00000*0000=0=11000*0000000A"
 S comp=X?.4(.10AN,.5PN)
 d chk(0)
 ;
 ; w !," expr ? I. (.N patatom, N. patatom)"
 S X="ABCDABCDABCDABCDabcdabcdABCDABCDabcdabcdABCDABCDABCDABCD"
 ;;;S comp=X?4.(.3"abcd",3."ABCD")
 ;;;d chk(0)
 ;
 ; w !," expr ? I. (.N patatom, N.M patatom)"
 S X="#######"
 S comp=X?4.(.5APN,2.5"#")
 d chk(1)
 ;
 ; w !," expr ? I. (N. patatom, N patatom)"
 S X="ABCDEFGH############ABCDEFGH"
 S comp=X?5.(3.U,4"###")
 d chk(1)
 ;
 ; w !," expr ? I. (N. patatom, .N patatom)"
 S X="1234123412341234123412341234ABCDABCDABCDABCD"
 S comp=X?4.(4."1234",.3"ABCD")
 d chk(1)
 ;
 ; w !," expr ? I. (N. patatom, N. patatom)"
 S X="AAAAAAAAAAA99009999999AAAAAAAAA9990000999999"
 S comp=X?4.(3."A",4.N)
 d chk(1)
 ;
 ; w !," expr ? I. (N. patatom, N.M patatom)"
 S X="111111-2211-2211-221111AA1111-2211-2211-2211-2211-22A11-22111-2211-2211-2211-22"
 S comp=X?5.(2.AN,2.6"11-22")
 d chk(0)
 ;
 ; w !," expr ? I. (N.M patatom, N patatom)"
 S X="DFL;FDK;FDLKFDLJKFDLJKFDLJKFDLJKFDLJKFDLKFDLK;FLKFDFDFDVSLFD"
 S comp=X?4.(2.4"ABCD",2"ABC")
 d chk(0)
 ;
 ; w !," expr ? I. (N.M patatom, .N patatom)"
 S X="ABCDEFGH/1234456"
 S comp=X?4.(5.9NA,.9PAN)
 d chk(1)
 ;
 ; w !," expr ? I. (N.M patatom, N. patatom)"
 S X="*****ABCDEF*******ABCDEFGH***AB***************ABCDEJFK"
 S comp=X?4.(3.9"*",2.A)
 d chk(1)
 ;
 ; w !," expr ? I. (N.M patatom, N.M patatom)"
 S X="ABC0ABABAABABBABABAB0ABAB"
 S comp=X?4.(3.9"AB",3.5AN)
 d chk(1)
 ;
 ;
 ; w !," expr ? I.J (N patatom, N patatom)"
 S X="123ABGH123"
 S comp=X?2.5(3N,2A)
 d chk(1)
 ;
 ; w !," expr ? I.J (.N patatom, N patatom)"
 S X="1B2[[0"
 S comp=X?2.6(.4AN,2P)
 d chk(1)
 ;
 ; w !," expr ? I.J (.N patatom, .N patatom)"
 S X="12*23++++ADDF---AAAAA"
 S comp=X?2.5(.3AN,.3P)
 d chk(0)
 ;
 ; w !," expr ? I.J (.N patatom, N. patatom)"
 S X="++AB"
 S comp=X?2.8(.5"++",4.AP)
 d chk(1)
 ;
 ; w !," expr ? I.J (.N patatom, N.M patatom)"
 S X="*"
 S comp=X?1.2(.1N,1.2P)
 d chk(1)
 ;
 ; w !," expr ? I.J (N. patatom, N patatom)"
 S X="012345678A9012BC345"
 S comp=X?3.10(5.N,4NA)
 d chk(1)
 ;
 ; w !," expr ? I.J (N. patatom, .N patatom)"
 S X="99999999999999999999999999999999999999999999999999999999999999999999999"
 S comp=X?10.200(2.AN,.5AN)
 d chk(1)
 ;
 ; w !," expr ? I.J (N. patatom, N. patatom)"
 S X="AAAAAAAA]]]]]]]]]]444444444]]]]]]]]]AA===4444444444\\\\\\0000000======"
 S comp=X?3.10(2.AN,4.P)
 d chk(0)
 ;
 ; w !," expr ? I.J (N. patatom, N.M patatom)"
 S X="AAAAAAAAAAAAAAAAAAAAKKKLLLLJG7GJFNFNFNFNBBBBBBBBBBBBBBBBBBBB"
 S comp=X?1.3(20.A,10.20NA)
 d chk(1)
 ;
 ; w !," expr ? I.J (N.M patatom, N patatom)"
 S X="HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH"
 S comp=X?3.6(2.4"H",5"HH")
 d chk(1)
 ;
 ; w !," expr ? I.J (N.M patatom, .N patatom)"
 S X=""
 S comp=X?4.9(3.10"+",.4N)
 d chk(1)
 ;
 ; w !," expr ? I.J (N.M patatom, N. patatom)"
 S X="12345HJKKLLL012345JIK0124abcd01245ABCDEF012345DDFFGDDFDFDF"
 S comp=X?9.20(4.6N,3.A)
 d chk(1)
 ;
 ; w !," expr ? I.J (N.M patatom, N.M patatom)"
 S X="012ASD34=34=34=34=34=AAAAAA34SDFSGD4566SG"
 S comp=X?3.9(3.7AN,3.9"34=")
 d chk(1)
 ;
 ;
 ; w !," expr ? repcount (patatom,patatom,patatom)"
 S X="123-45-567ABCDEFG3233---"
 S comp=X?4.(1.3A,1"-",2.N)
 d chk(1)
 ;
 ; w !," expr ? repcount (patatom,patatom,patatom,patatom,patatom)"
 S X="abcd1234-A-A-A-*ABCD12345-*-*-"
 S comp=X?5.7(2.NU,2."-A",2.P,2.L)
 d chk(1)
 ;
 ; w !," expr ? repcount (patatom,patatom,patatom,patatom,patatom,patatom)"
 S X="-1234-ab-AB-12-12"
 S comp=X?.4(.2"-12-",.3NA,.3NP,.2"-AB-",.3PL,1E)
 d chk(0)
 ;
 ;
 ; w !," expr ? repcount (...) repcount patcode"
 S X="-1-1*AB+-"
 S comp=X?2.4(.4AN,1.3AP,1E,2"-1")1.3P
 d chk(1)
 ;
 ; w !," expr ? repcount (...) repcount strlit"
 S X="1ABCD1E#####"
 S comp=X?2(.4AN,1.3AP,2."#")1.4"#"
 d chk(0)
 ;
 ; w !," expr ? repcount (...) repcount patcode repcount (...)"
 S X="AAABCCCCCCCCCCCBBBB BBBBAAAA 12  1AAAAABBBBCCC"
 S comp=X?.5(1."A",1."B",1."C")1.PN.5(1.NP,1."A",1."B",1."C")
 d chk(0)
 ;
 ; w !," expr ? repcount (...) repcount strlit  repcount (...)"
 S X="CCCCCCCCCCCAAAAAAABBBBBBBBBBBAAAAAAAAA   XY  BBBBCCCAAAAAAAAAAAA"
 S comp=X?.5(1."A",1."B",1."C")1" ".4(1."A",1."B",1."C",1.13AP)
 d chk(1)
 ;
 ; w !," expr ? repcount (...) repcount (...) repcount patcode"
 S X="*-=BBBBBB123A--="
 S comp=X?2.(.A,3.P)2.5(3A,2.NA,1P)3.4AP
 d chk(1)
 ;
 ; w !," expr ? repcount (...) repcount (...) repcount strlit"
 S X="1--ABabAAab  "
 S comp=X?1.3(.N,2"-",.2A).3(."AB",."ab",1"AA",1"ab")1.3" "
 d chk(1)
 ;
 ; w !," expr ? repcount (...) repcount (...) repcount (...)"
 S X="AB1212112 -12AAA1"
 S comp=X?9.(1.AN,.3PN)1(1"12",1"AB").2(1.3"A",.3AN)
 d chk(1)
 ;
 ;
 ; w !," expr ? repcount patcode repcount (...)"
 S X="     ABC456789"
 S comp=X?2.E2.(4.AN,4.N)
 d chk(1)
 ;
 ; w !," expr ? repcount strlit repcount (...)"
 S X="XY XY XY XY XY *"
 S comp=X?2."XY "3.(1"XY ",2A,1P)
 d chk(1)
 ;
 ; w !," expr ? repcount patcode repcount (...) repcount patcode"
 S X="ABABC**"
 S comp=X?2A.4(1.A,2.P).3P
 d chk(1)
 ;
 ; w !," expr ? repcount patcode repcount (...) repcount strlit"
 S X="ABCD475---ABCDE-------"
 S comp=X?2.NA.4(1.A,2.P).3"--"
 d chk(1)
 ;
 ; w !," expr ? repcount strlit repcount (...)  repcount patcode"
 S X="    =AB 12345"
 S comp=X?1." "4.(2A,2.P,1."=").N
 d chk(0)
 ;
 ; w !," expr ? repcount strlit repcount (...)  repcount strlit"
 S X="ABABABAB12341234AXAXAXAXAX"
 S comp=X?2."AB"2.7(.A,4N)2."AX"
 d chk(1)
 ;
 ;
 ; w !," expr '?"
 S X="AB1212112 -12AAA1"
 S comp=X'?9.(1.AN,.3PN)1(1"12",1"AB").2(1.3"A",.3AN)
 d chk(0)
 ;
 ; w !," multi alternation"
 S X="35646413231--AABABABABABABABABABabababAAA89-1-1879HJABABAB89909999AAAAAAAAAAACCCCCCCCCCCCCC AAAAAAAAABBBBBBBBBBBBB=----------="
 ;;S comp=X?1.3(.N,2"-",.2A).5(."AB",."ab",1"AA",1"ab")2.4(.4AN,1.3AP,1E,2"-1")4.(3.9"AB",3.5AN).5(1."A",1."B",1."C")1" ".4(1."A",1."B",1."C",1.13AP)
 ;;d chk(1)
 ;
 ; w !," nested patatom"
 S X="AAAAABBBBBBCCCCCCCBBBBBCCCCCCCCBBBBBBBAAAAAAABBBBBBBBBBBBBAAAAAACCCCCCABABABABABABAB345123ABABABABABABABABABABABABABAB123ABBBBBBCCCCCCCBBBBB"
 S comp=X?1.5(3.4(1."A",1."B",1."C"),2.(3.9"AB",3.5AN))
 d chk(1)
 q
 ;
chk(corr) ;q:comp=corr
 n o,p
 s h2=$h
 s dif=$$^difftime(h2,h1)
 s p=$st($st,"PLACE"),o=$p(p,"+",2)-1,p=$p(p,"+",1)_"+"_o_"^v"
 s p="s p=$t("_p_")" x p
 s h1=h2
 w !,X," ",p i comp=corr w " ok","   TIME: ",dif q
 w !,comp," ",corr," ",p,!,X,"   TIME: ",dif,!
 Q
