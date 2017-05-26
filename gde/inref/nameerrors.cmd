template ~region ~stdnullcoll	! spanning regions requires Standard Null Collation enabled
change ~region DEFAULT ~stdnullcoll
add ~region AREG ~dyn=ASEG
add ~segment ASEG ~file=a.dat
add ~region BREG ~dyn=BSEG
add ~segment BSEG ~file=b.dat
add ~namebcd
add namebcd
add ~name b*(1:10) ~region=breg
ADD ~NAME b*(1,2) ~REG=BREG
add ~name b(1,1:10,2) ~reg=breg
add ~name b(1,1:10,2:20) ~region=breg
add ~name b(1,"1:10",2:20) ~region=breg
add ~name b(1,"a":,:20) ~region=breg
add ~name b(1,2,4:5:6:7) ~reg=breg
! The below commands shoud throw %GDE-E-NAMSUBSBAD (some commands with valid minor changes should work)
add ~name a(1,2) ~reg=AREG		! Should work
add ~name a(-000000004.0) ~reg=AREG	! Should work
add ~name a(1.2abcd) ~reg=AREG
ADD ~NAME A(1234abcd) ~REG=AREG
ADD ~NAME A("1234abcd") ~REG=AREG	! Should work
add ~name a(-+-+2) ~reg=AREG		! Should work
add ~name a(abcd) ~reg=AREG
add ~name a(---++abcd) ~reg=AREG
add ~name a(----++1E20a) ~reg=AREG
add ~name a(----++1E20+c) ~reg=AREG
add ~name a(1E+) ~reg=AREG
add ~name a(1E-) ~reg=AREG
add ~name a(1E+2) ~reg=AREG		! Should work
add ~name a(1E-20) ~reg=AREG		! Should work
add ~name a(1.) ~reg=AREG		! Should work
add ~name a(1.a) ~reg=AREG
add ~name a(.) ~reg=AREG
add ~name a(----++1E20+abcd,1E20) ~reg=AREG
add ~name a(1E20,----++1E20,1E20) ~reg=BREG
! The below should fail with %GDE-E-NAMNUMSUBNOTEXACT
add -name a(1E-43) -reg=AREG	! This should work, but the next one shouldn't
add -name a(1E-44) -reg=AREG
add ~name a(1E20,----++1E20+,1E20) ~reg=AREG
add -name a(1E-100,----++1E20,1E20) -reg=AREG
add -name a(1E-20,----++1E20,1E20) -reg=AREG	! Should work
change -name a(1E-20,1E20,1E+20) -reg=BREG	! Should work
change -name a(1E-20,1E20,1234567890123456789E+20) -reg=AREG
add -name a(1E-20,1E20,123456789012345678E+20) -reg=AREG
add -name a(1E-20,1234567890123456789E-20,20) -reg=AREG
add -name a1(1234567890.1234567800E-20) -reg=AREG ! Should work
add -name a1(1234567890.12345678100E-20) -reg=AREG
add -name a1(1234567890.1234567810E-20) -reg=AREG
add -name a1(1234567890.123456781E-20) -reg=AREG
add -name a(12345678901234567890123456789012345678901234567) -reg=AREG
add -name a(.0000000000000000000000000000000000000000012345678901234567800) -reg=BREG
change -name a(.000000000000000000000000000000000000000001234567890123456780) -reg=AREG !additional 0
! the additional 00s in the above and the below is the same. should issue OBJDUP
add -name a(.00000000000000000000000000000000000000000123456789012345678) -reg=AREG
add -name a(.000000000000000000000000000000000000000000123456789012345678) -reg=AREG
! The below two exceeds the limit and should error with NAMNUMSUBNOTEXACT
add -name a(.000000000000000000000000000000000000000001234567890123456789) -reg=AREG
add -name a(.0000000000000000000000000000000000000000000123456789012345678) -reg=AREG
!
! All the below are 234. So rest of them should throw %GDE-E-OBJDUP, Name a(234) already exists
add ~name a(234) ~reg=AREG
add ~name a(00234) ~reg=AREG
add ~name a(--234) ~reg=AREG
add ~name a(+234) ~reg=AREG
add ~name a(234.0) ~reg=AREG
add ~name a(234.0000) ~reg=AREG
add ~name a(234.000000000000001) ~reg=AREG	! This is not 234. so should work
add ~name a(234.0E-10) ~reg=AREG		! Should work
! The below command should throw %GDE-E-NAMSUBSEMPTY error
add ~name a(234,,2) ~reg=AREG
! Every other command should throw %GDE-E-NAMNUMSUBSOFLOW, Subscript #1 with value XXX in name specification has a numeric overflow
add ~name a(1E20) ~reg=AREG
add ~name a(1E100) ~reg=AREG
add ~name a(1234567890.12345678E-20) ~reg=AREG
add ~name a(123456789012345678901234567890123456789012345678) ~reg=AREG
add ~name a(12345678901234567800000000000000000000000000000) ~reg=AREG
add ~name a(123456789012345678000000000000000000000000000000) ~reg=AREG
add ~name a(1E46) ~reg=AREG
add ~name a(1E47) ~reg=AREG
! Some Parenthesis related errors
! %GDE-E-NAMRPARENMISSING, Subscripted Name specification xxx is missing one or more right-parens at the end of subscripts
ADD ~NAME A(1,2(3,4) ~REG=AREG
ADD ~NAME A(1,2,3 ~REG=AREG
ADD ~NAME A(1,2,3, ~REG=AREG
ADD ~NAME A(1,2,"abcd efgh", ~REG=AREG
! %GDE-E-NAMLPARENNOTBEG, Subscripted Name specification xxx needs to have a left-paren at the beginning of subscripts
ADD ~NAME A2) ~REG=AREG
ADD ~NAME A2: ~REG=AREG
! %GDE-E-NAMRPARENNOTEND, Subscripted Name specification xxx cannot have anything following the right-paren at the end of subscripts
ADD ~NAME A(1,2)) ~REG=AREG
ADD ~NAME A(1,2):) ~REG=AREG
! %GDE-E-NAMSUBSBAD, Subscript #1 with value xxx in name specification is an invalid number or string
ADD ~NAME A(1(2,3)4:5) ~REG=AREG
ADD ~NAME A(1,(2,3)4:5) ~REG=AREG
ADD ~NAME A(1,(2,3),4) ~REG=AREG
! %GDE-E-NAMGVSUBSMAX, Subscripted Name specification xxx has more than the maximum # of subscripts (31)
ADD ~NAME A(1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1)   ~reg=AREG
ADD ~NAME A(1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2) ~reg=AREG
! Some Quote related errors
add ~name a(" ~reg=AREG
add ~name a(" "" "" ") ~reg=AREG
add ~name a(" "" "" "") ~reg=AREG
add ~name DIVISION("USA","Northeast,Southeast","a":"h") ~region=AREG
change ~name DIVISION("USA","Northeast"_$c(44)_"Southeast","a":"h") ~region=BREG
! Range issues
add ~Name X(1:10) ~reg=AREG
add ~Name X(6:15) ~reg=BREG	! This is overlapping range and should throw GDE-E-NAMRANGEOVERLAP
add ~name X(8:20) ~reg=AREG
add ~Name X(6:15) ~reg=BREG	! This is no longer overlapping ranges and should work
add ~name y(1:5)   ~reg=AREG
add ~name y(10:15) ~reg=AREG
add ~name y(20:25) ~reg=AREG
add ~name y(30:35) ~reg=AREG
add ~name y(4:31)  ~reg=AREG
add ~name y(14:21) ~reg=BREG	! This no longer overlapping ranges and should work
! Even though ranges intersect, it should not error because they map to same region
ADD ~NAME A(1,2:4)  ~reg=AREG
ADD ~NAME A(1,5:10) ~reg=AREG
ADD ~NAME A(1,3:7)  ~reg=AREG
! ranges in different subscript, though overlaps should work fine.
ADD ~NAME A(1:10) ~reg=AREG
ADD ~NAME A(3,1:20) ~reg=BREG
! Status check of names till this point
show ~name
! Tests for bad string subscript specifications (including using $) 
ADD ~NAME A(1,"abcd) ~REG=AREG
ADD ~NAME A(1,"abcd"_) ~REG=AREG
ADD ~NAME A(1,"abcd"_efgh) ~REG=AREG
ADD ~NAME A(1,"abcd"_$) ~REG=AREG
ADD ~NAME A(1,"abcd"_$a) ~REG=AREG
ADD ~NAME A(1,"abcd"_$3) ~REG=AREG
ADD ~NAME A(1,"abcd"_$0) ~REG=AREG
ADD ~NAME A(1,"abcd"_$3() ~REG=AREG
ADD ~NAME A(1,"abcd"_$3()) ~REG=AREG
ADD ~NAME A(1,"abcd"_$C(57)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$CH(57)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$CHA(57)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$CHAr(57)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$CHARA(57)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$Z(57)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$ZC(57)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$ZCH(57)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$ZCHA(57)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$zChAR(57)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$ZCHARA(57)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$C(50000)) ~REG=AREG	!--> should give GDE-E-NAMSTRSUBSCHARG error in M mode, but work fine in UTF8 mode
ADD ~NAME A(1,"abcd"_$C(500000000000000000023)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$C(5E400)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$C(5E1)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$C(5000000000000000000000000000000000000000000000000000000000000000000000000023)) ~REG=AREG
ADD ~NAME A(1,"abcd"_$C("50")) ~REG=AREG
ADD ~NAME A(1,"ab""_""cd") ~REG=AREG
! Collation related errors
! Keywords are deliberately not in full
add ~name yy(10:1) ~reg=areg
add ~name yy("abcd":1) ~reg=areg
add ~name yy("abcd":"A") ~reg=areg
ad ~gblname xx ~coll=1
add ~gblname yy ~coll=99
a ~n xx("a":"g") ~r=areg
ad ~na xx("h":"l") ~re=breg
a ~name xx(1:"D") ~reg=BREG
a ~name yy("g":"a") ~regi=areg
a ~nam yy("l":"h") ~regio=breg
a ~name yy(1:"D") ~reg=BREG
add ~name yy(10:1) ~reg=areg
add ~name yy("abcd":1) ~reg=areg
add ~name yy("abcd":"F") ~reg=areg
chan ~g yy ~c=1
change ~gbl yy ~coll=3
c ~gblname xx ~coll=99
show ~gblname
show ~name	! Should show the ranges in collation order, especially gbl yy
! All the below should fail with GDE-E-NAMRANGEORDER
add ~name yy("y":"z") ~region=noreg
add ~na xx("Z":"Y") ~region=noreg
change ~name yy("abcd":"A") xx("abcd":"A")	! This one with syntax error
change ~name yy("a":"g") ~region=areg
rename ~name yy("abcd":"A") xx("abcd":"A")
delete ~name xx("G":"A")
delete ~name yy("G":"M")
add ~gblname p ~col=1
add ~gblname pol ~coll=9	! polish collation a,A,b,B,c,C...
add ~name p("a":"c") ~region=areg
add ~name p("A":"C") ~region=breg
add ~name pol("a":"h") ~region=areg
add ~name pol("p":"z") ~region=breg
! a:c and A:C nomally does not overlap. But in polish collation it does. Expect it to error when collation changes
change ~gblname p ~coll=9
delete ~gblname p
add ~gblname p ~col=9
add ~name pol("G":"P") ~region=creg
!
! The below commands using unicode characters in the name should not work
!
add ~name க("அ":"௺") ~reg=tamil
change ~name க("a":"z") ~region=DEFAULT
delete ~name க("அ":"ஔ")
rename ~name க("க":"வ") k("க":"ஹ")
show ~name ம("அ":"ஔ")
verify ~name ம("அ":"ஔ")
!
