!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!								!
! Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	!
! All rights reserved.						!
!								!
!	This source code contains the intellectual property	!
!	of its copyright holder(s), and is made available	!
!	under a license.  If you do not know the terms of	!
!	the license, please stop and do not read further.	!
!								!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! This module is derived from FIS GT.M.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

template ~region ~stdnullcoll	! spanning regions requires Standard Null Collation enabled
change ~region DEFAULT ~stdnullcoll
add ~region AREG ~dyn=ASEG
add ~segment ASEG ~file=a.dat
add ~region BREG ~dyn=BSEG
add ~segment BSEG ~file=b.dat
add ~name A("abcd",1:) ~reg=AREG
add ~name A("efgh",:1) ~reg=AREG
add ~name A("ijkl",:) ~reg=BREG
add ~name B("ABCD",3:"abcd") ~reg=BREG
show ~name
rename ~name A("efgh","":1) B("ABCD",3)
rename ~name A("ijkl",:) B(:)
rename ~name B("ABCD",3:"abcd") A(1,2,3:)
show ~name
rename ~name A(1,2,3:) B("ABCD",3:"abcd")
rename ~name B("ABCD",3) A("efgh",:1)
show ~name
! TODO ~ In the below config, verify ^X(2) goes to AREG and ^Y(2) goes to BREG
add ~name X(:) ~region=AREG
add ~name X(2,:) ~region=BREG
add ~name Y(:) ~region=AREG
add ~name Y(2) ~region=BREG
! Test equivalence of 1 and 0.1E1 when specified in numeric form and if specified in string form
add ~name A("1") ~reg=AREG
add ~name A(1) ~reg=AREG	! Should throw %GDE-E-OBJDUP, Name A(1) already exists
add ~name A(0.1E1) ~reg=AREG	! Should throw %GDE-E-OBJDUP, Name A(1) already exists
add ~name A("0.1E1") ~reg=AREG	! "0.1E1" should be treated differently from 0.1E1 and so no OBJDUP error expected here
show ~name
! Test a range where left and right ends are identical is treated as a point and not a range
ADD ~NAME pointa(1:1)      ~REG=AREG
ADD ~NAME pointa(1:1.0E01) ~REG=BREG
ADD ~NAME pointa(1:10)     ~REG=BREG	! Should throw GDE-E-OBJDUP, Name pointa(1:10) already exists
ADD ~NAME pointa(1:0.1E01) ~REG=AREG	! Should throw GDE-E-OBJDUP, Name pointa(1) already exists
! Strings and numeric subscripts
add ~name PRODAGE(0:10) ~region=DECADE0
add ~name PRODAGE(10:20) ~region=DECADE1
add ~name PRODAGE(20:30) ~region=DECADE2
show ~name
add ~name PRODAGE("") ~region=DEFAULT
add ~name PRODAGE(:10) ~region=DECADE0
add ~name PRODAGE(10:20) ~region=DECADE1
add ~name PRODAGE(20:) ~region=DECADE2
show ~name
add ~name PRODAGE(:"10") ~region=DECADE0
add ~name PRODAGE(10:"20") ~region=DECADE1
add ~name PRODAGE("10":"20") ~region=DECADE1
add ~name PRODAGE("100":"120") ~region=DECADE0
add ~name PRODAGE("20":) ~region=DECADE2
show ~name
add ~region DECADE0 ~dyn=DECADE0SEG
add ~segment DECADE0SEG ~file=decade0.dat
add ~region DECADE1 ~dyn=DECADE1SEG
add ~segment DECADE1SEG ~file=decade1.dat
add ~region DECADE2 ~dyn=DECADE2SEG
add ~segment DECADE2SEG ~file=decade2.dat
