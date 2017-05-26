#! /usr/local/bin/tcsh -f
#
# GTM Process starts
$GTM << xyz
d in2^dbfill("set")
f repeat=100:1:110 do in3^npfill("set",1,repeat) 
h
xyz
