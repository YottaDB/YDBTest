; -----------------------------------------------------------------------------------------------
;             Trigger definitions for SETs and KILLs in replwason.m
; -----------------------------------------------------------------------------------------------

+^a(jobindex=:,i=:)   -commands=SET,KILL -xecute="do trig1^replwason"
+^b(jobindex=:,i=:)   -commands=SET,KILL -xecute="do trig1^replwason"
+^c(jobindex=:,i=:)   -commands=SET,KILL -xecute="do trig1^replwason"

+^aps(i=:)            -commands=SET,KILL -xecute="do trig2^replwason"
+^bps(i=:)            -commands=SET,KILL -xecute="do trig2^replwason"
+^cps(i=:)            -commands=SET,KILL -xecute="do trig2^replwason"

