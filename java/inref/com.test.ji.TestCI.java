/****************************************************************
 *								*
 * Copyright (c) 2013-2015 Fidelity National Information 	*
 * Services, Inc. and/or its subsidiaries. All rights reserved.	*
 *								*
 * Copyright (c) 2017-2021 YottaDB LLC and/or its subsidiaries. *
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
package com.test.ji;

import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;

/**
 * The class generating all GTMJI test cases. All tests roughly follow the same template for M
 * and Java files; for more details, please refer to the comments within the TestCase class.
 */
public class TestCI {
	private static String destDir;

	/*
	 * Test 1: Try all basic argument and return types.
	 */
	public static void getTest1() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.BASIC_ARG_TYPES_LENGTH * GTMType.BASIC_CALLIN_RET_TYPES_LENGTH * GTMType.DIRECTIONS_LENGTH];
		int testCasesIndex = 0;

		for (int dirIndex = 0; dirIndex < GTMType.DIRECTIONS_LENGTH; dirIndex++) {
			final int direction = GTMType.DIRECTIONS[dirIndex];

			for (int argIndex = 0; argIndex < GTMType.BASIC_ARG_TYPES_LENGTH; argIndex++) {
				for (int retIndex = 0; retIndex < GTMType.BASIC_CALLIN_RET_TYPES_LENGTH; retIndex++) {
					final String argValue;
					final String argInit;
					final String expValue;
					final int argType = GTMType.BASIC_ARG_TYPES[argIndex];
					boolean error = false;
					boolean isZero;

					switch (argType) {
					case GTMType.GTM_BOOLEAN:
						boolean booleanValue = TestCommon.rand.nextBoolean();
						argValue = booleanValue + "";
						argInit = J.genArgInit("x", "GTMBoolean", argValue);
						expValue = (direction != GTMType.OUTPUT_ONLY) ? argValue : "true";
						break;
					case GTMType.GTM_INTEGER:
						int intValue = TestCommon.rand.nextInt();
						argValue = intValue + "";
						argInit = J.genArgInit("x", "GTMInteger", argValue);
						if (direction == GTMType.INPUT_ONLY)
							expValue = argValue;
						else if (direction == GTMType.INPUT_OUTPUT)
							expValue = (intValue / 10) + "";
						else
							expValue = "123";
						break;
					case GTMType.GTM_LONG:
						long longValue;
						while (Math.abs((longValue = TestCommon.rand.nextLong())) >= 1E18);
						argValue = longValue + "";
						argInit = J.genArgInit("x", "GTMLong", argValue + "l");
						if (direction == GTMType.INPUT_ONLY)
							expValue = argValue;
						else if (direction == GTMType.INPUT_OUTPUT)
							expValue = (longValue / 10) + "";
						else
							expValue = "123";
						break;
					case GTMType.GTM_FLOAT:
						float floatValue = TestCommon.rand.nextFloat();
						if (floatValue < TestCommon.M_MIN) {
							isZero = true;
							argValue = "0";
						} else {
							isZero = false;
							argValue = TestCommon.F5.format(floatValue);
						}
						argInit = J.genArgInit("x", "GTMFloat", argValue + "f");
						if (direction == GTMType.INPUT_ONLY)
							expValue = isZero ? ".0" : argValue;
						else if (direction == GTMType.INPUT_OUTPUT)
							expValue = TestCommon.F6.format(Float.parseFloat(argValue) / 10);
						else
							expValue = "123.0";
						break;
					case GTMType.GTM_DOUBLE:
						assert(argType == GTMType.GTM_DOUBLE);
						double doubleValue = ((direction != GTMType.OUTPUT_ONLY) && (TestCommon.rand.nextInt(100) == 0)) ? Double.MAX_VALUE : TestCommon.rand.nextDouble();
						if (doubleValue >= TestCommon.M_LIMIT) {
							error = true;
							argValue = doubleValue + "";
							argInit = J.genArgInit("x", "GTMDouble", argValue);
							expValue = "150373506,(Call-In),%YDB-E-NUMOFLOW, Numeric overflow\n";
						} else {
							if (doubleValue < TestCommon.M_MIN) {
								isZero = true;
								argValue = "0";
							} else {
								isZero = false;
								argValue = TestCommon.D14.format(doubleValue);
							}
							argInit = J.genArgInit("x", "GTMDouble", argValue);
							if (direction == GTMType.INPUT_ONLY)
								expValue = isZero ? ".0" : argValue;
							else if (direction == GTMType.INPUT_OUTPUT)
								expValue = TestCommon.D15.format(Double.parseDouble(argValue) / 10);
							else
								expValue = "123.0";
						}
						break;
					default:
						argInit = null;
						argValue = null;
						expValue = null;
					}

					final String retValue;
					int retType = GTMType.BASIC_CALLIN_RET_TYPES[retIndex];
					final String retTypeWord = GTMType.ALL_CALLIN_RET_TYPE_WORDS[retIndex];

					switch (retType) {
					case GTMType.VOID:
						retValue = "";
						break;
					case GTMType.GTM_BOOLEAN:
						retValue = TestCommon.rand.nextBoolean() ? "1" : "0";
						break;
					case GTMType.GTM_INTEGER:
						retValue = TestCommon.rand.nextInt() + "";
						break;
					case GTMType.GTM_LONG:
						long value;
						while (Math.abs((value = TestCommon.rand.nextLong())) >= 1E18);
						retValue = value + "";
						break;
					case GTMType.GTM_FLOAT:
						float floatValue = TestCommon.rand.nextFloat();
						if (floatValue < TestCommon.M_MIN)
							floatValue = 0;
						retValue = TestCommon.F6.format(floatValue);
						break;
					case GTMType.GTM_DOUBLE:
						double doubleValue = TestCommon.rand.nextDouble();
						if (doubleValue < TestCommon.M_MIN)
							doubleValue = 0;
						retValue = TestCommon.D15.format(doubleValue);
						break;
					default:
						retValue = null;
					}

					final boolean doesError = error;

					testCases[testCasesIndex++] = new TestCase("Test1", TestCase.CALL_IN, retType,
							new GTMType(M.genVarName(false), direction, argType)) {
						@Override
						public String getMCode() {
							StringBuilder mCode = new StringBuilder();
							mCode.append(mHeader);
							if (direction != GTMType.OUTPUT_ONLY) {
								mCode.append("\twrite " + args[0].name + ",!\n");
								mCode.append("\tset " + args[0].name + "=" + args[0].name + "/10" + "\n");
							} else
								mCode.append("\tset " + args[0].name + "=123\n");
							mCode.append("\tquit" + (ret == GTMType.VOID ? "\n\n" : " " + retValue + "\n\n"));
							return mCode.toString();
						}

						@Override
						public String getJavaCode() {
							StringBuilder builder = new StringBuilder();
							builder.append(javaHeader);
							builder.append("\t\ttry {\n");
							builder.append("\t\t\t" + argInit + "\n");
							if (ret == GTMType.VOID)
								builder.append("\t\t\tGTMCI.do" + retTypeWord + "Job(\"" + name + "\", x);\n");
							else if (ret == GTMType.GTM_FLOAT)
								builder.append("\t\t\tSystem.out.println(\"Job returned \" + " +
										"floatFormat.format(GTMCI.do" + retTypeWord + "Job(\"" + name + "\", x)));\n");
							else if (ret == GTMType.GTM_DOUBLE)
								builder.append("\t\t\tSystem.out.println(\"Job returned \" + " +
										"doubleFormat.format(GTMCI.do" + retTypeWord + "Job(\"" + name + "\", x)));\n");
							else
								builder.append("\t\t\tSystem.out.println(\"Job returned \" + " +
										"GTMCI.do" + retTypeWord + "Job(\"" + name + "\", x));\n");
							if (argType == GTMType.GTM_FLOAT)
								builder.append("\t\t\tSystem.out.println(\"The argument upon return is \" + floatFormat.format(x.value));\n");
							else if (argType == GTMType.GTM_DOUBLE)
								builder.append("\t\t\tSystem.out.println(\"The argument upon return is \" + doubleFormat.format(x.value));\n");
							else
								builder.append("\t\t\tSystem.out.println(\"The argument upon return is \" + x);\n");

							builder.append("\t\t} catch (Exception e) {\n");
							builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
							builder.append("\t\t}\n");
							builder.append("\t}\n");
							return builder.toString();
						}

						@Override
						public String getMResponse() {
							if (doesError)
								return "";
							else if (direction != GTMType.OUTPUT_ONLY) {
								if (argType == GTMType.GTM_BOOLEAN) {
									if (argValue.equals("true"))
										return "1\n";
									else
										return "0\n";
								}
								return argValue + "\n";
							} else
								return "";
						}

						@Override
						public String getJavaResponse() {
							String response = "The argument upon return is " + expValue + "\n";
							String value = retValue;

							if (doesError)
								return expValue;
							else if (ret != GTMType.VOID) {
								if (ret == GTMType.GTM_BOOLEAN) {
									if (value.equals("0"))
										value = "false";
									else
										value = "true";
								}

								response = "Job returned " + value + "\n" + response;
							}

							return response;
						}
					};
				}
			}
		}

		writeTestCase(testCases, 1);
	}

	/*
	 * Test 2: Try the more complex argument and return types.
	 */
	public static void getTest2() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.COMPLEX_CALLIN_ARG_TYPES_LENGTH * GTMType.COMPLEX_CALLIN_RET_TYPES_LENGTH * GTMType.DIRECTIONS_LENGTH];
		int testCasesIndex = 0;

		for (int dirIndex = 0; dirIndex < GTMType.DIRECTIONS_LENGTH; dirIndex++) {
			final int direction = GTMType.DIRECTIONS[dirIndex];

			for (int argIndex = 0; argIndex < GTMType.COMPLEX_CALLIN_ARG_TYPES_LENGTH; argIndex++) {
				for (int retIndex = 0; retIndex < GTMType.COMPLEX_CALLIN_RET_TYPES_LENGTH; retIndex++) {
					final String argValue;
					final String argInit;
					final String expValue;
					final int argType = GTMType.COMPLEX_CALLIN_ARG_TYPES[argIndex];

					switch (argType) {
					case GTMType.GTM_STRING:
						argValue = TestCommon.STRING_ARGS[TestCommon.rand.nextInt(TestCommon.STRING_ARGS_LENGTH)];
						argInit = J.genArgInit("x", "GTMString", "\"" + argValue + "\"");
						if (direction == GTMType.OUTPUT_ONLY)
							// 'ivan' (spelled in cyrillic) encoded in UTF-8
							expValue = new String(new byte[]{(byte)208, (byte)184, (byte)208, (byte)178,
									(byte)208, (byte)176, (byte)208, (byte)189});
						else if (direction == GTMType.INPUT_ONLY)
							expValue = argValue;
						else
							expValue = argValue.substring(argValue.length() / 2);
						break;
					case GTMType.GTM_BYTE_ARRAY:
						argValue = TestCommon.STRING_ARGS[TestCommon.rand.nextInt(TestCommon.STRING_ARGS_LENGTH)];
						argInit = J.genArgInit("x", "GTMByteArray", "\"" + argValue + "\".getBytes(\"UTF-8\")");
						byte[] gtmByteArray = argValue.getBytes("UTF-8");
						if (direction == GTMType.OUTPUT_ONLY) {
							// 'ivan' (spelled in cyrillic) encoded in UTF-8
							byte[] outputArray = new byte[]{(byte)208, (byte)184, (byte)208, (byte)178,
									(byte)208, (byte)176, (byte)208, (byte)189};
							if (gtmByteArray.length < outputArray.length)
								expValue = new String(outputArray, "UTF-8");
							else {
								// only what fits in the original array length will be copied back to Java
								System.arraycopy(outputArray, 0, gtmByteArray, 0, outputArray.length);
								expValue = new String(gtmByteArray, "UTF-8");
							}
						} else if (direction == GTMType.INPUT_ONLY)
							expValue = argValue;
						else {
							String secondHalf = argValue.substring(argValue.length() / 2);
							expValue = secondHalf + secondHalf;
						}
						break;
					case GTMType.JAVA_STRING:
						argValue = TestCommon.STRING_ARGS[TestCommon.rand.nextInt(TestCommon.STRING_ARGS_LENGTH)];
						argInit = J.genArgInit("x", "String", "\"" + argValue + "\"");
						// Java strings are immutable; expect no change
						expValue = argValue;
						break;
					case GTMType.JAVA_BYTE_ARRAY:
						argValue = TestCommon.STRING_ARGS[TestCommon.rand.nextInt(TestCommon.STRING_ARGS_LENGTH)];
						argInit = "byte[] x = \"" + argValue + "\".getBytes(\"UTF-8\");";
						byte[] byteArray = argValue.getBytes("UTF-8");
						if (direction == GTMType.OUTPUT_ONLY) {
							// 'ivan' (spelled in cyrillic) encoded in UTF-8
							byte[] outputArray = new byte[]{(byte)208, (byte)184, (byte)208, (byte)178,
									(byte)208, (byte)176, (byte)208, (byte)189};
							// only what fits in the original array length will be copied back to Java
							int storeCount = Math.min(byteArray.length, outputArray.length);
							System.arraycopy(outputArray, 0, byteArray, 0, storeCount);
							expValue = new String(byteArray, "UTF-8");
						} else if (direction == GTMType.INPUT_ONLY)
							expValue = argValue;
						else {
							String secondHalf = argValue.substring(argValue.length() / 2);
							expValue = secondHalf + secondHalf;
						}
						break;
					case GTMType.JAVA_BIG_DECIMAL:
						// this will almost definitely cause a value beyond the 18-digit mval capacity
						argValue = new BigDecimal(TestCommon.rand.nextLong()).multiply(new BigDecimal(TestCommon.rand.nextLong())).
								multiply(new BigDecimal(TestCommon.rand.nextDouble())).toString();
						argInit = J.genArgInit("x", "BigDecimal", "\"" + argValue + "\"");
						// BigDecimals are only allowed for input-only use, so expect no change
						expValue = argValue;
						break;
					default:
						argInit = null;
						argValue = null;
						expValue = null;
					}

					final int retType = GTMType.COMPLEX_CALLIN_RET_TYPES[retIndex];
					final String retValue = TestCommon.STRING_ARGS[TestCommon.rand.nextInt(TestCommon.STRING_ARGS_LENGTH)];
					final String retTypeWord = GTMType.COMPLEX_CALLIN_RET_TYPE_WORDS[retIndex];

					testCases[testCasesIndex++] = new TestCase("Test2", TestCase.CALL_IN, retType,
							new GTMType(M.genVarName(false), direction, argType)) {
						@Override
						public String getMCode() {
							StringBuilder mCode = new StringBuilder();
							mCode.append(mHeader);
							if (direction != GTMType.OUTPUT_ONLY) {
								mCode.append("\tfor i=1:1:$zlength(" + args[0].name + ") write $zascii($zextract(" + args[0].name + ",i)),\"|\"\n");
								mCode.append("\twrite !\n");
								// set the value to the second half of the original string
								mCode.append("\tset " + args[0].name + "=$zextract(" + args[0].name + ",$zlength(" + args[0].name + ")/2+1,$zlength(" + args[0].name + "))\n");
							} else	// set the value to a predefined string in cyrillic
								mCode.append("\tset " + args[0].name + "=$zchar(208)_$zchar(184)_$zchar(208)_$zchar(178)_" +
										"$zchar(208)_$zchar(176)_$zchar(208)_$zchar(189)\n");
							mCode.append("\tquit" + " \"" + retValue + "\"\n\n");
							return mCode.toString();
						}

						@Override
						public String getJavaCode() {
							StringBuilder builder = new StringBuilder();
							builder.append(javaHeader);
							builder.append("\t\ttry {\n");
							builder.append("\t\t\t" + argInit + "\n");
							if (ret == GTMType.JAVA_BYTE_ARRAY)
								builder.append("\t\t\tSystem.out.println(\"Job returned \" + " +
										"new String(GTMCI.do" + retTypeWord + "Job(\"" + name + "\", x), \"UTF-8\"));\n");
							else
								builder.append("\t\t\tSystem.out.println(\"Job returned \" + " +
										"GTMCI.do" + retTypeWord + "Job(\"" + name + "\", x));\n");
							switch (argType) {
							case GTMType.GTM_STRING:
								builder.append("\t\t\tSystem.out.println(\"The argument upon return is \" + x.value);\n");
								break;
							case GTMType.GTM_BYTE_ARRAY:
								builder.append("\t\t\tSystem.out.println(\"The argument upon return is \" + new String(x.value, \"UTF-8\"));\n");
								break;
							case GTMType.JAVA_STRING:
								builder.append("\t\t\tSystem.out.println(\"The argument upon return is \" + x);\n");
								break;
							case GTMType.JAVA_BYTE_ARRAY:
								builder.append("\t\t\tSystem.out.println(\"The argument upon return is \" + new String(x, \"UTF-8\"));\n");
								break;
							case GTMType.JAVA_BIG_DECIMAL:
								builder.append("\t\t\tSystem.out.println(\"The argument upon return is \" + x.toString());\n");
								break;
							}
							builder.append("\t\t} catch (Exception e) {\n");
							builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
							builder.append("\t\t}\n");
							builder.append("\t}\n");
							return builder.toString();
						}

						@Override
						public String getMResponse() {
							if (direction != GTMType.OUTPUT_ONLY) {
								byte[] stringBytes = null;
								try {
									stringBytes = argValue.getBytes("UTF-8");
								} catch (UnsupportedEncodingException e) {
									e.printStackTrace();
								}
								StringBuilder builder = new StringBuilder();
								int l = stringBytes.length;
								for (int i = 0; i < l; i++) {
									builder.append(stringBytes[i] & 0xFF);
									builder.append("|");
								}
								builder.append("\n");
								return builder.toString();
							} else
								return "";
						}

						@Override
						public String getJavaResponse() {
							return	"Job returned " + retValue + "\n" +
									"The argument upon return is " + expValue + "\n";
						}
					};
				}
			}
		}

		writeTestCase(testCases, 2);
	}

	/*
	 * Test 3: Generate different kinds of errors in M code and expect them to be caught
	 * as exceptions in Java.
	 */
	public static void getTest3() throws Exception {
		String var1 = M.genVarName(false);
		String var2 = M.genVarName(true);

		final String[] errorCodes = new String[]{
				"\twrite " + var1 + "\n",
				"\twrite " + var2 + "\n",
				"\tset a=1/0\n"};
		final String[] errorTexts = new String[]{
				"150373850,%s,%%YDB-E-LVUNDEF, Undefined local variable: " + var1 + "\n",
				"150372994,%s,%%YDB-E-GVUNDEF, Global variable undefined: " + var2 + "\n",
				"150373210,%s,%%YDB-E-DIVZERO, Attempt to divide by zero\n"};

		int numOfErrorCases = errorCodes.length;

		TestCase[] testCases = new TestCase[numOfErrorCases];

		for (int errorCase = 0; errorCase < numOfErrorCases; errorCase++) {
			final int errorIndex = errorCase;

			testCases[errorIndex] = new TestCase("Test3", TestCase.CALL_IN, GTMType.VOID) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append(errorCodes[errorIndex]);
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					// the error thrown in M gets passed to Java, so this is the message
					// from the exception caught in the try-catch block
					return String.format(errorTexts[errorIndex], name + "+1^" + "test3");
				}
			};
		}

		writeTestCase(testCases, 3);
	}

	/*
	 * Test 4: Ensure that if arguments to an M label are skipped, they end up undefined.
	 */
	public static void getTest4() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.ALL_CALLIN_ARG_TYPES_LENGTH * GTMType.ALL_CALLIN_RET_TYPES_LENGTH * GTMType.DIRECTIONS_LENGTH];
		int testCasesIndex = 0;

		for (int dirIndex = 0; dirIndex < GTMType.DIRECTIONS_LENGTH; dirIndex++) {
			final int direction = GTMType.DIRECTIONS[dirIndex];

			for (int argIndex = 0; argIndex < GTMType.ALL_CALLIN_ARG_TYPES_LENGTH; argIndex++) {
				final int argType = GTMType.ALL_CALLIN_ARG_TYPES[argIndex];

				for (int retIndex = 0; retIndex < GTMType.ALL_CALLIN_RET_TYPES_LENGTH; retIndex++) {
					final int retType = GTMType.ALL_CALLIN_RET_TYPES[retIndex];
					final String retTypeWord = GTMType.ALL_CALLIN_RET_TYPE_WORDS[retIndex];

					testCases[testCasesIndex++] = new TestCase("Test4", TestCase.CALL_IN, retType,
							new GTMType(M.genVarName(false), direction, argType)) {
						@Override
						public String getMCode() {
							StringBuilder mCode = new StringBuilder();
							mCode.append(mHeader);
							if (retType == GTMType.VOID) {
								mCode.append("\twrite " + args[0].name + ",!\n");
								mCode.append("\tquit\n");
							} else
								mCode.append("\tquit " + args[0].name + "\n");
							return mCode.toString();
						}

						@Override
						public String getJavaCode() {
							StringBuilder builder = new StringBuilder();
							builder.append(javaHeader);
							builder.append("\t\ttry {\n");
							builder.append("\t\t\tGTMCI.do" + retTypeWord + "Job(\"" + name + "\");\n");
							builder.append("\t\t} catch (Exception e) {\n");
							builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
							builder.append("\t\t}\n");
							builder.append("\t}\n");
							return builder.toString();
						}

						@Override
						public String getJavaResponse() {
							return "150373850," + name + "+1^" + "test4" + ",%YDB-E-LVUNDEF, Undefined local variable: " + args[0].name + "\n";
						}
					};
				}
			}
		}

		writeTestCase(testCases, 4);
	}

	/*
	 * Test 5: Ensure that NULL arguments and NULL 'value' fields do not work.
	 */
	public static void getTest5() throws Exception {
		/* Additional 2 for GTMByteArray and GTMString, which have non-primitive 'value' fields. */
		TestCase[] testCases = new TestCase[(GTMType.ALL_CALLIN_ARG_TYPES_LENGTH + 2) * GTMType.ALL_CALLIN_RET_TYPES_LENGTH * GTMType.DIRECTIONS_LENGTH];
		int testCasesIndex = 0;

		for (int i = 0; i < 2; i++) {
			// if set, indicates that the argument should be NULL, not the 'value' field
			final boolean argNull = i == 1;

			for (int dirIndex = 0; dirIndex < GTMType.DIRECTIONS_LENGTH; dirIndex++) {
				final int direction = GTMType.DIRECTIONS[dirIndex];

				for (int argIndex = 0; argIndex < GTMType.ALL_CALLIN_ARG_TYPES_LENGTH; argIndex++) {
					final int argType = GTMType.ALL_CALLIN_ARG_TYPES[argIndex];

					// the only type that can have a NULL 'value' field is GTMString, since all other types'
					// 'value' fields are primitives
					if (!argNull && (argType != GTMType.GTM_STRING && argType != GTMType.GTM_BYTE_ARRAY))
						continue;

					for (int retIndex = 0; retIndex < GTMType.ALL_CALLIN_RET_TYPES_LENGTH; retIndex++) {

						final int retType = GTMType.ALL_CALLIN_RET_TYPES[retIndex];

						final String argInit;
						final String retTypeWord = GTMType.ALL_CALLIN_RET_TYPE_WORDS[retIndex];

						if (argNull)
							argInit = J.genArgInitNull("x", GTMType.JAVA_ARG_TYPE_NAMES[argIndex]);
						else
							argInit = J.genArgInit("x", GTMType.JAVA_ARG_TYPE_NAMES[argIndex], "null");

						testCases[testCasesIndex++] = new TestCase("Test5", TestCase.CALL_IN, retType,
								new GTMType(M.genVarName(false), direction, argType)) {
							@Override
							public String getMCode() {
								StringBuilder mCode = new StringBuilder();
								mCode.append(mHeader);
								mCode.append("\tquit" + (retType == GTMType.VOID ? "" : " 123") + "\n\n");
								return mCode.toString();
							}

							@Override
							public String getJavaCode() {
								StringBuilder builder = new StringBuilder();
								builder.append(javaHeader);
								builder.append("\t\ttry {\n");
								builder.append("\t\t\t" + argInit + "\n");
								builder.append("\t\t\tGTMCI.do" + retTypeWord + "Job(\"" + name + "\", x);\n");
								builder.append("\t\t} catch (Exception e) {\n");
								builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
								builder.append("\t\t}\n");
								builder.append("\t}\n");
								return builder.toString();
							}

							@Override
							public String getJavaResponse() {
								if (argNull)
									/* Note that we expect GTM-E-JNI below instead of YDB-E-JNI
									 * because the java plugin has that string hardcoded in it.
									 */
									return "GTM-E-JNI, Arg #1 to entryref '" + name + "' is null.\n";
								else
									return "GTM-E-JNI, Passing a null reference in the 'value' field of arg #1 to entryref '" + name + "'.\n";
							}
						};
					}
				}
			}
		}

		writeTestCase(testCases, 5);
	}

	/*
	 * Test 6: Try global writes, hangs, and interrupts.
	 */
	public static void getTest6() throws Exception {
		final String[] mCodes = new String[]{
				"\thang " + (Math.random() * 2) + "\n",
				"\tzsystem \"kill -0 \"_$job_\"; echo $status\"\n",
				"\tset $zinterrupt=\"write \"\"Received an interrupt!\"\",!  hang 1\"\n" +
					"\tif $zsigproc($job,$ztrnlnm(\"sigusrval\"))\n" +
					"\thang 1\n" +
					"\tset " + M.genVarName(true) + "=123\n"};
		final String[] mResponses = new String[]{"", "0\n", "Received an interrupt!\n"};

		int numOfCases = mCodes.length;

		TestCase[] testCases = new TestCase[numOfCases];

		for (int codeCase = 0; codeCase < numOfCases; codeCase++) {
			final int codeIndex = codeCase;

			testCases[codeIndex] = new TestCase("Test6", TestCase.CALL_IN, GTMType.VOID) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append(mCodes[codeIndex]);
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return mResponses[codeIndex];
				}
			};
		}

		writeTestCase(testCases, 6);
	}

	/*
	 * Test 7: Ensure appropriate errors on return type mismatch between what is specified in the call-in table
	 * and actually passed to the routine.
	 */
	public static void getTest7() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.ALL_CALLIN_RET_TYPES_LENGTH * GTMType.ALL_CALLIN_RET_TYPES_LENGTH];
		int testCasesIndex = 0;

		for (int retIndex1 = 0; retIndex1 < GTMType.ALL_CALLIN_RET_TYPES_LENGTH; retIndex1++) {
			final int retType1 = GTMType.ALL_CALLIN_RET_TYPES[retIndex1];
			final String ret1ErrorTypeWord = GTMType.ALL_CALLIN_RET_TYPE_NAMES[retIndex1];

			for (int retIndex2 = 0; retIndex2 < GTMType.ALL_CALLIN_RET_TYPES_LENGTH; retIndex2++) {
				final int retType2 = GTMType.ALL_CALLIN_RET_TYPES[retIndex2];
				final String ret2ErrorTypeWord = GTMType.ALL_CALLIN_RET_TYPE_NAMES[retIndex2];
				final String retTypeWord = GTMType.ALL_CALLIN_RET_TYPE_WORDS[retIndex2];

				testCases[testCasesIndex++] = new TestCase("Test7", TestCase.CALL_IN, retType1) {
					@Override
					public String getMCode() {
						StringBuilder mCode = new StringBuilder();
						mCode.append(mHeader);
						mCode.append("\tquit" + (retType1 == GTMType.VOID ? "" : " 1") + "\n\n");
						return mCode.toString();
					}

					@Override
					public String getJavaCode() {
						StringBuilder builder = new StringBuilder();
						builder.append(javaHeader);
						builder.append("\t\ttry {\n");
						builder.append("\t\t\tGTMCI.do" + retTypeWord + "Job(\"" + name + "\");\n");
						builder.append("\t\t} catch (Exception e) {\n");
						builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
						builder.append("\t\t}\n");
						builder.append("\t}\n");
						return builder.toString();
					}

					@Override
					public String getJavaResponse() {
						if (retType1 == GTMType.VOID) {
							if (retType2 != GTMType.VOID)
								return "GTM-E-JNI, Expecting a return value from a void entryref '" + name + "'.\n";
						} else {
							if (retType2 == GTMType.VOID)
								return "GTM-E-JNI, Expecting void return from a non-void entryref '" + name + "'.\n";
						}
						if (retType1 != retType2)
							return "GTM-E-JNI, Wrong return type for entryref '" + name + "': " +
								ret1ErrorTypeWord + " expected but " + ret2ErrorTypeWord + " found.\n";
						return "";
					}
				};
			}
		}

		writeTestCase(testCases, 7);
	}

	/*
	 * Test 8: Ensure that passing arguments of inappropriate types results in errors describing the mismatch.
	 */
	public static void getTest8() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.ALL_CALLIN_ARG_TYPES_LENGTH * GTMType.ALL_CALLIN_ARG_TYPES_LENGTH * GTMType.DIRECTIONS_LENGTH];
		int testCasesIndex = 0;

		for (int dirIndex = 0; dirIndex < GTMType.DIRECTIONS_LENGTH; dirIndex++) {
			final int direction = GTMType.DIRECTIONS[dirIndex];

			for (int argIndex1 = 0; argIndex1 < GTMType.ALL_CALLIN_ARG_TYPES_LENGTH; argIndex1++) {
				final int finalArgIndex1 = argIndex1;
				final int argType1 = GTMType.ALL_CALLIN_ARG_TYPES[argIndex1];

				for (int argIndex2 = 0; argIndex2 < GTMType.ALL_CALLIN_ARG_TYPES_LENGTH; argIndex2++) {
					final int finalArgIndex2 = argIndex2;
					final int argType2 = GTMType.ALL_CALLIN_ARG_TYPES[argIndex2];

					final String argInit;

					switch (argType2) {
					case GTMType.GTM_BOOLEAN:
						argInit = J.genArgInit("x", "GTMBoolean", "true");
						break;
					case GTMType.GTM_INTEGER:
						argInit = J.genArgInit("x", "GTMInteger", "1");
						break;
					case GTMType.GTM_LONG:
						argInit = J.genArgInit("x", "GTMLong", "1L");
						break;
					case GTMType.GTM_FLOAT:
						argInit = J.genArgInit("x", "GTMFloat", "1.0F");
						break;
					case GTMType.GTM_DOUBLE:
						argInit = J.genArgInit("x", "GTMDouble", "1.0");
						break;
					case GTMType.GTM_STRING:
						argInit = J.genArgInit("x", "GTMString", "\"1\"");
						break;
					case GTMType.GTM_BYTE_ARRAY:
						argInit = J.genArgInit("x", "GTMByteArray", "new byte[]{1}");
						break;
					case GTMType.JAVA_STRING:
						argInit = J.genArgInit("x", "String", "\"1\"");
						break;
					case GTMType.JAVA_BYTE_ARRAY:
						argInit = "byte[] x = new byte[]{1};";
						break;
					case GTMType.JAVA_BIG_DECIMAL:
						argInit = J.genArgInit("x", "BigDecimal", "1");
						break;
					default:
						argInit = null;
					}

					testCases[testCasesIndex++] = new TestCase("Test8", TestCase.CALL_IN, GTMType.VOID,
							new GTMType(M.genVarName(false), direction, argType1)) {
						@Override
						public String getMCode() {
							StringBuilder mCode = new StringBuilder();
							mCode.append(mHeader);
							mCode.append("\tquit\n\n");
							return mCode.toString();
						}

						@Override
						public String getJavaCode() {
							StringBuilder builder = new StringBuilder();
							builder.append(javaHeader);
							builder.append("\t\ttry {\n");
							builder.append("\t\t\t" + argInit + "\n");
							builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\", x);\n");
							builder.append("\t\t} catch (Exception e) {\n");
							builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
							builder.append("\t\t}\n");
							builder.append("\t}\n");
							return builder.toString();
						}

						@Override
						public String getJavaResponse() {
							if (argType1 != argType2)
							{
								if ((argType1 == GTMType.GTM_STRING) || (argType1 == GTMType.JAVA_STRING)) {
									if ((argType2 != GTMType.GTM_STRING) && (argType2 != GTMType.JAVA_STRING))
										return "GTM-E-JNI, Wrong type used for arg #1 to entryref '" + name +
											"': GTMString or String expected but " + GTMType.JAVA_ARG_TYPE_NAMES[finalArgIndex2] + " found.\n";
								} else if ((argType1 == GTMType.GTM_BYTE_ARRAY) || (argType1 == GTMType.JAVA_BYTE_ARRAY)) {
									if ((argType2 != GTMType.GTM_BYTE_ARRAY) && (argType2 != GTMType.JAVA_BYTE_ARRAY))
										return "GTM-E-JNI, Wrong type used for arg #1 to entryref '" + name +
											"': GTMByteArray or byte[] expected but " + GTMType.JAVA_ARG_TYPE_NAMES[finalArgIndex2] + " found.\n";
								} else
									return "GTM-E-JNI, Wrong type used for arg #1 to entryref '" + name + "': " +
									GTMType.JAVA_ARG_TYPE_NAMES[finalArgIndex1] + " expected but " + GTMType.JAVA_ARG_TYPE_NAMES[finalArgIndex2] + " found.\n";
							}
							return "";
						}
					};
				}
			}
		}

		writeTestCase(testCases, 8);
	}

	/*
	 * Test 9: Do a halt and ensure that the process terminates.
	 */
	public static void getTest9() throws Exception {
		TestCase[] testCases = new TestCase[] {
			new TestCase("Test9", TestCase.CALL_IN, GTMType.VOID) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append("\thalt\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\");\n");
					/* Starting r1.10, due to issue #32, a HALT inside a call-in returns to the caller
					 * instead of exiting and therefore we should expect the next line to be displayed
					 * even though the previous line did a call-in that in turn did a HALT.
					 */
					builder.append("\t\t\tSystem.out.println(\"This should get displayed even though previous call-in did a HALT!\");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return "This should get displayed even though previous call-in did a HALT!\n";
				}
			}
		};

		writeTestCase(testCases, 9);
	}

	/*
	 * Test 10: Ensure that MUPIP STOP terminates the GT.M instance.
	 */
	public static void getTest10() throws Exception {
		TestCase[] testCases = new TestCase[] {
			new TestCase("Test10", TestCase.CALL_IN, GTMType.VOID) {
				@Override
				public String getMCode() {
					// fires up a child job and terminates it
					String childControl = M.genVarName(true);
					String ready = M.genVarName(true);
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append("\tif ($data(" + childControl + ")) do\n");
					mCode.append("\t.\twrite \"This is a child process!\",!\n");
					mCode.append("\t.\tset " + ready + "=1\n");
					mCode.append("\t.\tfor  hang 1\n");
					mCode.append("\tset " + childControl + "=1\n");
					mCode.append("\twrite \"This is a parent process!\",!\n");
					mCode.append("\tset " + ready + "=0\n");
					mCode.append("\tjob ^test10\n");
					mCode.append("\tfor i=1:1:60 quit:" + ready + "  hang 1\n");
					mCode.append("\tif i=60 write \"TEST-E-FAIL, The child did not start in one minute\",! quit\n");
					mCode.append("\tif $zsigproc($zjob,15)\n");
					mCode.append("\tfor i=1:1:60 quit:$zsigproc($zjob,0)  hang 1\n");
					mCode.append("\tif i=60 write \"TEST-E-FAIL, The child did not terminate in one minute\",! quit\n");
					mCode.append("\twrite \"The child process is dead!\",!\n");
					mCode.append("\tkill " + childControl + "\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\");\n");
					builder.append("\t\t\tSystem.out.println(\"The M job has terminated!\");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getMResponse() {
					return
					"This is a parent process!\n" +
					"The child process is dead!\n";
				}

				@Override
				public String getJavaResponse() {
					return "The M job has terminated!\n";
				}
			}
		};

		writeTestCase(testCases, 10);
	}

	/*
	 * Test 11: Verify that an error is issued on an incorrect call-in routine name.
	 */
	public static void getTest11() throws Exception {
		final String[] javaCodes = new String[]{
			"\t\t\tGTMCI.doVoidJob(\"abc123\");\n",
			"\t\t\tString abc = \"a\";\n" +
				"\t\t\tfor (int i = 0; i < 11; i++)\n" +
				"\t\t\t\tabc = abc + abc;\n" +
				"\t\t\tabc += \"a\";\n" +
				"\t\t\tGTMCI.doVoidJob(abc);\n" };
		final String[] javaResponses = new String[]{
			"150379666,(Call-In),%YDB-E-CINOENTRY, No entry specified for abc123 in the call-in table\n",
			"GTM-E-JNI, Entryref exceeds 2048 characters.\n" };

		int numOfCases = javaCodes.length;

		TestCase[] testCases = new TestCase[numOfCases];

		for (int codeCase = 0; codeCase < numOfCases; codeCase++) {
			final int codeIndex = codeCase;

			testCases[codeIndex] = new TestCase("Test11", TestCase.CALL_IN, GTMType.VOID) {
				@Override
				public String getMCode() {
					return mHeader + "\tquit\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append(javaCodes[codeIndex]);
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return javaResponses[codeIndex];
				}
			};
		}

		writeTestCase(testCases, 11);
	}

	/*
	 * Test 12: Verify that an error is issued if more than 31 arguments are passed.
	 */
	public static void getTest12() throws Exception {
		int numOfCases = 32;

		GTMType[] args = new GTMType[numOfCases];
		String varNameBase = M.genVarName(false);
		for (int i = 0; i < numOfCases; i++)
			args[i] = new GTMType(varNameBase + i, GTMType.INPUT_ONLY, GTMType.GTM_BOOLEAN);

		TestCase[] testCases = new TestCase[numOfCases];

		for (int testCase = 0; testCase < numOfCases; testCase++) {
			final int numOfTestArgs = testCase + 1;

			GTMType[] testArgs = new GTMType[numOfTestArgs];
			System.arraycopy(args, 0, testArgs, 0, numOfTestArgs);

			testCases[testCase] = new TestCase("Test12", TestCase.CALL_IN, GTMType.GTM_INTEGER, testArgs) {
				@Override
				public String getMCode() {
					return mHeader + "\tquit 1\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tGTMCI.doIntJob(\"" + name + "\"");
					for (int i = 0; i < numOfTestArgs; i++)
						builder.append(", new GTMBoolean(true)");
					builder.append(");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					if (numOfTestArgs > 33)
						return "GTM-E-JNI, Number of parameters to entryref '" + name + "' exceeds 32.\n";
					else
						return "";
				}
			};
		};

		writeTestCase(testCases, 12);
	}

	/*
	 * Test 13: Expect an error when passing more actuals than formals.
	 */
	public static void getTest13() throws Exception {
		final int numOfFormals = 1 + TestCommon.rand.nextInt(31);
		final int numOfActuals = numOfFormals + 1;

		final GTMType[] formals = new GTMType[numOfFormals];

		String varNameBase = M.genVarName(false);
		for (int i = 0; i < numOfFormals; i++)
			formals[i] = new GTMType(varNameBase + i, GTMType.DIRECTIONS[TestCommon.rand.nextInt(GTMType.DIRECTIONS_LENGTH)], GTMType.GTM_INTEGER);

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test13", TestCase.CALL_IN, GTMType.VOID, formals) {
				@Override
				public String getMCode() {
					return mHeader + "\tquit\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\"");
					for (int i = 0; i < numOfActuals; i++)
						builder.append(", new GTMInteger(" + i + ")");
					builder.append(");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return "150374474,(Call-In),%YDB-E-ACTLSTTOOLONG, More actual parameters than formal parameters: lbl0\n";
				}
			}
		};

		writeTestCase(testCases, 13);
	}

	/*
	 * Test 14: Expect undefined arguments when there are fewer actuals than formals.
	 */
	public static void getTest14() throws Exception {
		final int numOfFormals = 1 + TestCommon.rand.nextInt(32);
		final int numOfActuals = numOfFormals - 1;

		final GTMType[] formals = new GTMType[numOfFormals];

		final String varNameBase = M.genVarName(false);
		for (int i = 0; i < numOfFormals; i++)
			formals[i] = new GTMType(varNameBase + i, GTMType.DIRECTIONS[TestCommon.rand.nextInt(GTMType.DIRECTIONS_LENGTH)], GTMType.GTM_LONG);

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test14", TestCase.CALL_IN, GTMType.VOID, formals) {
				@Override
				public String getMCode() {
					return mHeader + "\twrite " + args[numOfFormals - 1].name + ",!\n\tquit\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\"");
					for (int i = 0; i < numOfActuals; i++)
						builder.append(", new GTMLong(" + i + "L)");
					builder.append(");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return "150373850,lbl0+1^test14,%YDB-E-LVUNDEF, Undefined local variable: " + args[numOfFormals - 1].name + "\n";
				}
			}
		};

		writeTestCase(testCases, 14);
	}

	/*
	 * Test 15: Verify that strings of over 1MB are not allowed.
	 */
	public static void getTest15() throws Exception {
		final int[] types = new int[] {GTMType.GTM_STRING, GTMType.GTM_BYTE_ARRAY, GTMType.JAVA_STRING, GTMType.JAVA_BYTE_ARRAY};
		final int type = types[TestCommon.rand.nextInt(types.length)];
		TestCase[] testCases = new TestCase[] {
			new TestCase("Test15", TestCase.CALL_IN, GTMType.VOID,
					new GTMType(M.genVarName(false), GTMType.INPUT_ONLY, type)) {
				@Override
				public String getMCode() {
					return mHeader + "\tquit\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tStringBuilder sb = new StringBuilder(1100000);\n");
					builder.append("\t\t\twhile (sb.length() < 1100000)\n");
					builder.append("\t\t\t\tsb.append(\"abcdefghijklmnopqrstuvwxyz\");\n");
					if (type == GTMType.JAVA_STRING)
						builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\", sb.toString());\n");
					else if (type == GTMType.GTM_BYTE_ARRAY)
						builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\", new GTMByteArray(sb.toString().getBytes()));\n");
					else if (type == GTMType.JAVA_BYTE_ARRAY)
						builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\", sb.toString().getBytes());\n");
					else
						builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\", new GTMString(sb.toString()));\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					if (type == GTMType.JAVA_STRING)
						return "GTM-E-JNI, Value of arg #1 to entryref '" + name + "' exceeds the capacity of M variables.\n";
					else if (type == GTMType.JAVA_BYTE_ARRAY)
						return "GTM-E-JNI, Length of arg #1 to entryref '" + name + "' exceeds the capacity of M variables.\n";
					else
						return "GTM-E-JNI, Length of 'value' field in arg #1 to entryref '" + name + "' exceeds the capacity of M variables.\n";

				}
			}
		};

		writeTestCase(testCases, 15);
	}

	/*
	 * Test 16: Verify that errors are issued if the argument types do not correspond to the call-in table.
	 * Note that these types have a valid base (integer, long, and so on), but are inappropriate for Java call-ins.
	 */
	public static void getTest16() throws Exception {
		final String[] types = new String[] {
			"gtm_int_t", "gtm_int_t *", "gtm_uint_t", "gtm_uint_t *", "gtm_long_t", "gtm_long_t *",
			"gtm_ulong_t", "gtm_ulong_t *", "gtm_float_t", "gtm_float_t *", "gtm_double_t", "gtm_double_t *",
			"gtm_char_t *", "gtm_string_t *" };
		final String[] constructors = new String[] {
			"GTMInteger(123)", "GTMInteger(123)", "GTMInteger(123)", "GTMInteger(123)", "GTMLong(123L)", "GTMLong(123L)",
			"GTMLong(123L)", "GTMLong(123L)", "GTMFloat(123.0F)", "GTMFloat(123.0F)", "GTMDouble(123.0)", "GTMDouble(123.0)",
			"GTMString(\"123\")", "GTMString(\"123\")" };
		int types_length = types.length;

		TestCase[] testCases = new TestCase[types_length];

		for (int typeIndex = 0; typeIndex < types_length; typeIndex++) {
			final String argType = types[typeIndex];
			final String argConstructor = constructors[typeIndex];
			testCases[typeIndex] = new TestCase("Test16", TestCase.CALL_IN, GTMType.VOID,
					new GTMType(M.genVarName(false), GTMType.INPUT_ONLY, -1)) {
				@Override
				public String getMCode() {
					return mHeader + "\tquit\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\", new " + argConstructor + ");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return "GTM-E-JNI, Invalid expected type for arg #1 to entryref '" + name + "'.\n";
				}

				@Override
				public String getTableContent() {
					StringBuilder builder = new StringBuilder();
					builder.append(name);
					builder.append("\t:void ");
					builder.append(name);
					builder.append("^");
					builder.append(testName.toLowerCase());
					builder.append("(I:");
					builder.append(argType);
					builder.append(")\n");
					return builder.toString();
				}
			};
		}

		writeTestCase(testCases, 16);
	}

	/*
	 * Test 17: Verify that errors are issued if invalid types are used. Note that these types are not allowed
	 * for arguments in any call-in definition.
	 */
	public static void getTest17() throws Exception {
		final String[] types = new String[] {
			"gtm_char_t", "gtm_char_t **", "gtm_string_t", "gtm_pointertofunc_t", "gtm_pointertofunc_t *",
		 	"gtm_status_t", "gtm_status_t *", "gtm_jint_t *", "gtm_jlong_t *", "gtm_jfloat_t *", "gtm_jdouble_t *",
		 	"gtm_jboolean_t *", "gtm_jstring_t *", "gtm_jbyte_array_t *", "gtm_jbig_decimal_t *" };
		final String invalidType = types[TestCommon.rand.nextInt(types.length)];

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test17", TestCase.CALL_IN, GTMType.VOID,
					new GTMType(M.genVarName(false), GTMType.INPUT_ONLY, GTMType.GTM_INTEGER)) {
				@Override
				public String getMCode() {
					return mHeader + "\tquit\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return	"%YDB-I-EXTSRCLIN, \tlbl0\t:void lbl0^test17(I:" + invalidType + ")\n" +
							"%YDB-I-EXTSRCLOC, \t\tAt column xx, line 1, source module ./Test17.ci\n" +
							"150379658,(Call-In),%YDB-E-CIUNTYPE, Unknown parameter type encountered\n";
				}

				@Override
				public String getTableContent() {
					StringBuilder builder = new StringBuilder();
					builder.append(name);
					builder.append("\t:void ");
					builder.append(name);
					builder.append("^");
					builder.append(testName.toLowerCase());
					builder.append("(I:");
					builder.append(invalidType);
					builder.append(")\n");
					return builder.toString();
				}
			}
		};

		writeTestCase(testCases, 17);
	}

	/*
	 * Test 18: Try updating Java variables in GT.M with values exceeding their respective capacities in Java.
	 */
	public static void getTest18() throws Exception {
		TestCase[] testCases = new TestCase[2];
		for (int i = 0; i < 2; i++) {
			final int testIndex = i;
			testCases[testIndex] = new TestCase("Test18", TestCase.CALL_IN, GTMType.VOID,
					new GTMType(M.genVarName(false), GTMType.INPUT_OUTPUT, testIndex == 0 ? GTMType.GTM_INTEGER : GTMType.GTM_LONG)) {
				@Override
				public String getMCode() {
					return
						mHeader +
						"\tset " + args[0].name + "=" + (testIndex == 0 ? "12345678901\n" : "12345678901234567890\n") +
						"\tquit\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					if (testIndex == 0)
						builder.append("\t\t\tGTMInteger x = new GTMInteger(0);\n");
					else
						builder.append("\t\t\tGTMLong x = new GTMLong(0L);\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\", x);\n");
					if (testIndex == 0) {
						builder.append("\t\t\tif (x.value != 12345678901L)\n");
						builder.append("\t\t\t\tSystem.out.println(\"GTMInteger overflown!\");\n");
					} else {
						builder.append("\t\t\tif (!x.toString().equals(\"12345678901234567890\"))\n");
						builder.append("\t\t\t\tSystem.out.println(\"GTMLong overflown!\");\n");
					}
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					if (testIndex == 0)
						return "GTMInteger overflown!\n";
					else
						return "GTMLong overflown!\n";
				}
			};
		}

		writeTestCase(testCases, 18);
	}

	/*
	 * Test 19: Ensure appropriate conversion when passing alphanumeric values to numeric types.
	 */
	public static void getTest19() throws Exception {
		final String[] returnValues = new String[] {
			"123", "123abc", "abc", "abc123"};
		final String[] expReturnValues = new String[] {
			"123", "123", "0", "0"};
		final int returnValuesLength = returnValues.length;

		TestCase[] testCases = new TestCase[(GTMType.BASIC_CALLIN_RET_TYPES_LENGTH - 1) * returnValuesLength];
		int testCasesIndex = 0;

		for (int retValueIndex = 0; retValueIndex < returnValuesLength; retValueIndex++) {
			final String returnValue = returnValues[retValueIndex];
			final String expReturnValue = expReturnValues[retValueIndex];

			for (int retIndex = 0; retIndex < GTMType.BASIC_CALLIN_RET_TYPES_LENGTH - 1; retIndex++) {
				final int retType = GTMType.BASIC_CALLIN_RET_TYPES[retIndex];
				final String retTypeWord;

				if (retType == GTMType.VOID)
					continue;
				else
					retTypeWord = GTMType.ALL_CALLIN_RET_TYPE_WORDS[retIndex];

				testCases[testCasesIndex++] = new TestCase("Test19", TestCase.CALL_IN, retType) {
					@Override
					public String getMCode() {
						return mHeader + "\tquit \"" + returnValue + "\"\n";
					}

					@Override
					public String getJavaCode() {
						StringBuilder builder = new StringBuilder();
						builder.append(javaHeader);
						builder.append("\t\ttry {\n");
						builder.append("\t\t\tSystem.out.println(GTMCI.do" + retTypeWord + "Job(\"" + name + "\"));\n");
						builder.append("\t\t} catch (Exception e) {\n");
						builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
						builder.append("\t\t}\n");
						builder.append("\t}\n");
						return builder.toString();
					}

					@Override
					public String getJavaResponse() {
						String retValue;
						if (retType == GTMType.GTM_BOOLEAN)
							retValue = expReturnValue.equals("0") ? "false" : "true";
						else if (retType == GTMType.GTM_INTEGER || retType == GTMType.GTM_LONG)
							retValue = expReturnValue;
						else /* GTMType.GTM_FLOAT or GTMType.GTM_DOUBLE */
							retValue = expReturnValue + ".0";
						return retValue + "\n";
					}
				};
			}
		}

		writeTestCase(testCases, 19);
	}

	/*
	 * Test 20: Verify that access from concurrent threads is properly serialized.
	 */
	public static void getTest20() throws Exception {
		final int numOfThreads = 5;
		final int numOfIterations = 10;

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test20", TestCase.CALL_IN, GTMType.VOID) {
				@Override
				public String getMCode() {
					StringBuilder builder = new StringBuilder();
					builder.append("callins(boolInVar,intInVar,longInVar,floatInVar,doubleInVar,stringInVar,byteArrayInVar,javaStringInVar,javaByteArrayInVar,bigDecimalInVar)\n");
					builder.append("\tset boolInVar=10,intInVar=1,longInVar=2,floatInVar=3,doubleInVar=4,stringInVar=5,byteArrayInVar=6,javaStringInVar=7,javaByteArrayInVar=8,bigDecimalInVar=9\n");
					builder.append("\tset ^x=1\n");
					builder.append("\tquit\n");
					builder.append("\n");
					builder.append("callinsByRef(boolInVar,intInVar,longInVar,floatInVar,doubleInVar,stringInVar,byteArrayInVar,javaStringInVar,javaByteArrayInVar)\n");
					builder.append("\tset boolInVar=0,intInVar=1,longInVar=2,floatInVar=3,doubleInVar=4,stringInVar=5,byteArrayInVar=6,javaStringInVar=7,byteArrayInVar=8\n");
					builder.append("\tset ^x=1\n");
					builder.append("\tquit\n");
					builder.append("\n");
					builder.append("callinsIO(boolInVar,intInVar,longInVar,floatInVar,doubleInVar,stringInVar,byteArrayInVar,javaStringInVar,javaByteArrayInVar)\n");
					builder.append("\tset boolInVar=123,intInVar=123,longInVar=234,floatInVar=345,doubleInVar=456,stringInVar=\"567\",byteArrayInVar=$char(54)_$char(55)_$char(56),javaStringInVar=\"789\",javaByteArrayInVar=$char(48)_$char(49)_$char(50)\n");
					builder.append("\tset ^x=1\n");
					builder.append("\tquit 9876543210\n");
					builder.append("\n");
					builder.append("callinsRetBool(boolInVar)\n");
					builder.append("\tquit -boolInVar\n");
					builder.append("\n");
					builder.append("callinsRetInt(intInVar)\n");
					builder.append("\tquit intInVar+1\n");
					builder.append("\n");
					builder.append("callinsRetLong(longInVar)\n");
					builder.append("\tquit longInVar+1\n");
					builder.append("\n");
					builder.append("callinsRetFloat(floatInVar)\n");
					builder.append("\tquit floatInVar/2.0\n");
					builder.append("\n");
					builder.append("callinsRetDouble(doubleInVar)\n");
					builder.append("\tquit doubleInVar/2.0\n");
					builder.append("\n");
					builder.append("callinsRetString(stringInVar)\n");
					builder.append("\tquit \"abc\"\n");
					builder.append("\n");
					builder.append("callinsRetByteArray(byteArrayInVar)\n");
					builder.append("\tquit byteArrayInVar\n");
					return builder.toString();
				}

				@Override
				public String getTableContent() {
					StringBuilder builder = new StringBuilder();
					builder.append("callins\t\t\t:void callins^test20(I:gtm_jboolean_t,I:gtm_jint_t,I:gtm_jlong_t,I:gtm_jfloat_t,I:gtm_jdouble_t,I:gtm_jstring_t,I:gtm_jbyte_array_t,I:gtm_jstring_t,I:gtm_jbyte_array_t,I:gtm_jbig_decimal_t)\n");
					builder.append("callinsByRef\t\t:void callinsByRef^test20(I:gtm_jboolean_t,I:gtm_jint_t,I:gtm_jlong_t,I:gtm_jfloat_t,I:gtm_jdouble_t,I:gtm_jstring_t,I:gtm_jbyte_array_t,I:gtm_jstring_t,I:gtm_jbyte_array_t)\n");
					builder.append("callinsIO\t\t:gtm_jlong_t callinsIO^test20(IO:gtm_jboolean_t,IO:gtm_jint_t,IO:gtm_jlong_t,IO:gtm_jfloat_t,IO:gtm_jdouble_t,IO:gtm_jstring_t,IO:gtm_jbyte_array_t,IO:gtm_jstring_t,IO:gtm_jbyte_array_t)\n");
					builder.append("callinsRetBool\t\t:gtm_jboolean_t callinsRetBool^test20(I:gtm_jboolean_t)\n");
					builder.append("callinsRetInt\t\t:gtm_jint_t callinsRetInt^test20(I:gtm_jint_t)\n");
					builder.append("callinsRetLong\t\t:gtm_jlong_t callinsRetLong^test20(I:gtm_jlong_t)\n");
					builder.append("callinsRetFloat\t\t:gtm_jfloat_t callinsRetFloat^test20(I:gtm_jfloat_t)\n");
					builder.append("callinsRetDouble\t:gtm_jdouble_t callinsRetDouble^test20(I:gtm_jdouble_t)\n");
					builder.append("callinsRetString\t:gtm_jstring_t callinsRetString^test20(I:gtm_jstring_t)\n");
					builder.append("callinsRetByteArray\t:gtm_jbyte_array_t callinsRetByteArray^test20(I:gtm_jbyte_array_t)\n");
					return builder.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tfinal int numOfThreads = " + numOfThreads + ";\n");
					builder.append("\t\t\tThread[] threads = new Thread[numOfThreads];\n");
					builder.append("\t\t\tfinal StringBuilder[] builders = new StringBuilder[numOfThreads];\n");
					builder.append("\t\t\tfor (int i = 0; i < numOfThreads; i++) {\n");
					builder.append("\t\t\t\tfinal int threadIndex = i;\n");
					builder.append("\t\t\t\tthreads[i] = new Thread(new Runnable() {\n");
					builder.append("\t\t\t\t@Override\n");
					builder.append("\t\t\t\t\t\tpublic void run() {\n");
					builder.append("\t\t\t\t\t\ttry {\n");
					builder.append("\t\t\t\t\t\t\tThread.sleep((long)(200 * Math.random()));\n");
					builder.append("\t\t\t\t\t\t\tbuilders[threadIndex] = new StringBuilder();\n");
					builder.append("\t\t\t\t\t\t\tfor (int j = 0; j < " + numOfIterations + "; j++) {\n");
					builder.append("\t\t\t\t\t\t\t\tGTMBoolean gtmBoolean = new GTMBoolean(false);\n");
					builder.append("\t\t\t\t\t\t\t\tGTMInteger gtmInteger = new GTMInteger(3);\n");
					builder.append("\t\t\t\t\t\t\t\tGTMLong gtmLong = new GTMLong(1415L);\n");
					builder.append("\t\t\t\t\t\t\t\tGTMFloat gtmFloat = new GTMFloat(9.26535f);\n");
					builder.append("\t\t\t\t\t\t\t\tGTMDouble gtmDouble = new GTMDouble(8.979323846);\n");
					builder.append("\t\t\t\t\t\t\t\tGTMString gtmString = new GTMString(\"GT.M String Value\");\n");
					builder.append("\t\t\t\t\t\t\t\tGTMByteArray gtmByteArray = new GTMByteArray(new byte[]{51, 49, 52, 49});\n");
					builder.append("\t\t\t\t\t\t\t\tString javaString = \"Java String Value\";\n");
					builder.append("\t\t\t\t\t\t\t\tbyte[] javaByteArray = new byte[]{51, 49, 52, 49};\n");
					builder.append("\t\t\t\t\t\t\t\tBigDecimal bigDecimal = new BigDecimal(\"3.14159265358979323846\");\n");
					builder.append("\t\t\t\t\t\t\t\tGTMCI.doVoidJob(\"callins\", gtmBoolean, gtmInteger, gtmLong, gtmFloat,\n");
					builder.append("\t\t\t\t\t\t\t\t\tgtmDouble, gtmString, gtmByteArray, javaString, javaByteArray, bigDecimal);\n");
					builder.append("\t\t\t\t\t\t\t\tbuilders[threadIndex].append(\"Java values:\\t\" + gtmBoolean + \", \" + gtmInteger + \", \"\n");
					builder.append("\t\t\t\t\t\t\t\t\t+ gtmLong + \", \" + gtmFloat + \", \" + gtmDouble + \", \" + gtmString + \", \" + gtmByteArray + \", \"\n");
					builder.append("\t\t\t\t\t\t\t\t\t+ javaString + \", \" + new String(javaByteArray) + \", \" + bigDecimal + \"\\n\");\n");
					builder.append("\t\t\t\t\t\t\t\tGTMCI.doVoidJob(\"callinsByRef\", gtmBoolean, gtmInteger, gtmLong,\n");
					builder.append("\t\t\t\t\t\t\t\t\tgtmFloat, gtmDouble, gtmString, gtmByteArray, javaString, javaByteArray);\n");
					builder.append("\t\t\t\t\t\t\t\tbuilders[threadIndex].append(\"Java values:\t\" + gtmBoolean + \", \" + gtmInteger + \", \"\n");
					builder.append("\t\t\t\t\t\t\t\t\t+ gtmLong + \", \" + gtmFloat + \", \" + gtmDouble + \", \" + gtmString + \", \" + gtmByteArray + \", \"\n");
					builder.append("\t\t\t\t\t\t\t\t\t+ javaString + \", \" + new String(javaByteArray) + \"\\n\");\n");
					builder.append("\t\t\t\t\t\t\t\tbuilders[threadIndex].append(\"The callinsIO job returned \" + GTMCI.doLongJob(\n");
					builder.append("\t\t\t\t\t\t\t\t\t\"callinsIO\", gtmBoolean, gtmInteger, gtmLong, gtmFloat,\n");
					builder.append("\t\t\t\t\t\t\t\t\tgtmDouble, gtmString, gtmByteArray, javaString, javaByteArray) + \"\\n\");\n");
					builder.append("\t\t\t\t\t\t\t\tbuilders[threadIndex].append(\"Java values:\t\" + gtmBoolean + \", \" + gtmInteger + \", \"\n");
					builder.append("\t\t\t\t\t\t\t\t\t+ gtmLong + \", \" + gtmFloat + \", \" + gtmDouble + \", \" + gtmString + \", \" + gtmByteArray + \", \"\n");
					builder.append("\t\t\t\t\t\t\t\t\t+ javaString + \", \" + new String(javaByteArray) + \"\\n\");\n");
					builder.append("\t\t\t\t\t\t\t\tbuilders[threadIndex].append(\"The callinsRetBool job returned \" + GTMCI.doBooleanJob(\"callinsRetBool\", gtmBoolean) + \"\\n\");\n");
					builder.append("\t\t\t\t\t\t\t\tbuilders[threadIndex].append(\"The callinsRetInt job returned \" + GTMCI.doIntJob(\"callinsRetInt\", gtmInteger) + \"\\n\");\n");
					builder.append("\t\t\t\t\t\t\t\tbuilders[threadIndex].append(\"The callinsRetLong job returned \" + GTMCI.doLongJob(\"callinsRetLong\", gtmLong) + \"\\n\");\n");
					builder.append("\t\t\t\t\t\t\t\tbuilders[threadIndex].append(\"The callinsRetFloat job returned \" + GTMCI.doFloatJob(\"callinsRetFloat\", gtmFloat) + \"\\n\");\n");
					builder.append("\t\t\t\t\t\t\t\tbuilders[threadIndex].append(\"The callinsRetDouble job returned \" + GTMCI.doDoubleJob(\"callinsRetDouble\", gtmDouble) + \"\\n\");\n");
					builder.append("\t\t\t\t\t\t\t\tbuilders[threadIndex].append(\"The callinsRetString job returned \" + GTMCI.doStringJob(\"callinsRetString\", gtmString) + \"\\n\");\n");
					builder.append("\t\t\t\t\t\t\t\tbuilders[threadIndex].append(\"The callinsRetByteArray job returned \" + new String(GTMCI.doByteArrayJob(\"callinsRetByteArray\", javaByteArray)) + \"\\n\");\n");
					builder.append("\t\t\t\t\t\t\t\tThread.sleep((long)(30));\n");
					builder.append("\t\t\t\t\t\t\t}\n");
					builder.append("\t\t\t\t\t\t} catch (Exception e) {\n");
					builder.append("\t\t\t\t\t\t\te.printStackTrace();\n");
					builder.append("\t\t\t\t\t\t\tThread.currentThread().interrupt();\n");
					builder.append("\t\t\t\t\t\t}\n");
					builder.append("\t\t\t\t\t}\n");
					builder.append("\t\t\t\t});\n");
					builder.append("\t\t\t}\n");
					builder.append("\t\t\tSystem.out.println(\"All threads created!\");\n");
					builder.append("\t\t\tfor (int i = 0; i < numOfThreads; i++)\n");
					builder.append("\t\t\t\tthreads[i].start();\n");
					builder.append("\t\t\tSystem.out.println(\"All threads started!\");\n");
					builder.append("\t\t\tfor (int i = 0; i < numOfThreads; i++) {\n");
					builder.append("\t\t\t\ttry {\n");
					builder.append("\t\t\t\t\tthreads[i].join();\n");
					builder.append("\t\t\t\t} catch (InterruptedException e) {\n");
					builder.append("\t\t\t\t\te.printStackTrace();\n");
					builder.append("\t\t\t\t\tcontinue;\n");
					builder.append("\t\t\t\t}\n");
					builder.append("\t\t\t}\n");
					builder.append("\t\t\tSystem.out.println(\"All threads died!\");\n");
					builder.append("\t\t\tSystem.out.println(\"Cumulative output:\");\n");
					builder.append("\t\t\tfor (int i = 0; i < numOfThreads; i++) {\n");
					builder.append("\t\t\t\tSystem.out.println(\"Thread \" + i + \":\");\n");
					builder.append("\t\t\t\tSystem.out.println(builders[i].toString());\n");
					builder.append("\t\t\t}\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				public String getJavaResponse() {
					StringBuilder builder = new StringBuilder();
					builder.append("Java values:\tfalse, 3, 1415, 9.26535, 8.979323846, GT.M String Value, 3141, Java String Value, 3141, 3.14159265358979323846\n");
					builder.append("Java values:\tfalse, 3, 1415, 9.26535, 8.979323846, GT.M String Value, 3141, Java String Value, 3141\n");
					builder.append("The callinsIO job returned 9876543210\n");
					builder.append("Java values:\ttrue, 123, 234, 345.0, 456.0, 567, 6781, Java String Value, 0121\n");
					builder.append("The callinsRetBool job returned true\n");
					builder.append("The callinsRetInt job returned 124\n");
					builder.append("The callinsRetLong job returned 235\n");
					builder.append("The callinsRetFloat job returned 172.5\n");
					builder.append("The callinsRetDouble job returned 228.0\n");
					builder.append("The callinsRetString job returned abc\n");
					builder.append("The callinsRetByteArray job returned 0121\n");
					String oneThreadLoop = builder.toString();
					for (int i = 0; i < (numOfIterations - 1); i++)
						builder.append(oneThreadLoop);
					String oneThreadRun = builder.toString();
					builder.setLength(0);
					builder.append("All threads created!\n");
					builder.append("All threads started!\n");
					builder.append("All threads died!\n");
					builder.append("Cumulative output:\n");
					for (int i = 0; i < numOfThreads; i++) {
						builder.append("Thread " + i + ":\n");
						builder.append(oneThreadRun);
						builder.append("\n");
					}
					return builder.toString();
				}
			}
		};

		writeTestCase(testCases, 20);
	}

	/*
	 * Test 21: Ensure that setting null arguments to valid values inside an M label does not modify their values on the
	 * Java side regardless of the direction specified.
	 */
	public static void getTest21() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.ALL_CALLIN_ARG_TYPES_LENGTH * GTMType.ALL_CALLIN_RET_TYPES_LENGTH * GTMType.DIRECTIONS_LENGTH];
		int testCasesIndex = 0;

		for (int dirIndex = 0; dirIndex < GTMType.DIRECTIONS_LENGTH; dirIndex++) {
			final int direction = GTMType.DIRECTIONS[dirIndex];

			for (int argIndex = 0; argIndex < GTMType.ALL_CALLIN_ARG_TYPES_LENGTH; argIndex++) {
				final int argType = GTMType.ALL_CALLIN_ARG_TYPES[argIndex];
				final String argInit = J.genArgInitNull("x", GTMType.JAVA_ARG_TYPE_NAMES[argIndex]);

				testCases[testCasesIndex++] = new TestCase("Test21", TestCase.CALL_IN, GTMType.JAVA_STRING,
						new GTMType(M.genVarName(false), direction, argType)) {
					@Override
					public String getMCode() {
						StringBuilder mCode = new StringBuilder();
						mCode.append(mHeader);
						mCode.append("\tset ret=$get(" + args[0].name + ",\"Empty return\")\n");
						if (argType == GTMType.JAVA_STRING || argType == GTMType.GTM_STRING ||
							argType == GTMType.JAVA_BYTE_ARRAY || argType == GTMType.GTM_BYTE_ARRAY)
							mCode.append("\tset " + args[0].name + "=\"123\"\n");
						else
							mCode.append("\tset " + args[0].name + "=123\n");
						mCode.append("\tquit ret\n");
						return mCode.toString();
					}

					@Override
					public String getJavaCode() {
						StringBuilder builder = new StringBuilder();
						builder.append(javaHeader);
						builder.append("\t\t" + argInit + "\n");
						builder.append("\t\ttry {\n");
						builder.append("\t\t\tSystem.out.println(GTMCI.doStringJob(\"" + name + "\"));\n");
						builder.append("\t\t\tSystem.out.println(\"The arg is now \" + (x == null ? \"null\" : \"not null\"));\n");
						builder.append("\t\t} catch (Exception e) {\n");
						builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
						builder.append("\t\t}\n");
						builder.append("\t}\n");
						return builder.toString();
					}

					@Override
					public String getJavaResponse() {
						return	"Empty return\n" +
							"The arg is now null\n";
					}
				};
			}
		}

		writeTestCase(testCases, 21);
	}

	/*
	 * Test 22: Like in test 10, ensure that MUPIP STOP terminates the GT.M instance, but do the process
	 * synchronization with locks instead of globals.
	 */
	public static void getTest22() throws Exception {
		TestCase[] testCases = new TestCase[] {
			new TestCase("Test22", TestCase.CALL_IN, GTMType.VOID) {
				@Override
				public String getMCode() {
					// fires up a child job and terminates it
					String childControl = M.genVarName(true);
					String childLock = M.genVarName(true);

					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append("\tif ($data(" + childControl + ")) do\n");
					mCode.append("\t.\twrite \"This is a child process!\",!\n");
					mCode.append("\t.\tlock +" + childLock + "\n");
					mCode.append("\t.\tfor  hang 1\n");
					mCode.append("\tset " + childControl + "=1\n");
					mCode.append("\twrite \"This is a parent process!\",!\n");
					mCode.append("\tjob ^test22\n");
					mCode.append("\tset quit=0\n");
					mCode.append("\tfor i=1:1:60 do  quit:quit\n");
					mCode.append("\t.\tlock +" + childLock + ":1\n");
					mCode.append("\t.\tset haslock=$test\n");
					mCode.append("\t.\tif haslock lock -" + childLock + " hang 1\n");
					mCode.append("\t.\tif 'haslock set quit=1 quit\n");
					mCode.append("\tif i=60 write \"TEST-E-FAIL, The child did not acquire the lock in two minutes\",! quit\n");
					mCode.append("\tif $zsigproc($zjob,15)\n");
					mCode.append("\tfor i=1:1:60 quit:$zsigproc($zjob,0)  hang 1\n");
					mCode.append("\tif i=60 write \"TEST-E-FAIL, The child did not terminate in one minute\",! quit\n");
					mCode.append("\twrite \"The child process is dead!\",!\n");
					mCode.append("\tkill ^vmwpbx\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\");\n");
					builder.append("\t\t\tSystem.out.println(\"The M job has terminated!\");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getMResponse() {
					return
					"This is a parent process!\n" +
					"The child process is dead!\n";
				}

				@Override
				public String getJavaResponse() {
					return "The M job has terminated!\n";
				}
			}
		};

		writeTestCase(testCases, 22);
	}

	/*
	 * Test 23: Verify that an error is issued if the routine or label from the call-in table is not found.
	 */
	public static void getTest23() throws Exception {
		int numOfCases = 2;

		TestCase[] testCases = new TestCase[numOfCases];

		for (int codeCase = 0; codeCase < numOfCases; codeCase++) {
			final int codeIndex = codeCase;

			testCases[codeIndex] = new TestCase("Test23", TestCase.CALL_IN, GTMType.VOID) {
				@Override
				public String getMCode() {
					return mHeader + "\tquit\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					if (codeIndex == 0)
						return "150373978,(Call-In),%YDB-E-ZLINKFILE, Error while zlinking \"abc\",%YDB-E-FILENOTFND, File abc.m not found,%YDB-E-FILENOTFND, File abc.o not found\n";
					else
						return "150373122,(Call-In),%YDB-E-JOBLABOFF, Label and offset not found in created process\n";
				}

				@Override
				public String getTableContent() {
					StringBuilder builder = new StringBuilder();
					builder.append(name);
					builder.append("\t:void ");
					builder.append(codeIndex == 0 ? name : "abc");
					builder.append("^");
					builder.append(codeIndex == 0 ? "abc" : testName.toLowerCase());
					builder.append("()\n");
					return builder.toString();
				}
			};
		}

		writeTestCase(testCases, 23);
	}

	/*
	 * Test 24: Ensure that IO arguments come back intact if never modified in M.
	 */
	public static void getTest24() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.ALL_CALLIN_ARG_TYPES_LENGTH];

		for (int argIndex = 0; argIndex < GTMType.ALL_CALLIN_ARG_TYPES_LENGTH; argIndex++) {
			final int argType = GTMType.ALL_CALLIN_ARG_TYPES[argIndex];

			final String argInit;

			switch (argType) {
			case GTMType.GTM_BOOLEAN:
				argInit = J.genArgInit("x", "GTMBoolean", "true");
				break;
			case GTMType.GTM_INTEGER:
				argInit = J.genArgInit("x", "GTMInteger", "1");
				break;
			case GTMType.GTM_LONG:
				argInit = J.genArgInit("x", "GTMLong", "1L");
				break;
			case GTMType.GTM_FLOAT:
				argInit = J.genArgInit("x", "GTMFloat", "1.0F");
				break;
			case GTMType.GTM_DOUBLE:
				argInit = J.genArgInit("x", "GTMDouble", "1.0");
				break;
			case GTMType.GTM_STRING:
				argInit = J.genArgInit("x", "GTMString", "\"1\"");
				break;
			case GTMType.GTM_BYTE_ARRAY:
				argInit = J.genArgInit("x", "GTMByteArray", "new byte[]{1}");
				break;
			case GTMType.JAVA_STRING:
				argInit = J.genArgInit("x", "String", "\"1\"");
				break;
			case GTMType.JAVA_BYTE_ARRAY:
				argInit = "byte[] x = new byte[]{1};";
				break;
			case GTMType.JAVA_BIG_DECIMAL:
				argInit = J.genArgInit("x", "BigDecimal", "1");
				break;
			default:
				argInit = null;
			}

			testCases[argIndex] = new TestCase("Test24", TestCase.CALL_IN, GTMType.VOID,
					new GTMType(M.genVarName(false), GTMType.INPUT_OUTPUT, argType)) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\t" + argInit + "\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\", x);\n");
					String isSame;
					switch (argType) {
					case GTMType.GTM_BOOLEAN:
						isSame = "x.value";
						break;
					case GTMType.GTM_INTEGER:
					case GTMType.GTM_LONG:
					case GTMType.GTM_FLOAT:
					case GTMType.GTM_DOUBLE:
						isSame = "(x.value == 1)";
						break;
					case GTMType.GTM_STRING:
						isSame = "x.value.equals(\"1\")";
						break;
					case GTMType.GTM_BYTE_ARRAY:
						isSame = "(x.value.length == 1 && x.value[0] == 1)";
						break;
					case GTMType.JAVA_STRING:
						isSame = "x.equals(\"1\")";
						break;
					case GTMType.JAVA_BYTE_ARRAY:
						isSame = "(x.length == 1 && x[0] == 1)";
						break;
					case GTMType.JAVA_BIG_DECIMAL:
						isSame = "(x.equals(BigDecimal.ONE))";
						break;
					default:
						isSame = "false";
					}
					builder.append("\t\t\tSystem.out.println(\"The value is \" + (" + isSame + " ? \"same\" : \"not same\"));\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return "The value is same\n";
				}
			};
		}

		writeTestCase(testCases, 24);
	}

	/*
	 * Test 25: Ensure that skipping the returned value does not result in SIG-11s or similar failures.
	 */
	public static void getTest25() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.ALL_CALLIN_RET_TYPES_LENGTH - 1];
		int testCasesIndex = 0;

		for (int retIndex = 0; retIndex < GTMType.ALL_CALLIN_RET_TYPES_LENGTH; retIndex++) {
			final int retType = GTMType.ALL_CALLIN_RET_TYPES[retIndex];
			final String retTypeWord;

			if (retType == GTMType.VOID)
				continue;
			else
				retTypeWord = GTMType.ALL_CALLIN_RET_TYPE_WORDS[retIndex];

			testCases[testCasesIndex++] = new TestCase("Test25", TestCase.CALL_IN, retType) {
				@Override
				public String getMCode() {
					return mHeader + "\tquit\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					if (retType == GTMType.JAVA_BYTE_ARRAY)
						builder.append("\t\t\tSystem.out.println(new String(GTMCI.do" + retTypeWord + "Job(\"" + name + "\")));\n");
					else
						builder.append("\t\t\tSystem.out.println(GTMCI.do" + retTypeWord + "Job(\"" + name + "\"));\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return "150374554,(Call-In),%YDB-E-QUITARGREQD, Quit from an extrinsic must have an argument" + "\n";
				}
			};
		}

		writeTestCase(testCases, 25);
	}

	/*
	 * Test 26: Ensure that assigning an intrinsic special variable to an I/O M argument does not cause segmentation
	 * violations due to attempted operations on read-only memory.
	 */
	public static void getTest26() throws Exception {
		final int numOfArgs = 31;

		GTMType[] args = new GTMType[numOfArgs];
		final String varNameBase = M.genVarName(false);
		for (int i = 1; i <= numOfArgs; i++)
			args[i - 1] = new GTMType(varNameBase + i, GTMType.INPUT_OUTPUT, GTMType.GTM_STRING);

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test26", TestCase.CALL_IN, GTMType.VOID, args) {
				@Override
				public String getMCode() {
					return mHeader +
						"\tzshow \"I\":a\n" +
						"\tset length=+$order(a(\"I\",\"\"),-1)\n" +
						"\tfor i=1:1:" + numOfArgs + " set setCommand=\"" + varNameBase + "\"_i_\"=\"_$piece(a(\"I\",$random(length)+1),\"=\",1) set @setCommand\n" +
						"\tquit\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					for (int i = 0; i < numOfArgs; i++)
						builder.append("\t\t\t" + J.genArgInit(args[i].name, GTMType.JAVA_ARG_TYPE_NAMES[args[i].type], "\"abcdefg\"") + "\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\"");
					for (int i = 0; i < numOfArgs; i++)
						builder.append(", " + args[i].name);
					builder.append(");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}
			}
		};

		writeTestCase(testCases, 26);
	}

	/*
	 * Test 27: Verify that changing the value of a final I/O argument does not cause any complaints
	 * from the JVM in cases when we even allow changes for the chosen type.
	 */
	public static void getTest27() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.ALL_CALLIN_ARG_TYPES_LENGTH];
		int testCasesIndex = 0;

		for (int argIndex = 0; argIndex < GTMType.ALL_CALLIN_ARG_TYPES_LENGTH; argIndex++) {
			final int type = GTMType.ALL_CALLIN_ARG_TYPES[argIndex];

			testCases[testCasesIndex++] = new TestCase("Test27", TestCase.CALL_IN, GTMType.VOID,
					new GTMType(M.genVarName(false), GTMType.INPUT_OUTPUT, type)) {
				@Override
				public String getMCode() {
					return mHeader +
						"\tset " + args[0].name + "=12\n" +
						"\tquit\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");

					String argInit = "\t\t\tfinal " + GTMType.JAVA_ARG_TYPE_NAMES[type] + " " +
						args[0].name + " = new " + GTMType.JAVA_ARG_TYPE_NAMES[type];
					String value = "0";

					if ((type == GTMType.JAVA_STRING) || (type == GTMType.GTM_STRING) || (type == GTMType.JAVA_BIG_DECIMAL))
						value = "\"" + value + "\"";
					else if (type == GTMType.GTM_BYTE_ARRAY)
						value = "new byte[]{" + value + "}";
					else if (type == GTMType.GTM_BOOLEAN)
						value = "false";

					if (type == GTMType.JAVA_BYTE_ARRAY)
						argInit += "{0};\n";
					else
						argInit += "(" + value + ");\n";

					builder.append(argInit);
					builder.append("\t\t\tGTMCI.doVoidJob(\"" + name + "\", " + args[0].name + ");\n");

					if (type == GTMType.JAVA_BYTE_ARRAY)
						builder.append("\t\t\tSystem.out.println(" + args[0].name + "[0]);\n");
					else if (type == GTMType.GTM_BYTE_ARRAY)
						builder.append("\t\t\tSystem.out.println(" + args[0].name + ".value[0]);\n");
					else
						builder.append("\t\t\tSystem.out.println(" + args[0].name + ");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					String retValue;
					if (type == GTMType.GTM_BOOLEAN)
						retValue = "true";
					else if (type == GTMType.GTM_FLOAT || type == GTMType.GTM_DOUBLE)
						retValue = "12.0";
					else if (type == GTMType.JAVA_STRING || type == GTMType.JAVA_BIG_DECIMAL)
						retValue = "0";
					else if (type == GTMType.JAVA_BYTE_ARRAY || type == GTMType.GTM_BYTE_ARRAY)
						retValue = "49";
					else
						retValue = "12";
					return retValue + "\n";
				}
			};
		}

		writeTestCase(testCases, 27);
	}

	public static void writeTestCase(TestCase[] testCases, int number) {
		TestCase.write("Test" + number,
			testCases,
			destDir + "com/test/Test" + number + ".java",
			destDir + "test" + number + ".m",
			destDir + "Test" + number + ".ci",
			destDir + "Test" + number + ".cmp");
	}

	public static void main(String[] args) throws Exception {
		destDir = args[0];
		getTest1();
		getTest2();
		getTest3();
		getTest4();
		getTest5();
		getTest6();
		getTest7();
		getTest8();
		getTest9();
		getTest10();
		getTest11();
		getTest12();
		getTest13();
		getTest14();
		getTest15();
		getTest16();
		getTest17();
		getTest18();
		getTest19();
		getTest20();
		getTest21();
		getTest22();
		getTest23();
		getTest24();
		getTest25();
		getTest26();
		getTest27();
	}
}
