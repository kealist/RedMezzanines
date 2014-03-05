Red [
	Title:   "Red help functions"
	Author:  "Gregg Irwin"
	File: 	 %help.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
]

;ajoin: func [
;	;"Reduces and joins a block of values into a new string."
;	"Returns a string made from reduced values, with no spaces between values."
;	block [block!]
;][
;	; If we FORM the block, it doesn't crash, but we get spaces
;	; between values, which AJOIN in REBOL does not have.
;	make string! reduce block
;]

any-function?: func [value] [
	any [function? :value  op? :value  action? :value  native? :value]
]

;collect: function [/local keep out] [
;	;keep: context [
;		keep: func [value /only] [
;			either only [append/only out :value] [append out :value]
;			:value
;		]
;	;]
;	func [
;		"Collects block evaluation, at KEEP calls, into a result block."
;		body [block!] "Block to evaluate"
;		/into ;"Collect into 'output arg, rather than a new block"
;			output [series!]
;	][
;		out: default any [output copy []]
;		do bind/copy body 'keep
;		out
;	]
;]

default: func [
	"Set a value for the word if the word has no value."
	'word
	value
][
	if not all [value? :word  not none? get word] [set/any word value]
	;any [set? :word  set/any word get/any value]
	get/any word
]

;default: func [
;	"Set a word to a default value if it hasn't been set yet."
;	'word [word! set-word! lit-word!] "The word (use :var for word! values)"
;	:value "The value expression"
;][
;	any [set? :word  set word do value]
;	get/any word
;]

join: func [
	"Returns a copy of a value, with other values appended."
	value "Base value; copied if series, formed otherwise"
	rest  "Value or block of values"
][
	repend either series? :value [copy value] [form :value] :rest
]

max: maximum: func [a b] [either a >= b [a] [b]]
min: minimum: func [a b] [either a <= b [a] [b]]


repend: func [
	"Appends a reduced value to a series; returns series head."
	series [series!]
	value
	/only "Insert block types as single values (overrides /part)"
	;/part "TBD: In R3, but not R2"
][
	either only [
		append/only series reduce :value
	][
		append series reduce :value
	]
]

;set?: func [
;	"Returns true if a word is not unset! or none!."
;	'word [word! set-word! lit-word!] "The word (use :var for word! values)"
;][
;	to logic! all [value? word  not none? get word]
;]

value?: func [
	"Returns true if the word has a value."
	value [any-type!]
][
	not unset? get/any value
]

words-of: function [
	"Returns all words from a function spec."
	value [function!]
][
	res: copy []
	foreach val spec-of :value [
		if any [word? val refinement? val] [
			append res val
		]
	]
	res
]

;-------------------------------------------------------------------------------

test-fn: func ["Doc" a "AA" b [block!] c [string!] "CC" /local x y] []

;-------------------------------------------------------------------------------

arg-info: func [
	"Returns name, type, and doc-string for the given word in the spec."
	spec [block!] word [word!]
][
	pos: find spec word
	if pos [
		type-doc: reduce either block? pos/2 [
			either string? pos/3 [
				; type  doc
				[pick pos 2  pick pos 3]
			][
				; type  no-doc
				[pos/2 none]
			]
		][
			either string? pos/2 [
				; no-type  doc
				[none pos/2]
			][
				; no-type  no-doc
				[none none]
			]
		]
		reduce [word type-doc/1 type-doc/2]
	]
]

arg-words: function [
	"Returns all the arg words and refinements for a function."
	fn [any-function!]
][
	words: words-of :fn 
	either pos: find words /local [head clear pos] [words]
]

doc-string: function [
	"Returns the doc string for a function."
	fn [any-function!]
][
	either string? res: pick spec-of :fn 1 [res] [none]
]
doc-string?: function [
	"Returns true if the function has a doc string."
	fn [any-function!]
][
	string? pick spec-of :fn 1
]

;-------------------------------------------------------------------------------

about: does [
	print ["Red for" system/platform system/version]
]

HELP-USAGE: {
Use HELP or ? to view built-in docs for functions, values 
for contexts, or all values of a given datatype:

	help append
	? system
	? function!

To search in function specs, use a string:

	? "tail"
}
TBD-HELP-USAGE: {
To browse online web documents:

	help/online append

Other development and debugging functions:

	??    - Print a word and its value
	docs  - Open online documentation
	probe - Print a value (molded)
	source <func> - Show source code of func
	what  - Show a list of known functions

Other information:

	about   - See general program info
	bugs    - Open bug database
	changes - Show online change history
	license - Show user license
	upgrade - Check for newer versions
	usage   - Show command line options
}

?: help: function [
	'word [any-type!]
	/online
][
	case [
		unset? get/any word [print HELP-USAGE]
		online [
			; create URL for word's help
			; browse url
			print "Online help TBD"
		]
		'else [
			; Now we know we're either going to reflect help for a word,
			; find all values of a given datatype, probe a context, or 
			; search for a string in all doc strings.
		
			type-name: func [value] [
				value: mold type? :value
				clear back tail value
				append copy either find "aeiou" first value ["an "] ["a "] value
			]
		;	if not any [word? :word  path? :word] [
		;		print [mold :word "is" type-name :word]
		;		exit
		;	]
		
			value: get/any :word
			spec: spec-of :value
			
			prin ["USAGE:" lf tab]
			args: arg-words :value
			either op? :value [
				;!! TBD: This crashes right now
				print [args/1 mold word args/2]
			][
				;print [mold word args]
				prin [append mold word " "]
				foreach arg args [prin [append mold arg " "]]
				print ""
			]
		
			print [
				newline "DESCRIPTION:" newline
				tab any [doc-string :value "(undocumented)"] newline newline
				tab "_" mold word "_" "is" type-name :value "value."
			]
		;	unless args: find spec-of :value any-word! [exit]
		;	clear find args /local
		
		
		;	print-args: func [label list /extra /local str] [
		;		if empty? list [exit]
		;		print label
		;		foreach arg list [
		;			str: ajoin [tab arg/1]
		;			if all [extra word? arg/1] [insert str tab]
		;			if arg/2 [append append str " -- " arg/2]
		;			if all [arg/3 not refinement? arg/1] [
		;				repend str [" (" arg/3 ")"]
		;			]
		;			print str
		;		]
		;	]
		
			print-args: function [header fn] [
				print header
				foreach arg arg-words :value [
					set [word type doc] arg-info spec arg
					str: append form tab mold word
					if doc  [append append str " -- " doc]
					if type [
						append str "  | Type: "
						append str mold type 
					]
					print str
				]
			]
			print-args [newline "ARGUMENTS:"] :value
		
		;
		;	use [argl refl ref b v] [
		;		argl: copy []
		;		refl: copy []
		;		ref: b: v: none
		;		parse args [
		;			any [string! | block!]
		;			any [
		;				set word [refinement! (ref: true) | any-word!]
		;				(append/only either ref [refl] [argl] b: reduce [word none none])
		;				any [set v block! (b/3: v) | set v string! (b/2: v)]
		;			]
		;		]
		;		print-args "^/ARGUMENTS:" argl
		;		print-args/extra "^/REFINEMENTS:" refl
		;	]
		]
	]
	
]

;??: function [
;	"Debug print a name and its molded value."
;	'word [word! path!]
;][
;	prin append form word ": "
;]
;??: func [
;    {Prints a variable name followed by its molded value. (for debugging)}
;    'name
;][
;    print either word? :name [head insert tail form name reduce [": " mold name: get name]] [mold :name]
;    :name
;]

license: does [
	print {
	Distributed under the Boost Software License, Version 1.0.
	See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
	}
]

source: function [
	"Prints the source code for a word."
	'word [word! path!]
][
    val: get/any word
	;if not value? word [print [word "undefined"] exit]
	;print head insert mold get word reduce [word ": "]
	;print ajoin [form word ":"]
	prin append form word ": "
	case [
	    function? :val [
    	    prin mold type? :val
    	    prin " "
    	    print mold spec-of :val
    	    print mold body-of :val
    	]
    	any-function? :val [
    	    prin mold type? :val
    	    prin " "
    	    print mold spec-of :val
    	    ;!! body-of crashes for natives, etc.
    	]
    	unset? :val [print "undefined"]
    	'else [print mold val]
    ]
	; body-of doesn't work yet
]

usage: does []

what: function [
    "Prints a list of known functions."
    ;'name [word! lit-word! unset!] "Optional module name"
    /args "Show arguments from spec, not doc strings"
][
	; First, build a list of function names and their associated 
	; description to print with them.
	fn-desc: copy []
	longest: 0	; Length of the longest name we've found
	foreach word system/words [
		if any-function? fn: get word [
			desc: either args [
				words: words-of :fn
				clear find words /local
				mold words
			][
				doc-str: first spec-of :fn
				either string? doc-str [doc-str] ["Undocumented"]
			]
			repend fn-desc [word desc]
			;print mold word
			; Keep track of the longest name we've found
			longest: max longest length? form word
		]
	]
	buff: copy ""
	foreach [word desc] fn-desc [
		;append/dup clear buff #" " longest
		;print [head change buff word any [desc ""]]
		print [word tab any [desc "(Undocumented)"]]
	]
	fn-desc*: :fn-desc
    buff
]

;foreach word system/words [print [mold word tab mold type? get word]]
