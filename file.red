Red [
	Title:   "Red file functions"
	Author:  "Gregg Irwin"
	File: 	 %file.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
]

at-suffix: function [
	"Returns a filespec at its suffix or tail."
	path [any-string!]
][
	any [find/last path suffix? path  tail path]
]

change-suffix: func [
	"Changes the suffix of a filespec and returns the new filespec."
	path   [any-string!] "(modified)"
	suffix [any-string!] "The new suffix"
][
	append remove-suffix path suffix
]

;clean-path

dir?: func [
	"Returns true if a filespec ends with a path marker."
	path [file! url!]
][
	true? find "/\" last path
]

dirize: func [
	"Returns a copy of a filespec with a trailing path marker."
	path [file! string! url!]
][
	path: copy path
	either slash = last path [path] [append path slash]
]

file-of: func [
	"Returns the filename portion of a filespec."
	path [any-string!]
][
	second split-path path
]

path-of: func [
	"Returns the path portion of a filespec."
	path [any-string!]
][
	first split-path path
]

remove-suffix: func [
	"Removes the suffix from a filespec."
	path [any-string!] "(modified)"
][
	head clear at-suffix path
]


; Modeled on Ladislav's implementation where it holds that
;   file = rejoin split-path file
; This does not match current REBOL behavior. It arguably 
; makes more sense, but will break code in cases like this:
; 	%/c/test/test2/ 
;	REBOL      == [%/c/test/ %test2/]
;	Ladislav's == [%/c/test/test2/ %""]
; Ladislav's func only seems to go really wrong in the case
; of ending with a slash an that's the only slash in the 
; value which return an empty path and entire filespec as 
; the target.
; Schemes (http://) don't work well either.
;split-path: func [
;	"Returns a block containing a path and target, by splitting a filespec."
;	filespec [any-string!]
;	/local target
;][
;	target: tail filespec
;	if slash = last target [decr target]
;	target: any [find/reverse/tail target slash  filespec]
;	;!! TBD: Do we want to use TO FILE! on target, once TO is in Red?
;	reduce [copy/part filespec target  copy target]
;]
;split-path: func [
;	"Returns a block containing a path and target, by splitting a filespec."
;	filespec [any-string!]
;	/local target
;][
;	either any [
;		; It's a url ending with a slash. This doesn't account for
;		; formed URLs. To do that, we would have to search for "://"
;		all [slash = last filespec]
;		;!! TBD: Need url support
;		;all [url? filespec  slash = last filespec]
;		; Only one slash, and it's at the tail.
;		all [target: find/tail filespec slash  tail? target]
;	][
;		reduce [copy filespec  clear copy %.] ; copy %"" seems to make Red unhappy when compiling
;	][
;		target: tail filespec
;		if slash = last target [decr target]
;		target: any [find/reverse/tail target slash  filespec]
;		;!! TBD: Use TO FILE! on target, once TO is in Red.
;		reduce [copy/part filespec target  copy target]
;	]
;]
split-path: func [
	"Returns a block containing a path and target."
	path [any-string!]
	/local target
][
	target: any [find/last/tail path slash   path]
	reduce [copy/part path target  to file! target]
]
;; These tests match current REBOL behavior.
;split-path-tests: compose/deep [
;	%foo 			[%./ %foo]
;	%"" 			[%./ %""]
;	%/c/rebol/tools/test/test.r [%/c/rebol/tools/test/ %test.r]
;	%/c/rebol/tools/test/       [%/c/rebol/tools/ %test/]
;	%/c/rebol/tools/test        [%/c/rebol/tools/ %test]
;	%/c/test/test2/file.x       [%/c/test/test2/ %file.x]
;	%/c/test/test2/ [%/c/test/ %test2/]
;	%/c/test/test2  [%/c/test/ %test2]
;	%/c/test        [%/c/ %test]
;	%//test         [%// %test]
;	%/test          [%/ %test]
;	%/c/            [%/ %c/]
;	%/              [%/ (none)]
;	%//             [%/ %/]
;	%.              [%./ (none)]
;	%./             [%./ (none)]
;	%./.            [%./ %./]
;	%..             [%../ (none)]
;	%../            [%../ (none)]
;	%../..          [%../ %../]
;	%../../test     [%../../ %test]
;	%foo/..         [%foo/ %../]
;	%foo/.          [%foo/ %./]
;	%foo/../.       [%foo/../ %./]
;	%foo/../bar     [%foo/../ %bar]
;	%foo/./bar      [%foo/./ %bar]
;	%/c/foo/../bar  [%/c/foo/../ %bar]
;	%/c/foo/./bar   [%/c/foo/./ %bar]
;	http://www.rebol.com/index.html [http://www.rebol.com/ %index.html]
;	http://www.rebol.com/   [http:// %www.rebol.com/]
;	http://www.rebol.com    [http:// %www.rebol.com]
;	http://         [http:/ %/]		; What should we do in this case?
;	http://..       [http:// %../]
;	http://.        [http:// %./]
;	http://../.     [http://../ %./]
;	http://../bar   [http://../ %bar]
;	http://./bar    [http://./ %bar]
;	(at %/vol/dir/file.r 6)  [%dir/ %file.r]
;]
;foreach [test result] split-path-tests [
;	if result <> actual: split-path test [
;		print [mold test 'expected mold result "but got" mold actual]
;	]
;]
;foreach [test result] split-path-tests [
;	if test <> rejoin res: split-path test [
;		print ["REJOIN quality failed:" mold test mold rejoin res]
;	]
;]


suffix?: func [
	"Returns the file extension or none."
	path [any-string!]
][
	all [
		path: find/last path #"."
		not find path slash			; can't have a slash after the suffix
		copy path
	]
]

;to-local-file
;to-rebol-file :to-red-file
;to-red-file

undirize: func [
	"Returns a copy of a filespec with no trailing path marker."
	path [file! string! url!]
][
	path: copy path
	either slash = last path [chop path] [path]
]
