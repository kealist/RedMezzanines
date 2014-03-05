Red [
	Title:   "Red general purpose functions"
	Author:  "Gregg Irwin"
	File: 	 %general.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
]

;-------------------------------------------------------------------------------
;-- Including some general funcs inline for ease of testing right now.

;any-block?: func [value] [
;	any [block? :value  paren? :value  any-path? :value]
;]
;
;any-path?: func [value] [
;	any [path? :value  set-path? :value  get-path? :value  lit-path? :value]
;]
;
;any-string?: func [value] [
;	any [
;		string? :value  file? :value
;		; email? :value  tag? :value  url? :value
;	]
;]
;
;negate: func [n [number!]] [n * -1]
;
;series?: func [value] [
;	any [any-block? :value  any-string? :value]
;]

;-------------------------------------------------------------------------------

; This originally came from Gabriele Santilli IIRC.
also: func [
	"Returns the first value, but also evaluates the second."
	value1 [any-type!]
	value2 [any-type!]
][
	get/any 'value1
]
first-of: :also	; I've never liked ALSO as a name, but this may not be better.
first-of-two: :also

comment: func [value [any-type!]] []

;decr: func [
;	"Decrements a value or series index."
;	'word [word!] "Must refer to a number or series value"
;	/by "Change by this amount"
;		value
;][
;	;_incr-by word negate value
;	either series? get word [
;		set word skip get word negate any [value 1]
;	][
;		set word subtract get word any [value 1]
;	]
;]
;decr: function [
;	"Decrements a value or series index."
;	'word [word!] "Must refer to a number or series value"
;	/by "Change by this amount"
;		value
;][
;	incr/by :word negate value
;]
; Do we want to use a lit-word! arg here. I know they make things look
; clean for the user, but they also make it a pain to use expressions.
decr: function [
	"Decrements a value or series index."
	'word [word!] "Must refer to a number or series value"
	/by "Change by this amount"
		value
][
	;!! Note that ADD is the op, because we always negate the value.
	op: either series? get word [:skip] [:add]
	set word op get word negate any [value 1]
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

found?: func [
	"Returns true if value is not NONE."
	value
][
	not none? :value
]

;incr: func [
;	"Increments a value or series index."
;	'word [word!] "Must refer to a number or series value"
;	/by "Change by this amount"
;		value
;][
;	;_incr-by word value
;	either series? get word [
;		set word skip get word any [value 1]
;	][
;		set word add get word any [value 1]
;	]
;]
; Do we want to use a lit-word! arg here. I know they make things look
; clean for the user, but they also make it a pain to use expressions.
incr: function [
	"Increments a value or series index."
	'word [word!] "Must refer to a number or series value"
	/by "Change by this amount"
		value
][
	op: either series? get word [:skip] [:add]
	set word op get word any [value 1]
]

;_incr-by: func [
;	"Increment a value, or step a series, by a value."
;	'word [word!] "Must refer to a number or series value"
;	value "Change by this amount"
;][
;	either series? get word [
;		set word skip get word value
;	][
;		set word add get word value 1
;	]
;]

quote: func ['value] [:value]
; Should this use a get-word param?
quote: func [:value] [:value]

set?: func [
	"Returns true if a word is not unset! or none!."
	'word [word!]
][
	all [value? word  not none? get word]
]

true?: func [
	"Returns true if an expression can be used as true."
	value [any-type!]
][
	not not :value
]
	
value?: func [
	"Returns true if the word has a value."
	value [any-type!]
][
	not unset? get/any value
]

words-of: function [
	"Returns all words from a function spec."
	value [function!] ; TBD: object!
][
	res: copy []
	foreach val spec-of :value [
		; TBD: What about lit/get/set-words?
		if any [word? val refinement? val] [
			append res val
		]
	]
	res
]
