template ~region ~stdnullcoll
change ~region DEFAULT ~stdnullcoll
!
! Setup the mapping
!
add ~gblname tamil ~coll=0
add ~reg tamil ~dyn=tamil
add ~reg vowels ~dyn=vowels
add ~reg consonants ~dyn=consonants
add ~seg tamil ~file=tamil.dat
add ~seg vowels ~file=vowels.dat
add ~seg consonants ~file=consonants.dat
! Add names with unicode subscripts
add ~name tamil("அ":"௺") ~reg=tamil
add ~name tamil($char(3047):$zchar(224,175,186)) ~reg=numbers
!add ~name tamil($char(2949):"௧") ~reg=noreg
add ~name tamil("க":$char(3001)) ~reg=consonants
show ~name
!	
! The below using unicode in the subscripts should work
!
change ~name tamil("அ":"க") ~reg=vowels
delete ~name tamil("௧":"௺")
rename ~name tamil($char(2965):$char(3001)) tamil("க":"வ")
show ~name tamil("அ":"க")
verify ~name tamil($char(2949):"க")
!
show ~name
