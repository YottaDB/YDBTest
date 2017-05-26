add ~name A ~reg=AREG	! more regions to make sure a change to one region doesn't change TEMPLATE
add ~region AREG ~dyn=ASEG
add ~segment ASEG ~file=a.dat ~acc=BG
add ~name B ~reg=BREG
add ~region BREG ~dyn=BSEG		
add ~ segment BSEG ~ file = "b.dat" ~acc=BG	! Spaces are intentional
change ~region AREG ~collation=1	! randomize between 0-255
change ~region BREG ~nostdnullcoll
change ~region AREG ~stdnullcoll
change ~region AREG ~INST_FREEZE_ON_ERROR
change ~region BREG ~noinst_freeze_on_error
change ~region AREG ~journal=alloc=200 		! randomize between 200-8388607 (8388607 is limit of autoswitchlimit)
change ~region AREG ~journal=autoswitch=32768	! randomize between 16384-8388607
change ~region AREG ~journal=buffer=32768		! randomize between 2307-32768
change ~region AREG ~journal=before
change ~region BREG ~journal=nobefore_image
change ~region AREG ~journal=extension=100		! randomize between 1-1073741823
change ~region BREG ~journal=file_name=x.mjl
change ~region AREG ~journal=file_name=abcd-efgh=ijkl/?ijk!a(.)bc
change ~region AREG ~key_size=256			! randomize between 3-1019 (but max is record_size - 40)
change ~region AREG ~null_subscripts=ALWAYS	! randomize never,false,always,true,existing
change ~region AREG ~qdbrundown
change ~region AREG ~record_size=512		! randomize between 7-1048576 (should be greater than key_size+40)
