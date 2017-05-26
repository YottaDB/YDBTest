BEGIN {
        tst_dir = ENVIRON[ "tst_dir" ]
        gtm_tst_out = ENVIRON[ "gtm_tst_out" ]
	gtm_exe = ENVIRON[ "gtm_exe" ]
	tst_host = ENVIRON[ "tst_host" ]
    }
               {
                 gsub(/##TEST_PATH##/, ""tst_dir"/"gtm_tst_out"")
		 gsub(/##SOURCE_PATH##/, ""gtm_exe"")
		 gsub(/##TEST_HOST##/, ""tst_host"")
	         print
               }
