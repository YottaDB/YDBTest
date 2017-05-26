;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This routine exists to create a series of directories to create a path that
; is exactly GTM_DIST_MAX_PATH long and one more directory that is
; GTM_DIST_MAX_PATH + 1 long. For test simplicity, the routine creates two
; symlinks to these maximum length directories.
;
; GTM_DIST_MAX_PATH is taken to be the platforms PATH_MAX - 50 bytes. Each
; directory name is no longer than the platform NAME_MAX. Both values are
; pulled using the platform's getconf utility via test/com_u/getconf.m.
;
; For whatever reason, AIX and HPUX needed an extra byte stripped off.
gtm7926maxpath
	set maxpath=$$^getconf("PATH_MAX")-49-($zversion["AIX")-($zversion["HP")
	set maxname=$$^getconf("NAME_MAX")
	set $ETRAP="zwrite $zstatus,plen,maxpath halt"
	set dirperms=493 ; Octal 755
	set path=$zdirectory
	; Loop to create the longest directory paths
	for i=97:1:121 do  quit:plen'<(maxpath-1)
	.	set path=path_$tr($justify("/",maxname)," ",$char(i))
	.	set plen=$length(path)
	; Truncate path to maxpath
	set $extract(path,maxpath,plen)="",plen=$length(path)
	; Create a script using the maximum path and one over the maximum path
	do gentestpaths(path,path_"0")
	quit

; Generate a script file to create directories with the maximum possible paths
; for GT.M. The test initially used symbolic links in place of actual paths, but
; due to the maximum symbolic link length of 1024 on XFS, the script optionally
; falls back to actual paths when ln fails
;   http://oss.sgi.com/archives/xfs/2004-01/msg01046.html - XFS limitation
gentestpaths(maxdist,overdist)
	set file="testpaths.csh"
	open file:newversion
	use file
	write "set max_dist=",maxdist,!
	write "set over_dist=",overdist,!
	write "mkdir -p ${max_dist}",!
	write "mkdir -p ${over_dist}",!
	write "ln -s ${max_dist} max_dist",!
	write "if (0 == $status) set max_dist=$PWD/max_dist",!   ; redefine max_dist now that the symlink worked
	write "ln -s ${over_dist} over_dist",!
	write "if (0 == $status) set over_dist=$PWD/over_dist",! ; redefine over_dist now that the symlink worked
	close file
	quit
