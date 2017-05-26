! Test slightly fancy name specifications using ranges (which transform to minimal map entries) work
add -name X           -region=breg
add -name X(1)        -region=areg
add -name X(1,:10)    -region=areg
add -name X(1,10)     -region=areg
add -name X(1,10,:20) -region=areg
add -name X(1,10,20:) -region=breg
add -name X(1,10:)    -region=breg
!
! the map that gets created in the .gld for the above name specifications is the following
! X            <-- DEFAULT
! X(1)         <-- BREG
! X(1,10,20)   <-- AREG
! X)           <-- BREG
!
! To convert the map entries back to names let us start with the first subscripted map entry from the last.
! This is the 3rd map entry X(1,10,20). To convert it back to names, do the following.
! Add TWO names and replace one map entry with another.
!       X(1,10)     -region=AREG
!       X(1,10,20:) -region=BREG
!
! Resulting map is the below where one level of subscript in the 3rd map entry has been eliminated.
! The map that gets created is the following
! X            <-- DEFAULT
! X(1)         <-- BREG
! X(1,10)      <-- AREG
! X)           <-- BREG
!
! Do something similar to remove the next level of subscript
! Add TWO names and replace one map entry with another.
!       X(1)     -region=AREG
!       X(1,10:) -region=BREG
!
! Resulting map is the below where one level of subscript in the 3rd map entry has been eliminated.
! The map that gets created is the following
! X            <-- DEFAULT
! X(1)         <-- BREG
! X(1)         <-- AREG
! X)           <-- BREG
!
! At this point since the 3rd map entry became identical to the 2nd map entry (at the key level),
! the 3rd map entry can be removed completely. So resulting map is the following.
! X            <-- DEFAULT
! X(1)         <-- BREG
! X)           <-- BREG
!
! Now since two consecutive maps have identical regions, we can remove the first of the two.
! So resulting map is the following.
! X            <-- DEFAULT
! X)           <-- BREG
!
! And this map can be converted back to names using a simple transformation.
! Add ONE name and we are done.
!       X -region=BREG
!
! So we got a total of 5 names from the map entries.
!       X(1,10)     -region=AREG
!       X(1,10,20:) -region=BREG
!       X(1)     -region=AREG
!       X(1,10:) -region=BREG
!       X -region=BREG
!
! Note that X(1,10) (mapping to AREG) is a POINT specification that overrides the RANGE specification X(1,10:) (mapping to BREG).
!
! Also test that with the above name spaces provided as input to GDE (in ADD -NAME commands), the show -name output is the same.
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map

