! Test maps where adjacent maps are ++ entries
!
! create map entries of the form X(1,2)++, X(1,3)++ and X(1,4)++ where all ++ entries are at the same level
add -name X(1,1:2) -reg=XREG
add -name X(1,2)   -reg=XREG
add -name X(1,2:3) -reg=YREG
add -name X(1,3)   -reg=YREG
add -name X(1,3:4) -reg=ZREG
add -name X(1,4)   -reg=ZREG
!
! create map entries of the form Y(1,2)++ and Y(3)++ where consecutive ++ map entries are at different levels (decreasing order)
add -name Y(1,:2) -reg=AREG
add -name Y(1,2)  -reg=AREG
add -name Y(1:3)  -reg=BREG
add -name Y(3)    -reg=BREG
!
! create map entries of the form Z(1,2)++ and Z(3,5,6)++ where consecutive ++ map entries are at different levels (increasing order)
add -name Z(1)      -reg=MREG
add -name Z(1,:2)   -reg=MREG	 ! this is actually redundant but good to test this gets removed in the SHOW -NAME output
add -name Z(1,2)    -reg=MREG
add -name Z(1,2:)   -reg=NREG
add -name Z(1:3)    -reg=NREG
add -name Z(3)      -reg=NREG
add -name Z(3,:5)   -reg=NREG    ! this is also redundant but good to test this gets removed in the SHOW -NAME output
add -name Z(3,5)    -reg=NREG
add -name Z(3,5,:6) -reg=NREG    ! this is also redundant but good to test this gets removed in the SHOW -NAME output
add -name Z(3,5,6)  -reg=NREG
add -name Z(3,5,6:) -reg=OREG
add -name Z(3,5:)   -reg=OREG
add -name Z(3:)     -reg=OREG
exit
add -region MREG -dyn=MREG -stdnullcoll
add -segment MREG -file=MREG.dat
add -region ZREG -dyn=ZREG -stdnullcoll
add -segment ZREG -file=ZREG.dat
add -region NREG -dyn=NREG -stdnullcoll
add -segment NREG -file=NREG.dat
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region OREG -dyn=OREG -stdnullcoll
add -segment OREG -file=OREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
add -region XREG -dyn=XREG -stdnullcoll
add -segment XREG -file=XREG.dat
add -region YREG -dyn=YREG -stdnullcoll
add -segment YREG -file=YREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
show -map -reg=OREG

