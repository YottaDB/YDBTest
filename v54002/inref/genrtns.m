;
; Generate a bunch of random routines plus a "main.m" that contains a ZBREAK for each
; routine generated, then does an unlink-all. Verifies S9L04-00xxxx is fixed.
;
genrtns	Set rtncnt=200
	Set alphanums="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	Set mainrtn="main.m"
	Open mainrtn:New
	For i=1:1:rtncnt Do
	. Set rtnnamlen=$Random(20)+2
	. Set rtnnam=$ZExtract(alphanums,$Random(26+1))
	. For j=2:1:rtnnamlen Do
	. . Set rtnnam=rtnnam_$ZExtract(alphanums,$Random(36)+1)
	. Use mainrtn
	. Write " ZBreak +1^",rtnnam,!
	. Set rtnnam=rtnnam_".m"
	. Open rtnnam:New
	. Use rtnnam
	. Write !,"Quit",!
	. Close rtnnam
	. Use $P
	Use mainrtn
	Write !
	Write " ZGoto 0:allgone^main",!
	Write " Quit",!
	Write !
	Write "allgone",!
	Write " Write ""Reached main restart point"",!",!
	Close mainrtn
	Do ^main
	Quit

