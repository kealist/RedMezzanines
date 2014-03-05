Red [
	Title:   "Red control functions"
	Author:  "Gregg Irwin"
	File: 	 %control.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
]

; Ladislav's CFOR func
cfor: func [  ; Not this name
	"General loop based on an initial state, test, and per-loop change."
	init [block!] "Words and initial values as spec block (local)"
	test [block!] "Continue if condition is true"
	bump [block!] "Move to the next step in the loop"
	body [block!] "Block to evaluate each time"
	/local ret
] [
	do function [] join init [

		; It should actually make a selfless object from a block spec, but
		; that's awkward to specify in mezzanine code, so just make sure
		; that the native code makes a selfless context. It is likely a bad
		; idea to catch any break or continue in the init evaluation code
		; since the loop hasn't started yet, so we might want to just send
		; them upwards. Or should we process break and ignore continue?
	
		test: bind/copy test init
		body: bind/copy body init
		bump: bind/copy bump init
	
		; We don't need a direct reference to init anymore here, but we will
		; need to make sure our new values are referenced on the stack for
		; safety in the native so they don't get collected. Those assignments
		; are metaphors for replacing the references to the blocks in the stack
		; frame slots with references to their copies.
	
		while test [set/any 'ret do body do bump get/any 'ret]
	
		; The body and bump should be evaluated separately to make sure their
		; code doesn't mix, or otherwise you'll get weird errors. And don't
		; forget to return the value from the evaluation of the body by default
		; but also process break and continue from body, test and bump, according
		; to the behavior of the while loop here.
	]
		
]

