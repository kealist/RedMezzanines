Red [
	Title:   "Red datatype related functions"
	Author:  "Gregg Irwin"
	File: 	 %types.red
	Tabs:	 4
;	Rights:  "Copyright (C) 2013 All Mankind. All rights reserved."
;	License: {
;		Distributed under the Boost Software License, Version 1.0.
;		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
;	}
]

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

any-word?: func [value] [
	any [
		word? :value  set-word? :value  get-word? :value  lit-word? :value
		issue? :value  refinement? :value
	]
]

number?: func [value] [
	any [
		integer? :value
		;decimal? :value  float? :value  percent? :value  money? :value
	]
]

scalar?: func [
	"Returns true if value is not a series value."
	value [any-type!]
] [
	not series? :value
]

series?: func [value] [
	any [any-block? :value  any-string? :value]
]

;-------------------------------------------------------------------------------

; TBD: auto-gen <type>? funcs
;mk-type?-func-name: func [word] [
;    ; can't make word values yet    
;]
;foreach word system/words [
;    if datatype? get :word [
;        set mk-type?-func-name word func compose/deep [
;                [
;                    (rejoin ["Returns true if the value is a " word "."])
;                    value [any-type!]
;                ] [(word) = type? :value]
;            ]
;
;        ]
;    ]
;]
;action?:	 func ["Returns true if the value is this type." value [any-type!]] [action!	= type? :value]
;block?:		 func ["Returns true if the value is this type." value [any-type!]] [block!		= type? :value]
