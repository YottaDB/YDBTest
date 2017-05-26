#!/usr/local/bin/tcsh -f

# Setup
mkdir gtm7395_dummy_dir
chmod 0755 gtm7395_dummy_dir

# Test
$gtm_dist/mumps -run gtm7395
