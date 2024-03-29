" Vim syntax file
" Language   : Scala (http://scala-lang.org/)
" Maintainers: Stefan Matthias Aust, Julien Wetterwald
" Last Change: 2007 June 13
" Revision   : $Id$
"        $URL$

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case match
syn sync minlines=50

" most Scala keywords
syn keyword scalaKeyword abstract case catch do else extends final finally for forSome if implicit lazy match new null override private protected requires return sealed super this throw try type while with yield
syn match scalaKeyword "=>"
syn match scalaKeyword "<-"
syn match scalaKeyword "_"

syn match scalaOperator ":\{2,\}" "this is not a type

" package and import statements
syn keyword scalaPackage package nextgroup=scalaFqn skipwhite
syn keyword scalaImport import nextgroup=scalaFqn skipwhite
syn match scalaFqn "\<[._$a-zA-Z0-9,]*" contained nextgroup=scalaFqnSet
syn region scalaFqnSet start="{" end="}" contained

" boolean literals
syn keyword scalaBoolean true false

" definitions
syn keyword scalaDef def nextgroup=scalaDefName skipwhite
syn keyword scalaVal val nextgroup=scalaValName skipwhite
syn keyword scalaVar var nextgroup=scalaVarName skipwhite
syn keyword scalaClass class nextgroup=scalaClassName skipwhite
syn keyword scalaObject object nextgroup=scalaClassName skipwhite
syn keyword scalaTrait trait nextgroup=scalaClassName skipwhite
syn match scalaDefName "[^ =:;([]\+" contained nextgroup=scalaDefSpecializer skipwhite
syn match scalaValName "[^ =:;([]\+" contained
syn match scalaVarName "[^ =:;([]\+" contained 
syn match scalaClassName "[^ =:;(\[]\+" contained nextgroup=scalaClassSpecializer skipwhite
syn region scalaDefSpecializer start="\[" end="\]" contained contains=scalaDefSpecializer
syn region scalaClassSpecializer start="\[" end="\]" contained contains=scalaClassSpecializer

" type constructor (actually anything with an uppercase letter)
syn match scalaConstructor "\<[A-Z][_$a-zA-Z0-9]*\>" nextgroup=scalaConstructorSpecializer
syn region scalaConstructorSpecializer start="\[" end="\]" contained contains=scalaConstructorSpecializer

" method call
syn match scalaRoot "\<[a-zA-Z][_$a-zA-Z0-9]*\."me=e-1
syn match scalaMethodCall "\.[a-z][_$a-zA-Z0-9]*"ms=s+1

" type declarations in val/var/def
syn match scalaType ":\s*\(=>\s*\)\?[._$a-zA-Z0-9]\+\(\[[^]]*\]\+\)\?\(\s*\(<:\|>:\|#\|=>\)\s*[._$a-zA-Z0-9]\+\(\[[^]]*\]\+\)*\)*"ms=s+1

" comments
syn match scalaTodo "[tT][oO][dD][oO]" contained
syn match scalaLineComment "//.*" contains=scalaTodo
syn region scalaComment start="/\*" end="\*/" contains=scalaTodo
syn case ignore
syn include @scalaHtml syntax/html.vim
unlet b:current_syntax
syn case match
syn region scalaDocComment start="/\*\*" end="\*/" contains=scalaDocTags,scalaTodo,@scalaHtml keepend
syn region scalaDocTags start="{@\(link\|linkplain\|inherit[Dd]oc\|doc[rR]oot\|value\)" end="}" contained
syn match scalaDocTags "@[a-z]\+" contained

syn match scalaEmptyString "\"\""

" multi-line string literals
syn region scalaMultiLineString start="\"\"\"" end="\"\"\"" contains=scalaUnicode
syn match scalaUnicode "\\u[0-9a-fA-F]\{4}" contained

" string literals with escapes
syn region scalaString start="\"[^"]" skip="\\\"" end="\"" contains=scalaStringEscape " TODO end \n or not?
syn match scalaStringEscape "\\u[0-9a-fA-F]\{4}" contained
syn match scalaStringEscape "\\[nrfvb\\\"]" contained

" symbol and character literals
syn match scalaSymbol "'[_a-zA-Z0-9][_a-zA-Z0-9]*\>"
syn match scalaChar "'[^'\\]'\|'\\.'\|'\\u[0-9a-fA-F]\{4}'"

" number literals
syn match scalaNumber "\<\(0[0-7]*\|0[xX]\x\+\|\d\+\)[lL]\=\>"
syn match scalaNumber "\(\<\d\+\.\d*\|\.\d\+\)\([eE][-+]\=\d\+\)\=[fFdD]\="
syn match scalaNumber "\<\d\+[eE][-+]\=\d\+[fFdD]\=\>"
syn match scalaNumber "\<\d\+\([eE][-+]\=\d\+\)\=[fFdD]\>"

" xml literals
syn match scalaXmlTag "<[a-zA-Z]\_[^>]*/>" contains=scalaXmlQuote,scalaXmlEscape,scalaXmlString
syn region scalaXmlString start="\"" end="\"" contained
syn match scalaXmlStart "<[a-zA-Z]\_[^>]*>" contained contains=scalaXmlQuote,scalaXmlEscape,scalaXmlString
syn region scalaXml start="<\([a-zA-Z]\_[^>]*\_[^/]\|[a-zA-Z]\)>" matchgroup=scalaXmlStart end="</\_[^>]\+>" contains=scalaXmlEscape,scalaXmlQuote,scalaXml,scalaXmlStart,scalaXmlComment
syn region scalaXmlEscape matchgroup=scalaXmlEscapeSpecial start="{" matchgroup=scalaXmlEscapeSpecial end="}" contained contains=TOP
syn match scalaXmlQuote "&[^;]\+;" contained
syn match scalaXmlComment "<!--\_[^>]*-->" contained

syn sync fromstart

" map Scala groups to standard groups
hi link scalaKeyword Keyword
hi link scalaPackage Include
hi link scalaImport Include
hi link scalaBoolean Boolean
hi link scalaOperator Normal
hi link scalaNumber Number
hi link scalaEmptyString String
hi link scalaString String
hi link scalaChar String
hi link scalaMultiLineString String
hi link scalaStringEscape Special
hi link scalaSymbol Special
hi link scalaUnicode Special
hi link scalaComment Comment
hi link scalaLineComment Comment
hi link scalaDocComment Comment
hi link scalaDocTags Special
hi link scalaTodo Todo
hi link scalaType Type
hi link scalaTypeSpecializer scalaType
hi link scalaXml String
hi link scalaXmlTag Include
hi link scalaXmlString String
hi link scalaXmlStart Include
hi link scalaXmlEscape Normal
hi link scalaXmlEscapeSpecial Special
hi link scalaXmlQuote Special
hi link scalaXmlComment Comment
hi link scalaDef Keyword
hi link scalaVar Keyword
hi link scalaVal Keyword
hi link scalaClass Keyword
hi link scalaObject Keyword
hi link scalaTrait Keyword
hi link scalaDefName Function
hi link scalaDefSpecializer Function
hi link scalaClassName Special
hi link scalaClassSpecializer Special
hi link scalaConstructor Special
hi link scalaConstructorSpecializer scalaConstructor

let b:current_syntax = "scala"

