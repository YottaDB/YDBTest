; C9J05-009999 - dbg mode (UNIX) $ZSEARCH fails if given a non-existant directory.
;	         This test will not create any output unless it fails. Note the
;		 bogus TR # is because this is dbg only so has no customer effect.

	Set x=$ZSearch("/dir/does/not/exist/")
	Quit
