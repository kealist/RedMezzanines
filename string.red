Red [
	Title:   "Red string functions"
	Author:  "Gregg Irwin"
	File: 	 %string.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
]

;-------------------------------------------------------------------------------

CH_ALPHA: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
CH_LOWER: "abcdefghijklmnopqrstuvwxyz"
CH_UPPER: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

alpha-char?: func [char [char!]] [find/case CH_ALPHA char]
lower-char?: func [char [char!]] [find/case CH_LOWER char]
upper-char?: func [char [char!]] [find/case CH_UPPER char]

to-lower-char: func [char [char!]] [
	either upper-char? char [pick CH_LOWER index? upper-char? char] [char]
]
to-upper-char: func [char [char!]] [
	either lower-char? char [pick CH_UPPER index? lower-char? char] [char]
]

;-------------------------------------------------------------------------------


enclose: func [
	"Returns a string with leading and trailing values added."
	string [any-string!] "(modified)"
	values [series!] "A single value can be used"
][
	rejoin [form first values  string  form last values]
]
;enbrace:   func [s] [enclose s "{}"]
;enbracket: func [s] [enclose s "[]"]
;enparen:   func [s] [enclose s "()"]
;enquote:   func [s] [enclose s {"}]
;entag:     func [s] [enclose s "<>"]

; Intentional bad name, but the idea of an optimized ENCLOSED? for chars makes sense.
enchared?: func [
	"Returns true if a string begins and ends with leading and trailing characters."
	string [any-string!]
	chars  [char! series!] "A single value can be used"
][
	all [
		(length? string) >= 2
		#"^"" = first string
		#"^"" = last string
	]
]

enclosed?: func [
	"Returns true if a string begins and ends with leading and trailing values."
	string [any-string!]
	values [series!] "A single value can be used"
][
	all [
		(length? string) >= length? rejoin values
		begins-with? string form first values
		ends-with? string form last values
	]
]

lowercase: function [
	"Returns the string with all alpha characters changed to uppercase."
	string [any-string!] "(modified)"
	/part "Limit the number of changes"
		limit [integer!]
][
	repeat i any [limit  length? string] [
		if upper-char? ch: pick string i [poke string i to-lower-char ch]
	]
	string
]

lowercase?: func [
	val [char! string!]
][
	either char? val [
		to logic! all [(ch >= #"a") (ch <= #"z")]
	][
		strict-equal? val lowercase copy val
	]
]

quoted?: func [
	"Returns true if a string is enclosed in double quotes."
	string [any-string!]
][
	; This is naive, and probably deserves an optimized handler.
	;enclosed? s [#"^""]
	all [
		(length? string) >= 2
		#"^"" = first string
		#"^"" = last string
	]
]

uppercase: function [
	"Returns the string with all alpha characters changed to uppercase."
	string [any-string!] "(modified)"
	/part "Limit the number of changes"
		limit [integer!]
][
	repeat i any [limit  length? string] [
		if lower-char? ch: pick string i [poke string i to-upper-char ch]
	]
	string
]

uppercase?: func [
	val [char! string!]
][
	either char? val [
		to logic! all [(ch >= #"A") (ch <= #"Z")]
	][
		strict-equal? val uppercase copy val
	]
]

