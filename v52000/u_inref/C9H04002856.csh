#!/usr/local/bin/tcsh
#
# C9H04-002856 INVSVN error is accompanied with GTMASSERT emit_code.c line 1110 in V52000A
#
$gtm_dist/mumps $gtm_tst/$tst/inref/c002856.m
#
# Test that a .o file has been generated
#
ls -1 c002856.o
