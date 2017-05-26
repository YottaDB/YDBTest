! Test range overlap error is not issued incorrectly.
add -name X(1:10) -region=AREG
add -name X(5:15) -region=AREG
! At this point the name is X(1:15) --> AREG. So I expect X(4:8) --> BREG to work
add -name X(4:8)  -region=BREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
