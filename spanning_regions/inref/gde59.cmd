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

! Test case that Kishore came up with which exposed a bad assert
add -name PRODAGE("a10":"a20") -region=DECADE1
add -name PRODAGE("a20":) -region=DECADE2
add -name PRODAGE(20:) -r=D2
delete -name PRODAGE("a10":"a20")
add -name PRODAGE(20:) -r=D2
exit
add -region D2 -dyn=D2 -stdnullcoll
add -segment D2 -file=D2.dat
add -region DECADE2 -dyn=DECADE2 -stdnullcoll
add -segment DECADE2 -file=DECADE2.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
