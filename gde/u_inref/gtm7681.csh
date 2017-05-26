#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-7681 : GDE add -name with * in name-space creates incorrect mappings of globals when a SHOW -NAME is done
#

cat << GDE_EOF > test01.gde
add -name zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz* -region=BREG
add -name zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz1 -region=AREG
add -name zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz2 -region=AREG
add -name zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz3 -region=AREG
GDE_EOF

cat << GDE_EOF > test02.gde
add -name XY -region=CREG
add -name XY1* -region=AREG
add -name XY2 -region=BREG
GDE_EOF

cat << GDE_EOF > test03.gde
add -name XY -region=CREG
add -name XY1 -region=AREG
add -name XY2 -region=BREG
GDE_EOF

cat << GDE_EOF > test04.gde
add -name XY1* -region=AREG
GDE_EOF

cat << GDE_EOF > test05.gde
add -name XY   -region=CREG
add -name XY1* -region=AREG
add -name XY2* -region=BREG
add -name XY3* -region=BREG
add -name XY4* -region=AREG
add -name XY5  -region=BREG
GDE_EOF

cat << GDE_EOF > test06.gde
add -name X*     -region=BREG
add -name XY     -region=CREG
add -name XY1*   -region=AREG
add -name XY2*   -region=AREG
add -name XY34*  -region=CREG
add -name XY4*   -region=AREG
add -name XY45*  -region=BREG
add -name XY456* -region=AREG
add -name XY5    -region=CREG
GDE_EOF

cat << GDE_EOF > test07.gde
add -name X*   -region=CREG
add -name XW*  -region=AREG
add -name XW2* -region=BREG
add -name XX*  -region=AREG
add -name XY*  -region=AREG
add -name XY2* -region=BREG
GDE_EOF

cat << GDE_EOF > test08.gde
add -name XW* -region=AREG
add -name XX* -region=BREG
add -name XY* -region=AREG
add -name XZ* -region=BREG
add -name Xa* -region=AREG
GDE_EOF

cat << GDE_EOF > test09.gde
add -name zu* -region=BREG
add -name zv* -region=AREG
add -name zw* -region=BREG
add -name zx* -region=AREG
add -name zy* -region=BREG
add -name zz* -region=AREG
GDE_EOF

cat << GDE_EOF > test10.gde
add -name aa* -region=BREG
add -name ab* -region=AREG
add -name ac* -region=AREG
add -name ad* -region=AREG
add -name ae* -region=BREG
add -name af* -region=CREG
add -name ag* -region=AREG
add -name ah* -region=AREG
add -name ai* -region=AREG
add -name aj* -region=BREG
add -name ak* -region=CREG
add -name al* -region=AREG
add -name am* -region=AREG
add -name an* -region=AREG
add -name ao* -region=BREG
add -name ap* -region=CREG
add -name aq* -region=AREG
add -name ar* -region=AREG
add -name as* -region=AREG
GDE_EOF

cat << GDE_EOF > test11.gde
add -name ag   -region=DREG
add -name ag*  -region=CREG
add -name aga* -region=DREG
add -name agb* -region=BREG
add -name agc* -region=BREG
add -name agd* -region=BREG
add -name age* -region=BREG
add -name agf* -region=BREG
add -name agg* -region=BREG
add -name agh* -region=BREG
add -name agi* -region=BREG
add -name agj* -region=BREG
add -name agk* -region=BREG
add -name agl* -region=BREG
add -name agm* -region=BREG
add -name agn* -region=BREG
add -name ago* -region=BREG
add -name agp* -region=BREG
add -name agq* -region=BREG
add -name agr* -region=BREG
add -name ags* -region=BREG
add -name agt* -region=BREG
add -name agu* -region=BREG
add -name agv* -region=BREG
add -name agw* -region=BREG
add -name agx* -region=AREG
add -name agx  -region=CREG
add -name agxb* -region=BREG
add -name agxc* -region=BREG
add -name agxd* -region=BREG
add -name agxe* -region=BREG
add -name agxf* -region=BREG
add -name agxg* -region=BREG
add -name agxh* -region=BREG
add -name agxi* -region=BREG
add -name agxj* -region=BREG
add -name agxk* -region=BREG
add -name agxl* -region=BREG
add -name agxm* -region=BREG
add -name agxn* -region=BREG
add -name agxo* -region=BREG
add -name agxp* -region=BREG
add -name agxq* -region=BREG
add -name agxr* -region=BREG
add -name agxs* -region=BREG
add -name agxt* -region=BREG
add -name agxu* -region=BREG
add -name agxv* -region=BREG
add -name agxw* -region=BREG
add -name agxx* -region=BREG
add -name agy* -region=AREG
add -name agz* -region=AREG
GDE_EOF

cat << GDE_EOF > test12.gde
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaag   -region=DEFAULT
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaag*  -region=AREG
show -name
GDE_EOF

cat << GDE_EOF > test13.gde
add -name ag  -region=DEFAULT
add -name ag* -region=AREG
add -name ah  -region=AREG
add -name ah* -region=DEFAULT
GDE_EOF

cat << GDE_EOF > test14.gde
add -name ag  -region=DEFAULT
add -name ag* -region=AREG
add -name ah  -region=AREG
add -name ah* -region=BREG
add -name ai  -region=BREG
add -name ai* -region=DEFAULT
GDE_EOF

cat << GDE_EOF > test15.gde
add -name ag  -region=DEFAULT
add -name ag* -region=AREG
add -name ah  -region=AREG
add -name ah* -region=AREG
add -name ai  -region=AREG
add -name ai* -region=DEFAULT
GDE_EOF

cat << GDE_EOF > test16.gde
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaag   -region=DEFAULT
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaag*  -region=CREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaaga* -region=DREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagb* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagc* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagd* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaage* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagf* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagg* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagh* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagi* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagj* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagk* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagl* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagm* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagn* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaago* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagp* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagq* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagr* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaags* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagt* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagu* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagv* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagw* -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagx* -region=AREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagx  -region=CREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxb -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxc -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxd -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxe -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxf -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxg -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxh -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxi -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxj -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxk -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxl -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxm -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxn -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxo -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxp -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxq -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxr -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxs -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxt -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxu -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxv -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxw -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagxx -region=BREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagy* -region=AREG
add -name aaaaaaaaaaaaaaaaaaaaaaaaaaaagz* -region=AREG
GDE_EOF

cat << GDE_EOF > test17.gde
add -name x1*   -region=AREG
add -name x123* -region=DEFAULT
GDE_EOF

cat << GDE_EOF > test18.gde
add -name x1*         -region=AREG
add -name x123*       -region=DEFAULT
add -name x12342*     -region=BREG
add -name x12345*     -region=BREG
add -name x1234567*   -region=CREG
add -name x12345678   -region=BREG
add -name x12345678*  -region=DEFAULT
add -name x123456789* -region=DEFAULT
add -name x12345679*  -region=CREG
GDE_EOF

cat << GDE_EOF > test19.gde
add -name ag*  -region=AREG
add -name agz  -region=AREG
add -name agz* -region=BREG
add -name ah*  -region=AREG
GDE_EOF

cat << GDE_EOF > test20.gde
add -name ag*  -region=AREG
add -name agz  -region=AREG
add -name agz* -region=BREG
GDE_EOF

cat << GDE_EOF > test21.gde
add -name agz  -region=AREG
add -name agz* -region=BREG
GDE_EOF

cat << GDE_EOF > test22.gde
add -name agz  -region=AREG
add -name agz* -region=AREG
GDE_EOF

cat << GDE_EOF > test23.gde
add -name agz* -region=AREG
GDE_EOF

cat << GDE_EOF > test24.gde
add -name ag*  -region=AREG
add -name agy  -region=AREG
add -name agy* -region=BREG
add -name agz* -region=BREG
add -name ah*  -region=BREG
add -name ai*  -region=BREG
add -name aj*  -region=BREG
add -name ajk* -region=AREG
GDE_EOF

cat << GDE_EOF > test25.gde
add -name ag*  -region=AREG
add -name ag0* -region=BREG
add -name ag1  -region=BREG
add -name agy  -region=AREG
add -name agy* -region=BREG
add -name agz* -region=BREG
add -name ah*  -region=BREG
add -name ai*  -region=BREG
add -name aj*  -region=BREG
add -name ajk* -region=AREG
GDE_EOF

cat << GDE_EOF > test26.gde
add -name ag*  -region=AREG
add -name ag0* -region=BREG
add -name ag1  -region=BREG
add -name agy  -region=AREG
add -name agy* -region=BREG
add -name agz* -region=BREG
add -name ah*  -region=BREG
add -name ai*  -region=BREG
add -name aj*  -region=BREG
add -name ajx* -region=AREG
add -name ajy* -region=AREG
add -name ajz* -region=AREG
add -name ak*  -region=AREG
GDE_EOF

cat << GDE_EOF > test27.gde
add -name xy1*         -region=AREG
add -name xy123*       -region=DEFAULT
add -name xy1234       -region=DEFAULT
add -name xy1234*      -region=BREG
add -name xy1234567*   -region=CREG
add -name xy12345678   -region=BREG
add -name xy12345678*  -region=DEFAULT
add -name xy123456789* -region=DEFAULT
add -name xy12345679*  -region=CREG
add -name xy2*         -region=AREG
add -name xy234*       -region=BREG
add -name xy3*         -region=AREG
GDE_EOF

cat << GDE_EOF > test28.gde
add -name xy1*         -region=AREG
add -name xy123*       -region=DEFAULT
add -name xy12340*     -region=BREG
add -name xy12341*     -region=BREG
add -name xy12342*     -region=BREG
add -name xy12343*     -region=BREG
add -name xy12344*     -region=BREG
add -name xy12345*     -region=BREG
add -name xy1234567*   -region=CREG
add -name xy12345678   -region=BREG
add -name xy12345678*  -region=DEFAULT
add -name xy123456789* -region=DEFAULT
add -name xy12345679*  -region=CREG
add -name xy12346*     -region=BREG
add -name xy12347*     -region=BREG
add -name xy12348*     -region=BREG
add -name xy12349*     -region=BREG
add -name xy1234A*     -region=BREG
add -name xy1234B*     -region=BREG
add -name xy1234C*     -region=BREG
add -name xy1234D*     -region=BREG
add -name xy1234E*     -region=BREG
add -name xy1234F*     -region=BREG
add -name xy1234G*     -region=BREG
add -name xy1234H*     -region=BREG
add -name xy1234I*     -region=BREG
add -name xy1234J*     -region=BREG
add -name xy1234K*     -region=BREG
add -name xy1234L*     -region=BREG
add -name xy1234M*     -region=BREG
add -name xy1234N*     -region=BREG
add -name xy1234O*     -region=BREG
add -name xy1234P*     -region=BREG
add -name xy1234Q*     -region=BREG
add -name xy1234R*     -region=BREG
add -name xy1234S*     -region=BREG
add -name xy1234T*     -region=BREG
add -name xy1234U*     -region=BREG
add -name xy1234V*     -region=BREG
add -name xy1234W*     -region=BREG
add -name xy1234X*     -region=BREG
add -name xy1234Y*     -region=BREG
add -name xy1234Z*     -region=BREG
add -name xy1234a*     -region=BREG
add -name xy1234b*     -region=BREG
add -name xy1234c*     -region=BREG
add -name xy1234d*     -region=BREG
add -name xy1234e*     -region=BREG
add -name xy1234f*     -region=BREG
add -name xy1234g*     -region=BREG
add -name xy1234h*     -region=BREG
add -name xy1234i*     -region=BREG
add -name xy1234j*     -region=BREG
add -name xy1234k*     -region=BREG
add -name xy1234l*     -region=BREG
add -name xy1234m*     -region=BREG
add -name xy1234n*     -region=BREG
add -name xy1234o*     -region=BREG
add -name xy1234p*     -region=BREG
add -name xy1234q*     -region=BREG
add -name xy1234r*     -region=BREG
add -name xy1234s*     -region=BREG
add -name xy1234t*     -region=BREG
add -name xy1234u*     -region=BREG
add -name xy1234v*     -region=BREG
add -name xy1234w*     -region=BREG
add -name xy1234x*     -region=BREG
add -name xy1234y*     -region=BREG
add -name xy1234z*     -region=BREG
add -name xy2*         -region=AREG
add -name xy234*       -region=BREG
add -name xy3*         -region=AREG
GDE_EOF

cat << GDE_EOF > test29.gde
add -name a234567890123456789012345678g*  -region=AREG
add -name a234567890123456789012345678gz  -region=AREG
add -name a234567890123456789012345678gz* -region=BREG
add -name a234567890123456789012345678h*  -region=AREG
GDE_EOF

cat << GDE_EOF >> 1reg_complete.gde
change -segment DEFAULT -file=mumps.dat
add -region areg -dyn=aseg
add -segment aseg -file=a
GDE_EOF

cat << GDE_EOF > 2reg_complete.gde
change -segment DEFAULT -file=mumps.dat
add -region areg -dyn=aseg
add -segment aseg -file=a
add -region breg -dyn=bseg
add -segment bseg -file=b
GDE_EOF

cat << GDE_EOF > 3reg_complete.gde
change -segment DEFAULT -file=mumps.dat
add -region areg -dyn=aseg
add -segment aseg -file=a.dat
add -region breg -dyn=bseg
add -segment bseg -file=b.dat
add -region creg -dyn=cseg
add -segment cseg -file=c.dat
GDE_EOF

cat << GDE_EOF > 4reg_complete.gde
change -segment DEFAULT -file=mumps.dat
add -region areg -dyn=aseg
add -segment aseg -file=a
add -region breg -dyn=bseg
add -segment bseg -file=b
add -region creg -dyn=cseg
add -segment cseg -file=c
add -region dreg -dyn=dseg
add -segment dseg -file=d
GDE_EOF

setenv gtmgbldir mumps.gld
foreach file (test*.gde)
	echo ""
	echo " ----------------------------------------------------------------------------"
	echo " --> Running GDE with input file $file"
	echo " ----------------------------------------------------------------------------"
	rm -f mumps.gld complete.gde
	# Find out the # of regions in $file. DEFAULT might be present or not in the add -name commands so ignore that in the region count.
	@ regcnt = `$grep "\-region=" $file | $tst_awk -F'=' '{print $2}' | sort -u | grep -vw DEFAULT | wc -l`
	echo "Using ${regcnt}_reg_complete.gde as input file for gde"
	ln -s ${regcnt}reg_complete.gde complete.gde
	# Test that GDE SHOW -NAME works for different kinds of * mappings (recorded in the test*.gde files)
	$GDE << GDE_EOF
	@$file
	show -name
	@complete.gde
	exit
GDE_EOF
	# Test that GDE SHOW -NAME works the same way when it needs to read the mapping from the .gld file
	# Also take this opportunity to check that the maps are also good
	$GDE << GDE_EOF
	show -name
	show -map
	quit
GDE_EOF

end
