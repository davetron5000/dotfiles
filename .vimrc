" To use this, you must define the global variable "g:project_root" to be the
" location of the root of your project.  This assumes that project is Java
" and that it contains a directory called "src" beneath it. It also assumes
" that the ant build file is in build/build.xml.  This also assumes you are
" using a custom java.vim in your ~/.vim/ftplugin directory that contains the
" following code:
"
" set efm=%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#
" if exists("g:ant_target")
"     if exists("g:ant_buildfile")
"         let &makeprg="ant -buildfile " . g:ant_buildfile . " " . g:ant_target
"     else
"         let &makeprg="ant -find build.xml " . g:ant_target
"     endif
" else
"     let &makeprg="ant -find build.xml"
" endif
"
" 

" Determine the project_root, assuming ~/Projects/jdis if not specified
" Note that if you specify "g:current_tag", it will look in
" ~/Projects/jdis.<<tagname>> if no project_root is specified.
" This can be accomplished on the vim command line via
" vim --cmd 'let g:current_tag="tagname"'
if !exists("g:project_root")
    let g:project_root="~/Projects"
    exec "cd " . g:project_root
else
    exec "cd " . g:project_root
endif
" Specify the location of the ant buildfile
if !exists("g:build_file")
    let g:ant_buildfile=g:project_root . "/build.xml"
else
    let g:ant_buildfile=g:project_root . "/" . g:build_file
endif

" This function creates an IDE that contains a left-hand vertical window with
" the file explorer in it, initially opened to your project's source
" directory.  It also contains a bottom pane that is the "quickfix" window
" which will contain error messages and grep results.
function! JavaIDE()
    " Create the quickfix window
    copen
    " Go to the main window and vertically split
    wincmd k
    " Open our project root
    exec "e " . g:project_root . "/src"
endfunction

" Config for XML editing plugin
let xml_use_xhtml = 1
let xml_no_auto_nesting = 0
let xml_tag_completion_map = ">

"yypdwwi

" Misc stuff
hi Normal guibg=black
hi Normal guifg=white
filetype plugin on
filetype indent on
syn on

set gfn=Monaco:h13:a

" Configuration
set exrc
set noequalalways
set whichwrap+=hl
set formatoptions-=t formatoptions+=croqln2
exec "set path=" . g:project_root. "/**"
set ai
set expandtab
set ts=4
set sw=4
set cindent
set wm=1
set bg=dark
set go=arb
set vb t_vb=
set nohls
"set nofoldenable
set grepprg=grep\ -rn\ $*
set suffixesadd=.ec
set keywordprg=

" Mappings
exec "map g :grep  " . g:project_root . "<Home><Right><Right><Right><Right><Right>"
exec "map G :grep <cword> " . g:project_root
exec "map  :grep <cword> " . g:project_root . "
" cd to directory of current file
map c :cd %:p:h
" kill F1
map <F1> 
" open buffer list
map b n\be
" build
map m :make
" next error
map   :cnext
" fold this line
map f !!fold -w77 -s 
" Avoid annoying ^Z minimizing to nowhere
map  
" open the IDE
map   :call JavaIDE()
"map j :InsertBothGetterSetter
map j yypcwpublic/its
" Open file implementing class under cursor in new pane
map  s:find <cword>.java
" Create canoncial equals method for base classes
map eb opublic boolean equals(Object o)
" Create canoncial equals method for derived classes
map ed opublic boolean equals(Object o)
" Put braces around one line
map b O{jo}k
" Convert an exception to a catch block
map x ^icatch (lywea pb~$a)

" This could be a function to be more flexible.  Creates a scratch buffer to
" write SQL in.
map  n:set nobuflisted

" Stuff I'm not sure about
"map   :%s/<lf>1G


" Helpful abbreviations
:ab TRY try
:ab ITER for (Iterator i = list.iterator(); i.hasNext(); )
:ab JITER for (Iterator j = list.iterator(); j.hasNext(); )
:ab CLOSEDAO if (dao != null)
:ab IF if ()
:ab FOR for (Object o: list)
:ab OLDFOR for (int i=0;i<list.length; i++)
:ab LOGGER itsLogger = Logger.getLogger(getClass().getName());
:ab LOG4J import org.apache.log4j.*;

" Abs for LaTeX
:ab ITEMIZE \begin{itemize} %(
:ab ENUMERATE \begin{enumerate} %(
:ab DESCRIPTION \begin{description} %(