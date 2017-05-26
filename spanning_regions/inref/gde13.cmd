! Test case that used to fail before with Z(3,5) mapping to NREG showing up extraneously
add -name Z(1)      -region=MREG
add -name Z(1,2:)   -region=NREG
add -name Z(1:3)    -region=NREG
add -name Z(3)      -region=NREG
add -name Z(3,5,6)  -region=NREG
add -name Z(3,5,6:) -region=OREG
exit
add -region MREG -dyn=MREG -stdnullcoll
add -segment MREG -file=MREG.dat
add -region NREG -dyn=NREG -stdnullcoll
add -segment NREG -file=NREG.dat
add -region OREG -dyn=OREG -stdnullcoll
add -segment OREG -file=OREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
