Red [
	Title:   "Red series functions"
	Author:  "Gregg Irwin"
	File: 	 %series.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
]

;-------------------------------------------------------------------------------
;-- Including some general funcs inline for ease of testing right now.

any-block?: func [value] [
	any [block? :value  paren? :value  any-path? :value]
]

any-function?: func [value] [
	any [function? :value  op? :value  action? :value  native? :value]
]

any-path?: func [value] [
	any [path? :value  set-path? :value  get-path? :value  lit-path? :value]
]

any-string?: func [value] [
	any [
		string? :value  file? :value
		; email? :value  tag? :value  url? :value
	]
]

default: func [
	"Set a value for the word if the word is not set or is none."
	'word
	value
][
	if not all [value? :word  not none? get word] [
		set word :value
	]
	;TBD: get-word args support not in place yet.
	;if not set? :word [set word :value]
	get word
]

divisible?: func [a b] [0 = remainder a b]

negate: func [n [number!]] [n * -1]

negative?: func [n [number!]] [n < 0]

positive?: func [n [number!]] [n > 0]

remainder: func [
	a [number!]
	d [number!] "Divisor"
][
	a - (d * (a / d))
]

series?: func [value] [
	any [any-block? :value  any-string? :value]
]

value?: func [
	"Returns true if the word has a value."
	value [any-type!]
][
	not unset? get/any value
]

zero?: func [n [number!]] [n = 0]

;-------------------------------------------------------------------------------

; We have an abundance of JOINing funcs now. How do we justify all
; of them, and make the intent and behavior of each one clear?
; Red doesn't support this yet. Crash message says "not implemented".
ajoin: func [
	;"Reduces and joins a block of values into a new string."
	"Returns a string made from reduced values, with no spaces between values."
	block [block!]
][
	; If we FORM the block, it doesn't crash, but we get spaces
	; between values, which AJOIN in REBOL does not have.
	make string! reduce block
]

;alter	; Does anyone use it?

;red>> fn: func [n] [either n = 0 [print "done"] [print n fn n - 1]]
;== func [n][either n = 0 [print "done"] [print n fn n - 1]]
;red>> fn 4
;4
;3
;2
;1
;done
; Quick recursion test works, but recursive array call fails. Maybe due to locals?
array: func [
	"Makes and initializes a block of of values (NONE by default)."
	size [integer! block!] "Size or block of sizes for each dimension"
	/initial "Specify an initial value for elements"
		value "For each item: called if a func, deep copied if a series"
	/local result more-sizes
][
	if block? size [
		size: first size
		if tail? more-sizes: next size [more-sizes: none]
		if not integer? size [
			; throw error, integer expected
		]
	]
	result: copy [] ; make block! size
	case [
		;!! This crashes Red console right now.
		;block? more-sizes [
		;	loop size [append/only result array/initial more-sizes :value]
		;]
		series? :value [
			loop size [append/only result copy/deep value]
		]
		any-function? :value [
			loop size [append/only result value]
		]
		'else [
			append/dup result value size
		]
	]
	result
]

begins-with?: func [
	"Returns true if the series begins with the value; false otherwise."
	series [series!]
	value
	/only
	;/case
][
	either only [
		found? find/match/only series value
	][
		found? find/match series value
	]
]

; TBD: ACTION change
; POKE doesn't work on strings yet
; JS calls this SPLICE
;change: func [series value /part length] [
;	if all [length  length <> 1] [remove/part next series (length - 1)]
;	poke series 1 value		; = change/only
;]
change: func [
    series 
    value
    /part
        length
    /only
][
   	remove/part series any [length 1]
    either only [
        insert/only series value
    ][        
    	insert series value
    ]
]

change-all: func [
	"Change each value in the series by applying a function to it"
	series  [series!]
	fn      [any-function!] "Function that takes one arg"
][
	forall series [change series fn first series]
	series
]

chop: func [
	"Removes the last value in a series; returns series head."
	series [series!] "(modified)"
	/part "Specify the number of values to remove, or new tail position."
		length [number! series!]
][
	head either series? length [
		remove/part series length
	][
		remove/part skip tail series negate abs any [length 1]
	]
]

collect: func [
	"Returns a block of values collected when KEEP is called."
	body [block!]
	/into "Put results in out block, instead of creating a new block"
		; TBD: make out type series!
		out [any-block!] "Target for results, when /into is used" 
	/local keep
][
	keep: func [value /only] [
		either only [append/only out :value] [append out :value]
		:value
	]
	out: any [out copy []]
	do bind/copy body 'keep
	out
]

;collect-at: func [
;	"Returns a block of values collected at the given value as a set-word."
;    ;[throw]
;    'word
;	body [block!]
;	/into "Put results in out block, instead of creating a new block"
;		out [any-block!] "Target for results, when /into is used" 
;    /only "Insert series results as series"
;    /local fn 
;] [
;    fn: func [val] compose [
;        (pick [append append/only] not only) out get/any 'val
;        get/any 'val
;    ]
;	out: any [out copy []]
;    body: replace/all body to set-word! word fn
;    do body
;    out
;]

contains?: func [
	"Returns true if the series contains the value."
	series  [series! none!]
	value   [any-type!] "Treated as a single value if a block"
][
	not none? find/only series value
]


; This could also be done by adding a /SKIP refinement to INSERT.
delimit: func [
	;[throw catch]
	"Insert a delimiter between series values."
	series [series!] "(modified)"
	delim "The delimiter to insert between items"
	/skip "Treat the series as fixed size records" ; Overrides system/words/skip
		size [integer!] ;"The number of items between delimiters (default is 1)"
][
	; By default, delimiters go between each item.
	; MAX catches zero and negative sizes.
	size: max 1 any [size 1]
	; If we aren't going to insert any delimiters, return the series.
	if size + 1 > length? series [return series]
	; We don't want a delimiter at the beginning.
	incr/by series size
	; Use size+n because we're inserting a delimiter on each pass,
	; and need to skip over that as well. If we're inserting a
	; series into a string, we have to skip the length of that
	; series. i.e. the delimiter value is more than a single item
	; we need to skip.
	incr/by size any [
		all [any-string? series  series? delim  length? delim]
		all [any-string? series  length? form delim]
		1
	]
	forskip series size [
		insert/only series either series? delim [copy delim] [delim]
	]
	series
]
; >> make-csv: func [block] [rejoin delimit copy block #","]
; >> make-csv ['name 'rank 'serial-number]
; == "name,rank,serial-number"
;
; >> make-parse-OR: func [block] [delimit copy block '|]
; >> make-parse-OR [yes no maybe]
; == [yes | no | maybe]
;
; >> make-name-val-lines: func [block] [form delimit/skip copy block newline 2]
; >> print make-name-val-lines ["name:" 'Gregg "rank:" 'private "serial-number:" #0000]
; name: Gregg
; rank: private
; serial-number: 0000
comment {
	; empty series and delimiter
	print mold delimit "" ""
	; empty series
	print mold delimit "" ","
	; empty delimiter
	print mold delimit "123" ""
	; delimiter same length as series
	print mold delimit "123" "..."
	; delimiter longer than series
	print mold delimit "123" "......"
	; delimiter same as series
	x: "x" print mold delimit x x
	; skip size longer than series
	print mold delimit/skip "12345" #"," 10
	; skip size same as series length
	print mold delimit/skip "12345" #"," 5
	; skip size same as series length - 1
	print mold delimit/skip "12345" #"," 4
	; skip size of zero
	print mold delimit/skip "12345" #"," 0

	print mold delimit "12345" #","
	print mold delimit/skip "12345" #"," 1
	print mold delimit/skip "12345" #"," 2
	print mold delimit/skip "12345" #"," 3
	print mold delimit/skip "123456" #"," 3
	print mold delimit/skip "1234567" "..." 3
	print mold delimit "1234567" [a b]
	print mold delimit/skip "1234567" [a b] 3
	print mold delimit [a b c d e f] '|
	print mold delimit/skip [a b c d e f] '| 2
	print mold delimit [a b c d e f] none
	;print mold delimit [a b c d e f] print 'x  ; can't use unset as a delimiter
	print mold delimit [a b c d e f] [1 2]
	print mold delimit [a b c d e f] "12"

	print mold delimit make list! [a b c d e f] '|

	print mold delimit [a b c d e f] does [1]

	; trim decimals for this to be generalized
	fmt-int: func [str [string!]] [
		if 3 >= length? str [return str]
		reverse delimit/skip reverse str #"," 3
	]
	print mold fmt-num "123456789"
	print mold fmt-num "12345678"
	print mold fmt-num "1234567"
	print mold fmt-num "123456"
	print mold fmt-num "12345"
	print mold fmt-num "1234"
	print mold fmt-num "123"
	print mold fmt-num "12"
	print mold fmt-num "1"
	print mold fmt-num ""

	insert-sep-commas: func [str] [
		str: any [find str "."  tail str]
		str: skip str -3
		while [not head? str] [
			insert str #","
			str: skip str -3
		]
	]
	fmt-int: func [str [string!]] [
		insert-sep-commas str
	]
	print mold fmt-num "123456789"
	print mold fmt-num "12345678"
	print mold fmt-num "1234567"
	print mold fmt-num "123456"
	print mold fmt-num "12345"
	print mold fmt-num "1234"
	print mold fmt-num "123"
	print mold fmt-num "12"
	print mold fmt-num "1"
	print mold fmt-num ""
}


;drop: :remove

dupe: func [
	"Returns a value repeated count times in a block."
	value
	count [integer!]
	/str "Return a string, rather than a block, if /into is not used"
	/into "Put results in out, instead of creating a new block"
		out [series!] "Target for results, when /into is used"
][
	default out make either str [""] [[]] count
	insert/dup out value count
]


ends-with?: func [
	"Returns true if the series ends with the value; false otherwise."
	series [series!]
	value
	/only
	;/case
	/local pos
][
	pos: either only [
		find/last/tail/only series value
	][
		find/last/tail series value
	]
	either found? pos [tail? pos] [false]
]

;extract (in progress, need to determine required feature parity)
extract: function [
	"Returns values extracted from a series at regular intervals."
	series [series!]
	width [integer!] "Interval size"
	/index "Extract at offset from interval start"
		pos [number!] "Index offset"
	/fill "Override NONE as a fill value"
		fill-val "Fill value"
	/into "Put results in out block, instead of creating a new block"
		out [series!] "Target block for results, when /into is used"
	/local len val
][
	either zero? width [
		any [out  make series 0]
	][
		; Negative widths walk the series in reverse.
		len: either positive? width [
			divide length? series width
		] [
			divide index? series negate width
		]
		default pos 1
		if all [not fill  any-string? out] [fill-val: copy ""]
		default out make series len
		forskip series width [
			if none? set/any 'val pick series pos [set/any 'val fill-val]
			out: append/only out :val	; TBD: change to INSERT/ONLY (Why?)
		]
	]
	either into [out] [head out]
]
;blk: [1 2 3 4 5 6]
;extract blk 2

; Opposite of remove-each. Like Lisp's FILTER/remove-if-not.
;filter: keep-each: func [
;	"Keeps only values from a series where body block returns TRUE."
;	'word [get-word! word! block!] "Word or block of words to set each time (will be local)"
;	data  [series!] "Series to traverse"
;	body  [block!]  "Block to evaluate. Return TRUE to collect."
;] [
;	;remove-each :word data join [not] to paren! body
;	remove-each :word data reduce ['not to paren! body]
;]
;comment {
;	filter x [1 2 3] [x = 2]
;	filter x [1 2 3] [odd? x]
;	filter res [1 2 3] [odd? res]
;	filter [x y] [a 1 b 2 c 3] [all [odd? y  'c = x]]
;	filter x [(1 2) (2 3) (3 4)] [x = first [(2 3)]]
;}


;?? What is the use case, or example for this R3 function? i.e., why DO a 
;	body? That seems more like a MAP func, but with possible side effects.
find-all: function [
	"Find all occurrences of a value in a series."
	'series [word!]
	value
	body [block!] "Evaluated for each matching value"
][
	either not series? orig: get series [none] [
		while [any [set series find get series :value (set series orig false)]] [
			do body
			set series next get series
		]
	]
]
; This returns a block of series positions, where REMOVE-EACH, and
; my inverse of it (KEEP-EACH or my old KEEP-IF) return the values.
find-all: function [
	"Find all occurrences of a value in a series."
	'series [word!]
	value
][
	either not series? orig: get series [none] [
		collect [
			while [any [set series find get series :value (set series orig false)]] [
				keep/only get series
				set series next get series
			]
		]
	]
]

;find-each: function [
;	"Find all occurrences of mulitple values in a series."
;	series [word!]
;	values [any-block!]
;][
;]

; Moved to %hof.red
;find-if: func [
;	;"Finds the value in a series that matches a predicate."
;	"Returns a series at the last value that matches a test."
;	series [series!]
;	test [function!] "Test (predicate) to perform on each value; must take two args" ; TBD: any-function!
;	/skip "Treat the series as fixed size records"
;		size [integer! none!]
;	/local pos
;][
;	; FIND returns NONE if not found, but FIRST fails on NONE, so
;	; we can't blindly do FIRST FIND.
;	either empty? series [none] [
;		default size 1
;		;TBD: assert positive? size
;		;TBD: Handle case if none match
;		pos: series
;		forskip series size [
;			if test first series first pos [pos: series]
;		]
;		pos
;	]
;]

find-max: func [
	"Finds the largest value in a series"
	series [series!]
	/skip "Treat the series as fixed size records"
		size [integer!]
][
	find-if/skip series :greater? size
]
;find-max: func [
;	"Finds the largest value in a series"
;	series [series!]
;	/skip "Treat the series as fixed size records"
;		size [integer!]
;	/local pos
;][
;	either empty? series [none] [
;		default size 1
;		;TBD: assert positive? size
;		pos: series
;		forskip series size [
;			if greater? first series first pos [pos: series]
;		]
;		pos
;	]
;]

find-min: func [
	"Finds the smallest value in a series"
	series [series!]
	/skip "Treat the series as fixed size records"
		size [integer!]
][
	find-if/skip series :lesser? size
]
;find-min: func [
;	"Finds the smallest value in a series"
;	series [series!]
;	/skip "Treat the series as fixed size records"
;		size [integer!]
;	/local pos
;][
;	either empty? series [none] [
;		default size 1
;		;TBD: assert positive? size
;		pos: series
;		forskip series size [
;			if lesser? first series first pos [pos: series]
;		]
;		pos
;	]
;]

first+: func [
	"Return first value in a series, and increments the series index."
	'word [word!] "Must refer to a series (series index modified)."
][
	first-of  first word  incr word
]

flatten: func [
    "Returns a block, with all sub-blocks replaced by their contents."
    block [any-block!] "(modified)"
][
	forall block [
		if block? block/1 [change/part block block/1 1]
	]
	block
]

; FORALL is native in Red
;forall: func [
;	"Evaluates a block at every position in a series."
;	'word [word!] "Word referring to the series to traverse (modified)"
;	body [block!] "Body to evaluate at each position"
;][
;	forskip :word 1 body
;]

; This doesn't work like R3 in how negative widths work. But R3
; is a bit inconsistent itself:
;	>> tb: tail blk: [1 2 3 4 5 6]
;	== []
;	>> forskip tb -2 [print mold tb]
;	[5 6]
;	[3 4 5 6]
;	[1 2 3 4 5 6]
;	>> tbb: back tb
;	== [6]
;	>> forskip tbb -2 [print mold tbb]
;	[6]
;	[4 5 6]
;	[2 3 4 5 6]
;	>> forskip tb -2 [print mold tb]
;	[5 6]
;	[3 4 5 6]
;	[1 2 3 4 5 6]
; i.e. if at the tail, it steps back before doing the body, but
; if not at the tail (tbb), it does the body before stepping.
; This code matches the tbb case, but not the tb (tail) case.
; We miss the head element by bailing out when we get there,
; and we process the empty tail.
;forskip: func [
;	"Evaluates a block at regular intervals in a series."
;	'word [word!] "Word referring to the series to traverse (modified)"
;	width [integer!] "Interval size (width of each skip)"
;	body  [block!] "Body to evaluate at each position"
;	/local orig result op
;][
;	either zero? width [none] [
;		; TBD: assert word refs series
;		; Store original position in series, so we can restore it.
;		orig: get word
;		op: either positive? width [:tail?] [:head?]
;		; When we hit the end, restore the word to the original position.
;		while [any [not op get word (set word orig  false)]] [
;			set/any 'result do body
;			set word skip get word width
;			get/any 'result
;		]
;	]
;]
; This doesn't work like R3 in how negative widths work.
forskip: func [
	"Evaluates a block at regular intervals in a series."
	'word [word!] "Word referring to the series to traverse (modified)"
	width [integer!] "Interval size (width of each skip)"
	body  [block!] "Body to evaluate at each position"
	/local orig result op
][
	either zero? width [none] [
		; TBD: assert word refs series
		; Store original position in series, so we can restore it.
		orig: get word
		; What is our "reached the end" test?
		op: either positive? width [:tail?] [:head?]
		if all [negative? width  tail? get word] [
			; We got a negative width, so we're going backwards,
			; and we're at the tail. That means we want to step
			; back one interval to find the start of the first
			; "record".
			set word skip get word width
		]
		; When we hit the end, restore the word to the original position.
		while [any [not op get word (set word orig  false)]] [
			set/any 'result do body
			set word skip get word width
			get/any 'result
		]
		if all [
			negative? width
			divisible? subtract index? orig 1 width
			;?? check orig = get word for BREAK support?
		] [
			; We got a negative width, so we're going backwards,
			; and the above WHILE loop ended before processing
			; the element at the head of the series. Plus we reset
			; the word to its original position, *and* we would
			; have landed right on the head. Because of all that,
			; we want to process the head element.
			set word head get word
			set/any 'result do body
			set word orig
		]
		get/any 'result
	]
]
;tbb: back tb: tail blk: [1 2 3 4 5 6]
;forskip blk 2 [print mold blk]
;forskip tb -2 [print mold tb]
;forskip tbb -2 [print mold tbb]

; This version works like R3 (and what seems natural to me), but
; it's a bit ugly.
;forskip: func [
;	"Evaluates a block at regular intervals in a series."
;	'word [word!] "Word referring to the series to traverse (modified)"
;	width [integer!] "Interval size (width of each skip)"
;	body  [block!] "Body to evaluate at each position"
;	/local orig result
;][
;	either zero? width [none] [
;		; TBD: assert word refs series
;		; Store original position in series, so we can restore it.
;		orig: get word
;		either positive? width [
;			while [any [not tail? get word (set word orig  false)]] [
;				set/any 'result do body
;				set word skip get word width
;				get/any 'result
;			]
;		][
;			; We got a negative width, so we're going backwards.
;			; That means we want to step back one interval to find
;			; the start of that "record".
;			set word skip get word width
;			until [
;				set/any 'result do body
;				set word skip get word width
;				head? get word
;			]
;			; The loop ended when we hit the head, but we didn't 
;			; process the value there, so we have to do it now.
;			;!! This won't keep their spot if they BREAK though.
;			set/any 'result do body
;			set word orig
;			get/any 'result
;		]
;	]
;]


join: func [
	"Returns a copy of a value, with other values appended."
	value "Base value; copied if series, formed otherwise"
	rest  "Value or block of values"
][
	repend either series? :value [copy value] [form :value] :rest
]

last?: func [
	"Returns true if a series is at its last value."
	series [series!]
][
	1 = length? series
]

lengths: func [
	"Returns a block of lengths, one for each value in a series."
	series [series!] "Block of series values to match up"
][
	map series :length?
]

;map-each        native!   Evaluates a block for each value(s) in a seri...

match-up: func [
	"Returns a block of n-value blocks with corresponding elements from each series."
	series [series!] "Block of series values to match up"
][
	collect [
		repeat i pick-max map series :length? [
			keep/only collect [
				repeat j length? series [
					keep/only series/:i/:j
				]
			]
		]
	]
]

;maximum-of		See: FIND-MAX
;minimum-of		See: FIND-MIN

min-and-max: func [series [series!]] [
	reduce [pick-min series  pick-max series]
]

;move            function! Move a value or span of values in a series.

nth: function [
	"Returns the series where the Nth instance of a value is found, or NONE."
	series	 [series! none!]
	value 	 [any-type!]
	n		 [integer!] "Must be positive"
][
	; My old version uses PARSE, which we don't have yet.
	i: 0
	while [all [i < n  series: find series value]] [
		incr i
		incr series
	]
	series
]


offset?: func [
	"Returns the offset between two positions, in the same or different series."
	series1 [series!]
	series2 [series!]
][
	subtract index? series2 index? series1
]

pair-up: func [
	"Returns a block of two-value blocks with corresponding elements from each series."
	a [series!]
	b [series!]
][
	collect [
		repeat i max length? a length? b [
			keep/only reduce [a/:i b/:i]
		]
	]
]
;pair-up: func [
;	"Returns a block of two-value blocks with corresponding elements from each series."
;	a [series!]
;	b [series!]
;][
;    match-up reduce [a b]
;]

pick-multi: function [
	"Returns multiple values picked from a series or other value."
	value   [series!] ; date! time! tuple! map! pair!
	indexes [any-block!] "Block of PICK-compatible index values"
][
	collect [
		foreach index indexes [keep/only pick value index]
	]
;    collect/into [
;    	foreach index indexes [keep/only pick series index]
;    ] make series length? indexes
]

; Do we want to give them just the lead value, even if they
; /skip, or can they even /skip with the pick* name?
;pick-max: func [
;	"Pick the largest value in a series"
;	series [series!]
;	/skip "Treat the series as fixed size records"
;		size [integer!]
;][
;	either empty? series [none] [
;		pick find-max/skip series any [size 1] 1
;	]
;]
pick-max: func [
	"Pick the largest value in a series"
	series [series!]
	/skip "Treat the series as fixed size records"
		size [integer!]
][
	either empty? series [none] [
		either skip [
			copy/part find-max/skip series size size
		][
			pick find-max/skip series size 1
		]
	]
]
; What all do we want to do with max and min? If we have
; more than a couple options, we should make HOFs.
pick-min: func [
	"Pick the smallest value in a series"
	series [series!]
	/skip "Treat the series as fixed size records"
		size [integer!]
][
	either empty? series [none] [
		either skip [
			copy/part find-min/skip series size size
		][
			pick find-min/skip series size 1
		]
	]
]

; position-of? 
position: func [
	"Returns the series index where a value is found; NONE if value is not found."
	series	 [series! none!]
	value 	 [any-type!]
][
	index? find series value
]

;random

reform: func [
	"Returns a string made from reduced values, with spaces between values."
	;"Returns a string from reduced, formed values."
	;"Returns reduced, formed values."
	;"Returns formed, reduced values."
	value
][
	form reduce :value
]

rejoin: func [
	"Returns a new string (or same series type as block/1) made from reduced values."
	;"Returns reduced, joined values."
	;"Returns joined, reduced values."
	block [block!]
	/local op
][
	either empty? block: reduce block [block] [
		op: either series? first block [:copy] [:form]
		append op first block next block
	]
]

remold: func [
	"Returns a molded string made from reduced values, with spaces between values."
	;"Returns molded, reduced values."
	value
][
	mold reduce :value
]

;remove-each

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

;?? Add /only refinement to allow the use of blocks of values for OLD and NEW,
;   which make this work lis translit/translate by default.
;TBD: Needs CHANGE native
replace: function [
	"Replaces a search value with the replace value within the target series."
	series [series!] "Series to replace within (modified)"
	old-value "Value to be replaced (converted if necessary)"
	new-value "Value to replace with (called each time if a function)"
	/all "Replace all occurrences"  	;!! Native ALL is overridden here!
	/case "Case-sensitive replacement"  ;!! Native CASE is overridden here!
	;/tail "Return target after the last replacement position"  ;!! Native TAIL is overridden here!
][
	;orig: series
	; Make old-value match series type, except for bitset.
	if any-string? series [old-value: form :old-value]
	;!!TBD: binary
	;if binary? series [old-value: to binary! :old-value]
	len: either series? :old-value [length? :old-value] [1]
	; /all and /case checked before the while, /tail after
	done?: false
	while [
		all [
			not done?
			series: either case [find/case series :old-value] [find series :old-value]
		]
	][
		series: change/part series :new-value len
		if not all [done?: true] ;if not all [break]
	]	
	;either tail [series] [orig]
	series
]

;TBD: ACTION reverse

;reword

rotate: func [
	"Rotate values in a series."
	series [series!]
	/left   "Rotate left (the default)"
	/right  "Rotate right"
	/part
	    count [number!] "Rotate this many positions"  ; TBD series! support?
][
	range: any [all [range  range // length? series] 1]
	if any [empty? series  zero? range] [return series]
	either right [
		series: skip tail series negate range
		head insert head series take/part series range
	][
		append series take/part series range
	]
]


set-length: func [
	"Sets the length of a series, trimming or padding as necessary."
	series [series!] "(modified)"
	length [integer!]
	/with "Override default pad fill value (space for strings, none for blocks)"
		value
][
	default value either any-string? series [#" "] [none]
	if length = length? series [return series]
	either length < length? series [
		head clear skip series length
	][
		append/dup series :value subtract length length? series
	]
]

; The new PAD/JUSTIFY func might be used to implement this as well.
shift: function [
	"Shift values in a series; length doesn't change."
	series [series!]
	/left   "Shift left (the default)"
	/right  "Shift right"
	/part
	    count [number!] "Shift this many positions"  ; TBD series! support?
	/with
	    fill "Fill vacated slots with this value"
	;/local pad
][
	make-blank-value: func [type] [
		any [
			attempt [make type 0]
			attempt [make type ""]
			attempt [make type []]
			attempt [make type none]
		]
	]
	range: any [range 1]
	if any [empty? series  0 = range] [return series]
	;TBD: Add positive? check for range or have negative
	;     range values shift in the reverse direction.
	pad: dupe any [fill  make-blank-value last series] range
	either right [
		head insert head clear skip tail series negate range pad
	][
		append remove/part series range pad
	]
]

single?: :last?

;singularize: func [
;	"Returns a scalar value if the series contains only that value."
;	series [series!]
;][
;	either single? series [pick series 1] [series]
;]

slice: func [
	series
	start
	len
][
	copy/part at series start len
]

;TBD: ACTION sort

;split

sys-tail: :tail
split-at: function [
	"Split the series at a position or value, returning the two halves."
	series [series!]
	delim  "Delimiting value, or index if an integer"
	/value "Split at delim value, not index, if it's an integer"
	/tail  "Split at delim's tail; implies value"
	/last  "Split at the last occurrence of value, from the tail"
][
	copy-to: func [end] [copy/part series end]
	reduce either all [integer? delim  not any [value tail last]] [
		[copy-to delim  copy at series delim + 1]
	][
		if string? series [delim: form delim]
		; No way to apply or refine funcs in Red yet, so this is ugly.
		pos: either last [
			either tail [find/tail/last series delim] [find/last series delim]
		][
			either tail [find/tail series delim] [find series delim]
		]
		; Delimiter not found
		if none? pos [
			pos: either last [series] [sys-tail series]
		]
		[copy-to pos  copy pos]
	]
]
;red>> split-at blk 4
;== [[1 2 3 4] [5 6]]
;red>> split-at/tail/value blk 4
;== [[1 2 3 4] [5 6]]
;red>> split-at/value blk 4
;== [[1 2 3] [4 5 6]]
split-at-tests: [
	[split-at [1 2 3 4 5 6 3 7 8] 3]
	[split-at/tail [1 2 3 4 5 6 3 7 8] 3]
	[split-at/last [1 2 3 4 5 6 3 7 8] 3]
	[split-at/last/tail [1 2 3 4 5 6 3 7 8] 3]

	[split-at [1 2 3 4 5 6 3 7 8] -1]
	[split-at [1 2 3 4 5 6 3 7 8] 0]
	[split-at [1 2 3 4 5 6 3 7 8] 10]

	[split-at/last [1 2 3 4 5 6 3 7 8] -1]
	[split-at/last [1 2 3 4 5 6 3 7 8] 0]
	[split-at/last [1 2 3 4 5 6 3 7 8] 10]

	[split-at "123456378" 3]
	[split-at/tail "123456378" 3]
	[split-at/last "123456378" 3]
	[split-at/last/tail "123456378" 3]

	[split-at "123456378" #"3"]
	[split-at/tail "123456378" #"3"]
	[split-at/last "123456378" #"3"]
	[split-at/last/tail "123456378" #"3"]

	[split-at "123456378" #"/"]
	[split-at/tail "123456378" #"/"]
	[split-at/last "123456378" #"/"]
	[split-at/last/tail "123456378" #"/"]
]
foreach test split-at-tests [
	print [mold test "==" mold do test]
]

;TBD: ACTION take
take: func [
	"Removes and returns a value from a series."
	series [series! none!]
	/part "Return and remove more than one value"
		length [number! series!]
	/local result
] [
	if series [
		;!! TBD assert part length
		result: either part [copy/part series length] [first series]
		either part [remove/part series length] [remove series]
		result
	]
]

;take-max: func [
;	"Take the largest value from a series"
;	series [series!]
;	/skip "Treat the series as fixed size records"
;		size [integer!]
;][
;	either empty? series [none] [
;		either skip [
;			take/part find-max/skip series size size
;		][
;			take find-max/skip series size
;		]
;	]
;]
;
;take-min: func [
;	"Take the largest value from a series"
;	series [series!]
;	/skip "Treat the series as fixed size records"
;		size [integer!]
;][
;	either empty? series [none] [
;		either skip [
;			take/part find-min/skip series size size
;		][
;			take find-min/skip series size
;		]
;	]
;]

; Could also be called 'translit, for "transliterate"
translate: function [
	"Translates individual values in a series, from table1 to table2."
	series [series!] "(modified)"
	table1 [series!] "Values to replace, matched case-sensitively"
	table2 [series!] "If shorter than table1, NONE values may result"
] [
	repeat i length? series [
		if pos: find/case table1 series/:i [
			poke series i pick table2 index? pos
		]
	]
	series
]

transpose: func [
	"Transposes row and column values in a block of blocks."
	block [any-block!]
][
	collect [
		repeat i pick-max lengths block [
			keep/only collect [
				foreach row block [keep/only row/:i]
			]
		]
	]
]


;decr: function [
;	"Decrements a value or series index."
;	'word [word!] "Must refer to a number or series value"
;	/by "Change by this amount"
;		value
;][
;	;!! Note that ADD is the op, because we always negate the value.
;	op: either series? get word [:skip] [:add]
;	set word op get word negate any [value 1]
;]
;incr: function [
;	"Increments a value or series index."
;	'word [word!] "Must refer to a number or series value"
;	/by "Change by this amount"
;		value
;][
;	op: either series? get word [:skip] [:add]
;	set word op get word any [value 1]
;]
trim: func [
	series [series!]
	/head "Overrides HEAD func"
	/tail "Overrides TAIL func"
	; TBD: More refinements to add
][
	; Default to both head and tail if neither is specified.
	if not any [head tail] [set [head tail] true]

	; TBD: any-string?    
	vals: either string? series [" ^M^/^-^L"] [reduce [none]]
	trim-val?: func [val] [find vals val]
	;unicode-ws: \x0b\xa0\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u200b\u2028\u2029\u3000

	if head [
		tmp-ser: series
		while [all [trim-val? first tmp-ser  not tail? tmp-ser]] [
			;incr tmp-ser   ; this makes things crash
			tmp-ser: next tmp-ser
		]
		remove/part series tmp-ser
	]
	if tail [
		tmp-ser: at series length? series    ; can't use TAIL here
		while [all [trim-val? first tmp-ser  not head? tmp-ser]] [
			;decr tmp-ser
			tmp-ser: back tmp-ser
		]
		clear next tmp-ser
	]
	series	
]
; trim ""
; trim "a"
; trim " a "
; trim reduce ['a]
; trim reduce [none 'a none]
; trim reduce ['a none 'a none 'a]
; trim reduce ['a none 'a none]
; trim reduce [none 'a none 'a]

