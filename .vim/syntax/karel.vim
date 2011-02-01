" Vim syntax file
" Language: Karel the robot for rkarel
" Maintainer: David Copeland
"

if exists("b:current_syntax")
    finish
endif
syn keyword karelCommand MOVE TURNLEFT PICKBEEPER PUTBEEPER
syn keyword karelControl  IF ELSE 
syn keyword karelLoops ITERATE WHILE
syn keyword karelDefine DEFINE
syn keyword karelExtra WORLD PROGRAM
syn keyword karelConditionsPos facing_east facing_north facing_south facing_west front_clear left_clear on_beeper right_clear
syn keyword karelConditionsNeg not_facing_east not_facing_north not_facing_south not_facing_west not_on_beeper right_not_clear front_not_clear left_not_clear
syn match karelComment  "#.*$"
syn match karelSubName  "'[^']*'"
syn match karelIterateSize "[0-9][0-9]*\.TIMES"
"syn region karelWorld start="<<END" end="END"

hi def link karelCommand Function
hi def link karelComment Comment
hi def link karelControl Conditional
hi def link karelDefine Define
hi def link karelExtra Include
hi def link karelLoops Repeat
hi def link karelIterateSize Special
hi def link karelConditionsPos Constant
hi def link karelConditionsNeg Constant
hi def link karelSubName String
"hi def link karelWorld Typedef
