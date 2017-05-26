! Test NAMRANGEOVERLAP error with control-characters in the name
add -name MODELNUM("":"z"_$char(0)) -region=STRING1
add -name MODELNUM("z":"zzzz"_$char(1)) -region=STRING2
exit

