Red [
	Title:   "Red math and number-related functions"
	Author:  "Gregg Irwin"
	File: 	 %math.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
]

;-------------------------------------------------------------------------------

; Aggregators are functions that allows you to compute certain results
; over unbounded series. They generally take one argument, and maintain
; state with each successive call. In the future we'll have real closures
; in REBOL.
; Added the /query refinement, but not sure I like using RETURN for it.
; Maybe an "if not query [change-state]" approach is better. Either way
; it's a bit ugly for funcs that take values because you still have to
; pass a none value even when using /query.
aggregation-ctx: context [

    set 'make-count-aggregator does [
        func [/query /local state] [
            state: [0]
            if query [return state/1]
            state/1: state/1 + 1
            state/1
        ]
    ]

    set 'make-sum-aggregator does [
        func [value /query /local state] [
            state: [0]
            if query [return state/1]
            state/1: state/1 + value
            state/1
        ]
    ]

    ; Should this have an initial value override?
    set 'make-avg-aggregator does [
        func [value /query /local state] [
            state: [count 0 sum 0]
            if query [return divide state/sum state/count]
            state/count: state/count + 1
            state/sum: state/sum + value
            divide state/sum state/count
        ]
    ]

    set 'make-min-aggregator func [
        /init init-val [number! time!] "Set the initial minimum value"
    ][
        func [value /query /local state] compose/deep [
            state: [(any [init-val 0])] 
            if query [return state/1]
            ;if init  [state/1: (init-val)]
            ; Which is nicer here, path notation, or CHANGE? I like CHANGE.
            ;   if value < state/1 [state/1: value]
            ; Or always changing?
            ;   change state min state/1 value
            if value < state/1 [change state value]
            state/1
        ]
    ]

    set 'make-max-aggregator func [
        /init init-val [number! time!]  "Set the initial maximum value"
    ][
        func [value /query /local state] compose/deep [
            state: [(any [init-val 0])] 
            if query [return state/1]
            if value > state/1 [change state value]
            state/1
        ]
    ]

    ; Need to think about how this could be generalized.
    ; Power of 2 distribution quanitzer.
    set 'make-quantize-aggregator func [/local limits] [
        limits: []
        repeat i 48 [append limits 2 ** i]
        func [value /query /local state n] [
            state: [ ; 48 slots = a range up to 2 ** 48 - 1 (256 TB).
                0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
                0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
            ]
            if query [return state]
            n: repeat i length? state [
                if value < pick limits i [break/return i]
            ]
            state/:n: state/:n + 1
            state
        ]
    ]

    ; scalar expression, lower bound, upper bound, step value
    ;
    ; A linear frequency distribution, sized by the specified range, of
    ; the values of the specified expressions. Increments the value in
    ; the highest bucket that is less than the specified expression.
    set 'make-linear-quantize-aggregator func [
        lbound ubound step /local limits
    ][
        ; Do we want to do this, or just use FOR or WHILE/UNTIL directly?
        ; This allocates space, which would be bad for large ranges, but
        ; linear quantize shouldn't be used that way anyway, right?
        limits: range/skip reduce [lbound ubound] step
        func [value /query /local state n lim] compose/deep [
            lim: [(copy limits)]
            state: [(head insert/dup copy [] 0 length? limits)]
            if query [return state]
            n: repeat i length? state [
                if value < pick lim i [break/return i]
            ]
            state/:n: state/:n + 1
            state
        ]
    ]
    
    ; normalize
    ; denormalize
    
    ; clear
    ; trunc

] ; end aggregation-ctx

;-------------------------------------------------------------------------------


;~=: :near   ; approximately equal

abs: absolute: func [n [number!]] [n * sign? n]

;arccosine
;arcsine
;arctangent

average: func [
    "Returns the average of all values in a block."
    block [any-block!]
][
	if empty? block [return none]
	divide  sum block  length? block
]
avg: :average

;cosine

; Moved to %general.red
;decr: func [
;	"Decrement a value by 1."
;	'word [word!]
;	/by "Change by this amount"
;		value
;][
;	set word subtract get word any [value 1]
;]

;div: func [
;    "Returns the quotient and remainder of a divided by b."
;    a [number! money! time!]
;    b [number! money! time!]
;][
;    reduce [round/down a / b   remainder a b]
;]

even?: func [n [number!]] [zero? remainder n 2]
;even?_a: func [n [number!]] [0 = remainder n 2]
;even?_b: func [n [number!]] [divisible? n 2]

evenly-divisible?: func [a b] [0 = remainder a b]

; Moved to %general.red
;incr: func [
;	"Increment a value by 1."
;	'word [word!]
;	/by "Change by this amount"
;		value
;][
;	set word add get word any [value 1]
;]

limit: function [
	"Returns a value constrained between two boundaries (inclusive)."
	value
	bound-1
	bound-2
][
	lower: min bound-1 bound-2
	upper: max bound-1 bound-2
	max lower min value upper
]

;linear-interpolate: func [
;    src-min  [number!]
;    src-max  [number!]
;    dest-min [number!]
;    dest-max [number!]
;    value    [number!]
;][
;    add dest-min ((value - src-min) / (src-max - src-min) * (dest-max - dest-min))
;]
;for i 0 10 1 [print [i linear-interoplate 0 10 -1 0 i]]
;repeat i 10 [print [i linear-interoplate 0 200 20 50 i]]

;log-10
;log-2
;log-e

;make-linear-interpolater: func [
;    src-min  [number!]
;    src-max  [number!]
;    dest-min [number!]
;    dest-max [number!]
;    /local src-range dest-range scale
;][
;    src-range: src-max - src-min
;    dest-range: dest-max - dest-min
;    scale: dest-range / src-range
;    func [value [number!]] compose/deep [
;        add (dest-min) (to paren! compose [value - (src-min)]) * (scale)
;    ]
;]
; lin-terp-fn: make-linear-interpolater 0 10 -1 0
; for i 0 10 1 [print [i lin-terp-fn i]]
; lin-terp-fn: make-linear-interpolater 0 200 20 50
; for i 0 200 20 [print [i lin-terp-fn i]]

max: maximum: func [a b] [either a >= b [a] [b]]

min: minimum: func [a b] [either a <= b [a] [b]]


; MOD and MODULO were developed by Ladislav Mecir during the design of ROUND.
; Need to check with him if we have permission to use them in Red.
mod: func [
	"Compute a nonnegative remainder of A divided by B."
	; In fact the function tries to find the remainder,
	; that is "almost non-negative"
	; Example: 0.15 - 0.05 - 0.1 // 0.1 is negative,
	; but it is "almost" zero, i.e. "almost non-negative"
;	[catch]
	a [number!] ; money! time!
	b [number!] "Must be nonzero." ; money! time!
	/local r
][
	; Compute the smallest non-negative remainder
	all [negative? r: remainder a b   r: r + b]
	; Use abs a for comparisons
	a: abs a
	; If r is "almost" b (i.e. negligible compared to b), the
	; result will be r - b. Otherwise the result will be r
	either all [a + r = (a + b)  positive? r + r - b] [r - b] [r]
]

modulo: func [
	"MOD but negligible values (compared to A and B) are rounded to zero."
	;[catch]
	a [number!] ;money! time!
	b [number!] "Absolute value will be used" ; money! time!
	/local r
][
	; Coerce B to a type compatible with A
	any [number? a  b: make a b]
	; Get the "accurate" MOD value
	r: mod a abs b
	; If the MOD result is "near zero", w.r.t. A and B,
	; return 0--the "expected" result, in human terms.
	; Otherwise, return the result we got from MOD.
	either any [a - r = a   r + b = b] [make r 0] [r]
]

;near?: func [
;	"Returns true if the values are <= 1E-15 apart."
;	value1 [number!] ;[number! money! time!]
;	value2 [number!] ;[number! money! time!]
;	/within  "Specify an alternate maximum difference (epsilon)"
;		e [number! money! time!] "The epsilon value"
;][
;	e: abs any [e  to value1 1E-15]
;	e >= abs value1 - value2
;]

negate: func [n [number!]] [n * -1]

negative?: func [n [number!]] [n < 0]

odd?: func [n [number!]] [1 = remainder n 2]

positive?: func [n [number!]] [n > 0]

; Overflows go to zero!
power: func [base [number!] exp [number!] /local result] [
	result: 1
	while [exp <> 0] [
		if odd? exp [
			result: result * base
			exp: exp - 1
		]
		exp: exp / 2
		base: base * base
	]
	result
]

product: function [
    "Returns the product of all values in a block."
    values [block!]
][
	result: 1
;No ATTEMPT yet, for trying to match block datatype.	
;	result: any [
;		attempt [make pick values 1 1]
;		attempt [add 1 (0 * pick values 1)]
;		1
;	]
	foreach value reduce values [result: result * value]
	result
]

remainder: func [
	a [number!]
	d [number!] "Divisor"
][
	;a - (d * (a / d))
	a - (a / d * d)
]

;round

sign?: func [
	"Returns sign of number as 1, 0, or -1 (to use as a multiplier)."
	number [number!]
][
	case [
		positive? number [1]
		negative? number [-1]
		zero? number [0]
	]
]
; Whether we can do this depends on if the numeric datatypes support
; the comparison actions or POSITIVE?/NEGATIVE?/ZERO? actions.
sign?: func [
	"Returns sign of number as 1, 0, or -1 (to use as a multiplier)."
	n [number!]
][
	case [
		n > 0 [1]
		n < 0 [-1]
		n = 0 [0]
	]
]

;sine
;square-root

sum: function [
    "Returns the sum of all values in a block."
    values [block!]
] [
	result: 0
;No ATTEMPT yet, for trying to match block datatype.	
;	result: any [
;		attempt [make pick values 1 0]
;		attempt [0 * pick values 1]
;		0
;	]
	foreach value reduce values [result: result + value]
	result
]

;tangent

zero?: func [n [number!]] [n = 0]
; Kaj de Vos
;zero?: routine [
;	value			[integer!]
;	return:			[logic!]
;][
;	zero? value
;]
