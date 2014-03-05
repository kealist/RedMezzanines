Red [
	Title:   "Red set-related functions"
	Author:  "Gregg Irwin"
	File: 	 %sets.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
]


;difference (need more datatypes)
;difference: :series-difference  ; need to add more type support

exclude: function [
	;"Returns a unique copy of series1, excluding all values found in series2."
	"Returns the unique difference of two sets (NOT, COMPLEMENT)."
	series1 [series!]
	series2 [series!]
;	/case "Perform a case-sensitive search"
;	/skip "Treat the series as fixed size records"
;		size [integer!]
][
    res: make series1 length? series1
    foreach val series1 [
        if all [not find/only series2 val  not find/only res val] [
            append/only res val
        ]
    ]
    res
]
exclude: function [
	;"Returns a unique copy of series1, excluding all values found in series2."
	"Returns the unique difference of two sets (NOT, COMPLEMENT)."
	series1 [series!]
	series2 [series!]
;	/case "Perform a case-sensitive search"
;	/skip "Treat the series as fixed size records"
;		size [integer!]
][
    res: unique series1
    foreach val unique series2 [
        if pos: find/only res val [remove at res index? pos]
    ]
    res
]
;exclude [a b c] [a b d]
;exclude [a b d] [a b c]


intersect: function [
	"Returns the unique intersection of two sets (AND)."
	series1 [series!]
	series2 [series!]
;	/case "Perform a case-sensitive search"
;	/skip "Treat the series as fixed size records"
;		size [integer!]
][
    res: make series1 length? series1
    ;foreach val series1 ...
    foreach val unique series1 [
    ;foreach val ser: shorter unique series1 unique series2 ...
        if all [find/only series2 val  not find/only res val] [
            append/only res val
        ]
    ]
    res
]
;intersect: function [
;	"Returns the intersection of two sets (AND)."
;	series1 [series!]
;	series2 [series!]
;;	/case "Perform a case-sensitive search"
;;	/skip "Treat the series as fixed size records"
;;		size [integer!]
;][
;    res: make series1 length? series1
;    foreach val series1 [
;        if find/only series2 val [append/only res val]
;    ]
;    unique res
;]
;intersect  [a b c] [a b d]
intersect: function [
	"Returns the unique intersection of two sets (AND)."
	series1 [series!]
	series2 [series!]
;	/case "Perform a case-sensitive search"
;	/skip "Treat the series as fixed size records"
;		size [integer!]
][
    res: unique series1
    foreach val series2 [
        if not find/only res val [append/only res val]
    ]
    res
]
;intersect  [a b c] [a b d]

series-difference: function [
	"Returns the unique symmetric difference between two sets (XOR)."
	series1 [series!]
	series2 [series!]
;	/case "Perform a case-sensitive search"
;	/skip "Treat the series as fixed size records"
;		size [integer!]
][
    res: make series1 length? series1
    foreach val series1 [
        if all [not find/only series2 val  not find/only res val] [
            append/only res val
        ]
    ]
    foreach val series2 [
        if all [not find/only series1 val  not find/only res val] [
            append/only res val
        ]
    ]
    res
]
series-difference: function [
	"Returns the unique symmetric difference between two sets (XOR)."
	series1 [series!]
	series2 [series!]
;	/case "Perform a case-sensitive search"
;	/skip "Treat the series as fixed size records"
;		size [integer!]
][
    res: make series1 length? series1
    foreach val series1 [
        if not find/only series2 val [append/only res val]
    ]
    foreach val series2 [
        if not find/only series1 val [append/only res val]
    ]
    unique res
]
; series-difference [a b c] [a b d]
series-difference: function [
	"Returns the unique symmetric difference between two sets (XOR)."
	series1 [series!]
	series2 [series!]
;	/case "Perform a case-sensitive search"
;	/skip "Treat the series as fixed size records"
;		size [integer!]
][
    res: make series1 length? series1
    series1: unique series1
    series2: unique series2
    foreach val series1 [
        if not find/only series2 val [append/only res val]
    ]
    foreach val series2 [
        if not find/only series1 val [append/only res val]
    ]
    unique res
]
; series-difference [a b a c] [a b b d]

union: function [
	"Returns the unique union of two sets (OR)."
	series1 [series!]
	series2 [series!]
;	/case "Perform a case-sensitive search"
;	/skip "Treat the series as fixed size records"
;		size [integer!]
][
    unique append copy series1 series2
]
;union [a b c] [a b d]

unique: function [
	"Returns a copy of the series with duplicate values removed."
	series [series!]
;	/case "Perform a case-sensitive search"
;	/skip "Treat the series as fixed size records"
;		size [integer!]
][
    res: make series length? series
    foreach val series [
        if not find/only res val [append/only res val]
    ]
    res
]

;=== Set predicates

disjoint?: func [
	"Returns true if A and B have no elements in common; false otherwise."
	a [series! bitset!]
	b [series! bitset!]
][
	empty? intersect a b
]

intersect?: func [
	"Returns true if A and B have at least one element in common; false otherwise."
	a [series! bitset!]
	b [series! bitset!]
][
	not empty? intersect a b
]

subset?: func [
	"Returns true if A is a subset of B; false otherwise."
	a [series! bitset!]
	b [series! bitset!]
][
	empty? exclude a b
]

superset?: func [
	"Returns true if A is a superset of B; false otherwise."
	a [series! bitset!]
	b [series! bitset!]
][
	subset? b a
]

