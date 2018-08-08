/****************************************************************
*								*
* Copyright 2013 Fidelity Information Services, Inc		*
*								*
* Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	*
* All rights reserved.						*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
package com.test.ji;

import java.util.HashSet;

/**
 * A set of (though currently only one) functions that have to do with generation of M-related constructs.
 */
public class M {
	private static HashSet<String> mVarNames = new HashSet<String>();

	public static String genVarName(boolean global) {
		StringBuilder builder = new StringBuilder();

		do {
			int length = 3 + (int)(Math.random() * 7);
			builder = new StringBuilder(length);

			if (global)
				builder.append("^");
			/* We have had test failures where the generated M variable name matches a java keyword
			 * (e.g. "try", "null" which are disallowed as variables in java code).
			 * To avoid such issues, we prefix a "z" to all variable names (which still keeps it a valid M name).
			 * This assumes no java keyword begins with "z".
			 */
			builder.append("z");
			for (int i = 0; i < length; i++)
				builder.append((char)(97 + (int)(Math.random() * 26)));
		} while (mVarNames.contains(builder.toString()));

		return builder.toString();
	}
}
