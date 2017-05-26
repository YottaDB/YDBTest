! The first two should error out
add ~gblname abcd1234$% ~collation=1
add ~gblname abcd123~$ ~collation=0
add ~gblname abcd1234  ~collation=1	!<-- should work fine
add ~gblname errorcoll ~collation=11	!<-- should error
add ~gblname abcd ~collation=0
add ~gblname abcd ~collation=1
!
add ~gblname efgh
add ~gblname abcd			! should we see OBJDUP over QUALREQD
!
change ~gblname abcd1234 ~collation=1	! should see OBJNOTCHG  not in test_plan.txt
change ~gblname abcd1234 ~collation=0
change ~gblname abcd1 ~collation=1
change ~gblname abcd1234
! 
delete ~gblname abcd1			! OBJNOTFND
delete ~gblname abcd
!
rename ~gblname abcd123 abcd123
rename ~gblname efgh abcd               ! OBJNOTFND
rename ~gblname abcd1234 abcd	
rename ~gblname abcd1234 efgh		! OBJNOTFND
rename ~gblname abcd abcd
!
show ~gblname abcd1234			! OBJNOTFND
show ~gblname abcd
show ~gblname
!show	! commented out for now. Probably have it at the end
! Test cases for verify
verify   ~gblname doesnotexist
add ~gblname efgh ~collation=400	! ACTRANGE
verify ~gblname abcd
verify ~gblname efgh
verify
add ~gblname efgh ~collation=255
add ~gblname efgh ~collation=256	! Expect OBJDUP over ACTRANGE
verify
show ~gblname				! Show collation 0 value too
show ~commands
!
! unicode characters in gblname should not work
! 
add ~gblname க ~coll=0
change ~gblname க ~coll=1
rename ~gblname க ka
rename ~gblname ka க
show ~gblname க
verify ~gblname க
delete ~gblname க
!	
