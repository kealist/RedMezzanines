Red [
	Title:   "Red higher-order functions"
	Author:  "Gregg Irwin"
	File: 	 %hof.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
]

;-------------------------------------------------------------------------------

any-block?: func [value] [
	any [block? :value  paren? :value  any-path? :value]
]

any-string?: func [value] [
	any [
		string? :value  file? :value
		; email? :value  tag? :value  url? :value
	]
]

series?: func [value] [
	any [any-block? :value  any-string? :value]
]

;-------------------------------------------------------------------------------


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
;		; What is our "reached the end" test?
;		op: either positive? width [:tail?] [:head?]
;		if all [negative? width  tail? get word] [
;			; We got a negative width, so we're going backwards,
;			; and we're at the tail. That means we want to step
;			; back one interval to find the start of the first
;			; "record".
;			set word skip get word width
;		]
;		; When we hit the end, restore the word to the original position.
;		while [any [not op get word (set word orig  false)]] [
;			set/any 'result do body
;			set word skip get word width
;			get/any 'result
;		]
;		if all [
;			negative? width
;			divisible? subtract index? orig 1 width
;			;?? check orig = get word for BREAK support?
;		] [
;			; We got a negative width, so we're going backwards,
;			; and the above WHILE loop ended before processing
;			; the element at the head of the series. Plus we reset
;			; the word to its original position, *and* we would
;			; have landed right on the head. Because of all that,
;			; we want to process the head element.
;			set word head get word
;			set/any 'result do body
;			set word orig
;		]
;		get/any 'result
;	]
;]

incr: func [
	"Increments a value or series index."
	'word [word!] "Must refer to a number or series value"
	/by "Change by this amount"
		value
][
	;_incr-by word value
	either series? get word [
		set word skip get word any [value 1]
	][
		set word add get word any [value 1]
	]
]

value?: func [
	"Returns true if the word has a value."
	value [any-type!]
][
	not unset? get/any value
]

;-------------------------------------------------------------------------------


accumulate: function [  ; a.k.a. FOLD
	"Combines the results of a function applied to each value in a series."
	series [series!]
	fn     [any-function!] "Function taking two args: result so far and next value"
	/with "Use a different starting value than the first in the series"
    	value "Starting value; used as accumulator"
][
    default value first series
	if not with [incr series]
	foreach item series [value: fn :value :item]
]
; Has a code-injection vulnerability with get-word! parameters (R3 uses APPLY).
; R3 version based on a discussion about FOLD in AltME.

;all?: func [    ; every?
;	"Returns true if all items in the series match a test."
;	series  [series!]
;	test [datatype! any-function!] "Datatype to match, or func that returns false if test fails."
;][
;	either datatype? test [
;		parse series compose [some (test)]
;	][
;		foreach value series [
;			if not test :value [return false]
;		]
;	]
;]
; This name is too close to ALL
all?: func [    ; every?
	"Returns true if all items in the series match a test."
	series  [series!]
	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
][
	foreach value series [
		if not test :value [return false]
	]
]

;any?: func [    ; some?
;	"Returns true if any items in the series match a test."
;	series [series!]
;	test [datatype! any-function!] "Datatype to match, or func that returns true if test passes"
;][
;	either datatype? test [
;		found? find series test
;	][
;		foreach value series [
;			if test :value [return true]
;		]
;	]
;]
; This name is too close to ANY
any?: func [    ; some?
	"Returns true if any items in the series match a test."
	series [series!]
	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
][
	foreach value series [
		if test :value [return true]
	]
]

count: function [
	"Returns a count of values in a series that match a test."
	series [series!]
	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
][
	n: 0
	;foreach value series [if test :value [incr n]]
	foreach value series [if test :value [n: n + 1]]
	n
]
;b: [1 2 3 4 5 6 a b c d #e #f #g]

;collect-each: func [
;	"Removes values from a series where body returns TRUE."
;	;"Returns the series after removing all values that match a test."
;	'word [get-word! word! block!] "Word or block of words to set each time (will be local)"
;	series [series!]
;	body [block!] "Block to evaluate; return TRUE to reomve"
;	/into "Put results in out block, instead of creating a new block"
;		; TBD: make out type series!
;		out [any-block!] "Target for results, when /into is used" 
;	/local tmp
;][
;	collect/into [
;		foreach	:word series [
;			if not unset? set/any 'tmp do body [keep/only :tmp]
;		]
;	] any [out copy []]
;]
;collect-each: func [
;	"Removes values from a series where body returns TRUE."
;	;"Returns the series after removing all values that match a test."
;	'word [get-word! word! block!] "Word or block of words to set each time (will be local)"
;	series [series!]
;	body [block!] "Block to evaluate; return TRUE to reomve"
;	/into "Put results in out block, instead of creating a new block"
;		; TBD: make out type series!
;		out [any-block!] "Target for results, when /into is used" 
;	/local tmp res
;][
;	res: any [out copy []]
;	foreach	:word series [
;		if not unset? set/any 'tmp do body [append/only res :tmp]
;	]
;	res
;]
collect-each: : map-each

count-each: func [
	"Evaluates body for each value(s) in a series, returning a count of true results."
	'word [word!] "Word, or words, to set on each iteration"
	data [block!] 
	body [block!]
	/local n
] [
	n: 0
	body: bind/copy body word
	compose [
		foreach (:word) data [if do body [incr n]]
	]
	n
]
;count-each a [1 2 3] [odd? a]

;filter: func [
;	"Returns all values in a series that match a test."
;	series [series!]
;	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
;	/skip "Treat the series as fixed size records"
;		size [integer! none!]
;][
;	either empty? series [none] [
;		default size 1
;		;TBD: assert positive? size
;		collect [
;			forskip series size [
;				; Should we copy the value?
;				; Should we copy n (skip size) values?
;				; Should we have an option to return the series positions?
;				if test first series [keep first series]
;			]
;		]
;	]
;]

; Using COLLECT has a conflict with /OUT right now.
filter: function [
	"Returns all values in a series that match a test."
	series [series!]
	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
	;/out "Reverse the test, filtering out matching results"
	/out* "Reverse the test, filtering out matching results"
	;!! The local OUT in COLLECT messes with /out here
][
	collect [
		foreach value series [
			either out* [
				if not test :value [keep/only :value]
			][
				if test :value [keep/only :value]
			]
		]
	]
]

; This doesn't use COLLECT, so there is no conflict with /OUT in Red right now.
filter: function [
	"Returns all values in a series that match a test."
	series [series!]
	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
	/out "Reverse the test, filtering out matching results"
][
    result: copy []
	foreach value series [
		either out [
			if not test :value [append/only result :value]
		][
			if test :value [append/only result :value]
		]
	]
	result
]

filter: function [
	"Returns all values in a series that match a test."
	series [series!]
	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
	/out "Reverse the test, filtering out matching results"
][
    result: copy []
    ; The lambda here is like QUOTE, but it evaluates.
    ; This gets the EITHER out, at the cost of always calling OP.
    ; Red crashes when I try to build a func to do the NOT in it right now.
    op: either out [:not] [func [val] [:val]]
	foreach value series [
		if op test :value [append/only result :value]
	]
	result
]
; b: append/dup copy [] [1 b #c "d"] 15000

find-all: function [
	"Returns all positions in a series that match a test."
	series [series!]
	test [function!] "Test (predicate) to perform on each value; must take one arg" ; TBD: any-function!
][
    result: copy []
	forall series [
	    if test series/1 [append/only result series]
    ]
    result
]

;find-each

; This should return the first value that matches, but we don't have BREAK yet.
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
;			if test first pos [pos: series]
;		]
;		pos
;	]
;]
find-if: func [
	;"Finds the value in a series that matches a predicate."
	"Returns a series at the first value that matches a test."
	series [series!]
	test [function!] "Test (predicate) to perform on each value; must take two args" ; TBD: any-function!
	/skip "Treat the series as fixed size records"
		size [integer! none!]
	/local pos
][
	; FIND returns NONE if not found, but FIRST fails on NONE, so
	; we can't blindly do FIRST FIND.
	either empty? series [none] [
		default size 1
		;TBD: assert positive? size
		;TBD: Handle case if none match
		forskip series size [
			if test first series [return series]
		]
	]
]

;fold: :accumulate
;sum: func [block [any-block!]] [fold block :add]
;product: func [block [any-block!]] [fold/with block :multiply 1]
;sum-of-squares: func [block [any-block!]] [
;    fold block func [x y] [x * x + y] 0
;]

;!! Hmmm, something seems to crash the console.
;keep-each: func [
;	"Keeps only values from a series where body block returns TRUE."
;	'word [get-word! word! block!] "Word or block of words to set each time (will be local)"
;	series  [series!]
;	body  [block!] "Block to evaluate; return TRUE to collect"
;][
;    ; Can't do this until Red supports paren!
;	;remove-each :word data reduce ['not to paren! body]
;	body: head insert copy body 'not
;	remove-each :word data body
;]
;comment {
;	filter x [1 2 3] [x = 2]
;	filter x [1 2 3] [odd? x]
;	filter res [1 2 3] [odd? res]
;	filter [x y] [a 1 b 2 c 3] [all [odd? y  'c = x]]
;	filter x [(1 2) (2 3) (3 4)] [x = first [(2 3)]]
;}


map: func [
	"Evaluates a function for each value(s) in a series and returns the results."
	series [series!]
	fn [function!] "Function to perform on each value; must take one arg" ; TBD: any-function!
	/only "Insert block types as single values"
	;/skip "Treat the series as fixed size records"
		size [integer!]
][
	collect [
		foreach value series [
			keep/only fn value
		]
	]
]

; JS-like MAP. The order of args to the function is a bit odd, but is set
; up that way because we always want at least the value (if your func takes
; only one arg), the next most useful arg is the index, as you may display
; progress, and the series is there to give you complete control and match
; how JS does it. Now, should the series value be passed as the head of the
; series, or the current index, using AT?
map-js: func [
	"Evaluates a function for each value(s) in a series and returns the results."
	series [series!]
	fn [function!] "Function to perform on each value; called with value, index, and series args"
	/only "Insert block types as single values"
	/skip "Treat the series as fixed size records"
		size [integer!]
][
	collect [
		repeat i length? series [   ; use FORSKIP if we want to support /SKIP.
			keep/only fn series/:i :i :series ; :size ?
		]
	]
]
;res: map-js [1 2 3 a b c #d #e #f] :form
;res: map-js [1 2 3 a b c #d #e #f] func [v i] [reduce [i v]]
;res: map-js [1 2 3 a b c #d #e #f] func [v i s] [reduce [i v s]]
;res: map-js "Hello World!" func [v i s] [pick s i]

; Lisp-like MAP
;map: func [
;	{Maps a function to all elements of a block}
;	[throw]
;	fn   [any-function! word! path!] "Function to map over args"
;	block [block!] "Block of values to use as first function arg"
;	/with other-args [block!] "Block of sub-blocks; remaining args to function"
;	/local result blk
;] [
;	if word? :fn [fn: get fn]
;	result: make block! length? block
;	either none? other-args [
;		foreach elem block [append/only :result fn get/any 'elem]
;	][
;		fn: reduce [:fn]
;		other-args: copy/deep other-args
;		blk: make block! length? other-args
;		foreach elem block [
;			clear blk
;			foreach arg-blk other-args [
;				append/only blk pick arg-blk 1
;				remove arg-blk
;			]
;			append/only :result do compose [(fn) get/any 'elem (blk)]
;		]
;	]
;	result
;]


; From R2-forward
; MAP-EACH, minimal fast version
;map-each: function [
;	"Evaluates a block for each value(s) in a series and returns them as a block."
;	[throw]
;	'word [word! block!] "Word or block of words to set each time (local)"
;	data [block!] "The series to traverse"
;	body [block!] "Block to evaluate each time"
;] compose/deep [ ; To reduce function creation overhead to just once
;	foreach :word data reduce [
;		first [(func [output val [any-type!]] [
;			if value? 'val [insert/only tail output :val]
;			output
;		])]
;		make block! either word? word [length? data] [divide length? data length? word]
;		:do body
;	]
;]
; R3-compatible interface
; What happens if the result of the DO is unset!? For now, we'll
; ignore unset values. The example case being SPLIT, which uses
; MAP-EACH with an unset value for negative numeric vals used to
; skip in the series.
;map-each: func [
;	"Evaluates body for each value(s) in a series, returning all results."
;	'word [word!] "Word, or words, to set on each iteration"
;	data [block!] 
;	body [block!]
;	/local tmp
;] [
;	collect compose/deep [
;		foreach (:word) data [
;			;set/any 'tmp do bind/copy body (:word)
;			set/any 'tmp do body
;			if value? 'tmp [keep/only :tmp]
;		]
;	]
;]

; COLLECT doesn't work here yet.
;map-each: func [
;	"Evaluates body for each value(s) in a series, returning all results."
;	'word [word!] "Word, or words, to set on each iteration"
;	data [block!] 
;	body [block!]
;	/local tmp
;] [
;	;body: bind/copy body :word
;	collect compose [
;		foreach (:word) data [
;			;set/any 'tmp do bind/copy body (:word)
;			set/any 'tmp do body
;			if value? 'tmp [keep/only :tmp]
;		]
;	]
;]
;map-each a [1 2 3] [print mold a a]
; This returns:
;red>> map-each a [1 2 3] [print mold a a]
;1
;2
;3
;1
;2
;3
;1
;2
;3
; == [1 2 3 [1 2 3 [1 2 3 [1 2 3 [1 2 3 [1 2 3 [1 2 3 [1 2 3 [1 2 3 [1 ...
; Something about COLLECT isn't happy
; But this version works
map-each: func [
	"Evaluates body for each value(s) in a series, returning all results."
	'word [word!] "Word, or words, to set on each iteration"
	data [block!] 
	body [block!]
	/local tmp
] [
	res: copy []
	foreach :word data [
		if not unset? set/any 'tmp do body [append/only res :tmp]
	]
	res
]
;map-each v [1 2 3] [2 * v]

ref-name: func [
	refs [word! refinement! block!]
][
	if block? refs [
		refs: remove-each val copy refs [not any-word? val]
	]
	collect [
		; If we use TO REFINEMENT! here, then TO PATH! used on the result
		; block gives us double slashes in the path.
		foreach val compose [(refs)] [if get/any val [keep to word! val]]
	]
]
;>> fn: func [/ref /r2] [print mold ref-name [ref r2]]
;>> fn/ref/r2
;[/ref /r2]
;>> fn/ref
;[/ref]
;>> fn/r2
;[/r2]
;>> fn
;[]

refine: function [
	"Returns a path, by adding refinement(s) to a word or path."
	path [word! path!]
	refs [word! block!] "Refinements to add"
][
	refs: remove-each val copy refs [not any-word? val]
	join to path! :path refs
	;to path! append copy [find] ref-name [last tail] s v
]

;remove-each: func [
;	"Removes values from a series where body block returns TRUE."
;	"Returns the series after removing all values that match a test."
;	'word [get-word! word! block!] "Word or block of words to set each time (will be local)"
;	series [series!]
;	body [block!] "Block to evaluate; return TRUE to reomve"
;][
;	
;]

; This is just conceptual. Basic tests work, but do not consider it robust.
remove-each: function [
	"Removes values from a series where body returns TRUE."
	;"Returns the series after removing all values that match a test."
	'word  [get-word! word! block!] "Word or block of words to set each time (will be local)"
	series [series!]
	body   [block!] "Block to evaluate; return TRUE to remove"
][
	; How many words are we setting on each iteration?
	count: length? compose [(word)]
	; This is a two pass approach, pass 1 marks removal locations,
	; pass 2 removes the values from tail to head.
	marks: copy []
	i: 1
	; Pass 1: Mark locations, using INSERT so higher values are at the head.
	foreach :word series [
		if do body [insert marks i]
		i: i + count
	]
	; Pass 2: Remove values
	foreach mark marks [
		remove/part at series mark count
	]
	series
]
;b: [1 2 3 4 5 6 7 8]
;print remove-each v b [v > 4]
;b: [1 -2 3 4 5 -6 7 8]
;print remove-each v b [v < 0]
;b: [1 -2 3 4 5 -6 7 8]
;print remove-each [x y] b [y < 0]
;b: [1 -2 3 4 5 -6 7 8 9 -10 11 12 13 -14 15 16 17  -18]
;print remove-each [x y z] copy b [y < 0]
