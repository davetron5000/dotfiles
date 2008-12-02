" Vim filetype plugin file
" Language:	Java
" Maintainer:	Dan Sharp <vimuser@crosswinds.net>
" Last Change:	Wed, 19 Sep 2001 16:27:23 Eastern Daylight Time
" Current version is at http://sites.netscape.net/sharppeople/vim/ftplugin
"
" Modified by Dave 
" sets up ant as the make program
" Creates the function SwitchMakePrg which will switch between ant and make.
" For ant builds, you can set g:ant_target to the ant target you want.
" You may also set g:ant_buildfile to the buildfile you want to use (defualt
" is to -find build.xml


" Only do this when not done yet for this buffer
"if exists("g:did_ftplugin")
"  finish
"endif

" Don't load another plugin for this buffer
let g:did_ftplugin = 1

" Go ahead and set this to get decent indenting even if the indent files
" aren't being used.
setlocal cindent

"---------------------
" From Johannes Zellner <johannes@zellner.org>
setlocal cinoptions+=j1		" Correctly indent anonymous classes
setlocal cinoptions+=+0		" Align continuation lines with the previous line
"---------------------

" For filename completion, prefer the .java extension over the .class
" extension.
set suffixes+=.class
" Automatically add the java extension when searching for files, like with gf
" or [i
setlocal suffixesadd=.java

" Set 'formatoptions' to break comment lines but not other lines,
" and insert the comment leader when hitting <CR> or using "o".
setlocal fo-=t fo+=croql

" Set 'comments' to format dashed lists in comments
setlocal com& com^=sO:*\ -,mO:*\ \ ,exO:*/  " Behaves just like C

" Make sure the continuation lines below do not cause problems in
" compatibility mode.
set cpo-=C

" Use the javadoc lookup instead of man
"set keywordprg=/usr/bin/javadoclookup.pl
" configure for ant instead of make
"set makeprg=ant\ buildclient
compiler maven2

let g:maven_pom=g:project_root . "/main/trunk/pom.xml"
let &makeprg="mvn -f " . g:maven_pom . " install"
" Change the :browse e filter to primarily show Java-related files.
if has("gui_win32") && !exists("b:browsefilter")
    let  b:browsefilter="Java Files (*.java)\t*.java\n" .
		\	"Properties Files (*.prop*)\t*.prop*\n" .
		\	"Manifest Files (*.mf)\t*.mf\n" .
		\	"All Files (*.*)\t*.*\n"
endif
