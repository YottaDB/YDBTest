!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!								!
! Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	!
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

change ~segment DEFAULT ~file=locksmutexdefault.dat
add ~name A ~reg=AREG
add ~region AREG ~key_size=1019 ~dyn=ASEG
add ~segment ASEG ~acc=BG ~block_size=65024 ~file=locksmutexa.dat
add ~name B ~reg=BREG
add ~region BREG ~key_size=512 ~dyn=BSEG
add ~segment BSEG ~acc=MM ~block_size=5120 ~file=locksmutexb.dat
change ~segment ASEG ~lock=262145
change ~segment ASEG ~lock=262144
change ~segment BSEG ~lock=12345
change ~segment DEFAULT ~mutex_slots=2048
change ~segment ASEG ~mutex_slot=63
change ~segment ASEG ~mutex_slot=64
change ~segment BSEG ~mutex=32769
change ~segment BSEG ~mutex=32768
change ~segment DEFAULT ~reserved_bytes=921	! Assuming default blocksize 1024  & keysize 64, the max reserved_bytes = 1024-64-40=920
change ~segment DEFAULT ~reserved_bytes=920
change ~segment ASEG ~reserved_b=63966		! max reserved_bytes = 65024-1019-40 = 63965
change ~segment ASEG ~reserved_b=63965
change ~segment BSEG ~res=4569			! max reserved_bytes = 5120-512-40 = 4568
change ~segment BSEG ~res=4568
