Red [
	Title:   "Red comparison functions"
	Author:  "Gregg Irwin"
	File: 	 %compare.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
]


between?: func [
	"Returns TRUE if value is between the two boundaries (inclusive)."
	value
	bound-1
	bound-2
	;/exclusive "Exclude boudanry values"
][
	all [value >= min bound-1 bound-2  value <= max bound-1 bound-2]
;    either exclusive [
;     	all [value > min bound-1 bound-2  value < max bound-1 bound-2]
;    ][
;	    all [value >= min bound-1 bound-2  value <= max bound-1 bound-2]
;	][
]


longer: func [
	"Returns the longer of two series."
	a [series!] b [series!]
][
	;pick reduce [a b] longer? a b
	get/any pick [a b] longer? a b
]
longer-of:   :longer
pick-longer: :longer

longer?: func [
	"Returns true if A is longer than B."
	a [series!] b [series!]
][
	greater? length? a length? b
]
more?:    :longer?
more-in?: :longer?


; MIN and MAX should probably be here



shorter?: func [
	"Returns true if A is shorter than B."
	a [series!] b [series!]
][
	lesser? length? a length? b
]
fewer?:   :shorter?
less-in?: :shorter?

shorter: func [
	"Returns the shorter of two series."
	a [series!] b [series!]
][
	;pick reduce [a b] shorter? a b
	get/any pick [a b] shorter? a b
]
pick-shorter: :shorter
shorter-of:   :shorter


