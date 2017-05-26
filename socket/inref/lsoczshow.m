;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lsoczshow(path)
	; Check ZSHOW "D" output for UNIX sockets
	If '$d(path) Set path="local.sock"
	Set socdev="socdev"
	Open socdev:::"SOCKET"
	Write "Testing ZSHOW ""D"" for UNIX sockets",!
	Open socdev:(LISTEN=path_":LOCAL":attach="listen":new):1:"SOCKET"
	Else  Write "FAIL: Open listen at "_$ZPOS_" failed",! Halt
	Open socdev:(CONNECT=path_":local":attach="connect"):1:"socket"
	Else  Write "FAIL: Open connect at "_$ZPOS_" failed",! Halt
	Use socdev Write /WAIT(10) Set newhandle=$piece($key,"|",2) Use 0
	Set foundpathlisten=$$^pathcheck(path,"listen")
	Write "Listening socket shown on "_foundpathlisten,!
	Set foundzpathlisten=$$zpathcheck^pathcheck(socdev,path,"listen")
	If foundzpathlisten'=foundpathlisten Write "FAIL: mismatch foundzpathlisten = "_foundzpathlisten,!
	Set index("listen")=$zsocket(socdev,"INDEX","listen")
	Write:index("listen")'=0 "FAIL: Listening socket not index 0",!
	Set foundpathconnect=$$^pathcheck(path,"connect")
	Write "Connected socket shown on "_foundpathconnect,!
	Set foundzpathconnect=$$zpathcheck^pathcheck(socdev,path,"connect")
	If foundzpathconnect'=foundpathconnect Write "FAIL: mismatch foundzpathconnect = "_foundzpathconnect,!
	Set index("connect")=$zsocket(socdev,"INDEX","connect")
	Write:index("connect")'=1 "FAIL: Connected socket not index 1",!
	Set foundpathaccepted=$$^pathcheck(path,newhandle)
	Write "Accepted socket shown on "_foundpathaccepted,!
	Set foundzpathaccepted=$$zpathcheck^pathcheck(socdev,path,newhandle)
	If foundzpathaccepted'=foundpathaccepted Write "FAIL: mismatch foundzpathaccepted = "_foundzpathaccepted,!
	Set index(newhandle)=$zsocket(socdev,"INDEX",newhandle)
	Write:index(newhandle)'=2 "FAIL: Accepted socket not index 2",!
