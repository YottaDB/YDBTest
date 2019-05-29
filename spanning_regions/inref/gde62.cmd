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

! Slight variation of gde59.cmd
add -name PRODAGE("a10":"a20") -region=DECADE1
add -name PRODAGE("a30":) -region=DECADE3
add -name PRODAGE(20:) -r=D2
delete -name PRODAGE("a10":"a20")
exit
add -region D2 -dyn=D2 -stdnullcoll
add -segment D2 -file=D2.dat
add -region DECADE3 -dyn=DECADE3 -stdnullcoll
add -segment DECADE3 -file=DECADE3.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
