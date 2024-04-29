#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

# Make output the same under GT.M and YDB
setenv ydb_prompt 'GTM>'
setenv ydb_msgprefix "GTM"

echo '# Test that external commands returning a NULL pointer instead of a string raise XCRETNULLREF errors.'

cat > ret.c << EOF
  #include <libyottadb.h>

  char* nullptr(int _nargs)            { return 0; }
  char** nullptrptr(int _nargs)        { char**cpp=ydb_malloc(sizeof(char*)); *cpp=0; return cpp; }
  ydb_string_t* nullstring(int _nargs) { ydb_string_t* s=ydb_malloc(sizeof(ydb_string_t)); s->address=0; return s; }
  ydb_buffer_t* nullbuffer(int _nargs) { ydb_buffer_t* b=ydb_malloc(sizeof(ydb_buffer_t)); b->buf_addr=0; return b; }

  ydb_string_t* negstring(int _nargs)  { ydb_string_t* s=ydb_malloc(sizeof(ydb_string_t));
    s->address=""; s->length=-1;
    return s;
  }

  ydb_buffer_t* negbuffer(int _nargs)  { ydb_buffer_t* b=ydb_malloc(sizeof(ydb_buffer_t));
    b->buf_addr=""; b->len_alloc=0; b->len_used=-1;
    return b;
  }
EOF

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist ret.c -o ret_obj.o
$gt_ld_shl_linker ${gt_ld_option_output}ret${gt_ld_shl_suffix} $gt_ld_shl_options ret_obj.o $gt_ld_syslibs


setenv GTMXC_ret ret.xc
echo "`pwd`/ret${gt_ld_shl_suffix}" > $GTMXC_ret
cat >> $GTMXC_ret << EOF
  nullptr: char* nullptr()
  nullptrptr: char** nullptrptr()
  nullstring: ydb_string_t* nullstring()
  negstring: ydb_string_t* negstring()
  nullbuffer: ydb_buffer_t* nullbuffer()
  negbuffer: ydb_buffer_t* negbuffer()
EOF

$GTM << EOF
  write "Returning NULL char*: ",\$&ret.nullptr()
  write "Returning NULL in char**: ",\$&ret.nullptrptr()
  write "Returning NULL in ydb_string_t: ",\$&ret.nullstring()
  write "Returning NULL in ydb_buffer_t: ",\$&ret.nullbuffer()
EOF

echo
echo '# Test that external commands returning a negative string length raise ZCCONVERT errors.'

$GTM << EOF
  write "Returning negative ydb_string_t length: ",\$&ret.negstring()
  write "Returning negative ydb_buffer_t length: ",\$&ret.negbuffer()
EOF
