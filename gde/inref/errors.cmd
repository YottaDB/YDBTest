add ~name "a" ~reg=AREG
add ~name ~reg=AREG
! Test the missing double quotes
setgd ~file="mumps.gld
! The below tests space behavior
add ~name abcd~reg=AREG
add ~name abcd ~reg=AREG!abcd
! GTM-7693 - Test if GDE accepts ! if it is the only character in the line
!
! 
change ~region $DEFAULT ~
change ~region $DEFAULT ~abcd
change ~region $DEFAULT ~collation
change ~region $DEFAULT ~collation=A
change ~region $DEFAULT ~stdnullcoll=TRUE
change ~region $DEFAULT ~nostdnullcoll=FALSE
change ~region $DEFAULT ~dyn
change ~region $DEFAULT ~dyn=
change ~region $DEFAULT ~INST_FREEZE_ON_ERROR=FALSE
change ~region $DEFAULT ~noinst_freeze_on_error=TRUE
change ~region $DEFAULT ~journal
change ~region $DEFAULT ~journal=
change ~region $DEFAULT ~nojournal
change ~region $DEFAULT ~nojournal=before
change ~region $DEFAULT ~journal=before=TRUE
change ~region $DEFAULT ~nojournal=(before,allocation)
change ~region $DEFAULT ~nojournal=(before,auto)
change ~region $DEFAULT ~nojournal=buffer
change ~region $DEFAULT ~journal=(before,extension)
change ~region $DEFAULT ~nojournal=extension
change ~region $DEFAULT ~journal=file_name
change ~region $DEFAULT ~journal=(file=x.mjl,before)
change ~region $DEFAULT ~key
change ~region $DEFAULT ~key=1A
change ~region $DEFAULT ~null
change ~region $DEFAULT ~null=
change ~region $DEFAULT ~null=DEFAULT
change ~region $DEFAULT ~nonull=ALWAYS
change ~region $DEFAULT ~qdbrundown=true
change ~region $DEFAULT ~record_size
change ~region $DEFAULT ~record_size=
change ~region $DEFAULT ~record_size=TRUE
change ~region $DEFAULT ~record_size=1048577
change ~region $DEFAULT ~rec=512 ~key=300	! Should NOT work on VMS
!
!
change ~segment $DEFAULT ~access_method=USER
change ~segment $DEFAULT ~access_method=DEFAULT
