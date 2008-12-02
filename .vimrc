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

" Determine the project_root
if !exists("g:project_root")
    let g:project_root="~/Projects"
    exec "cd " . g:project_root
else
    exec "cd " . g:project_root
endif
" Specify the location of the ant buildfile
"if !exists("g:build_file")
"    let g:ant_buildfile=g:project_root . "/build.xml"
"else
"    let g:ant_buildfile=g:project_root . "/" . g:build_file
"endif

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
    exec "e " . g:project_root
endfunction

" Config for XML editing plugin
let xml_use_xhtml = 1
let xml_no_auto_nesting = 0
let xml_tag_completion_map = ">"

"yypdwwi/[ ;]D<<yypigetl~kkyyjpJ^ipublic $a() { return this.kyyjpkJdw$a; }kyyjpisetl~^ipublic void $a(kkk2yyjjjpkJJ$a ) { this.kkyyjjppkkJdw$a = J$a; }kkkdddd

" Misc stuff
hi Normal guibg=black
hi Normal guifg=white
filetype plugin on
filetype indent on
syn on

set gfn=Monaco:h13:a

"""" Configuration
" Check for local .vimrc
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
set grepprg=grep\ -rn\ $*
set suffixesadd=.ec
" Does vim help for any "K", as opposed to going to man page
set keywordprg=

"""" Mappings
" Sets you up to grep your entire project, 
exec "map g :grep  " . g:project_root . "<Home><Right><Right><Right><Right><Right>"
" Greps the entre project for the word under the cursor, allowing you to edit the line
exec "map G :grep <cword> " . g:project_root
" Greps the entre project for the word under the cursor
exec "map  :grep <cword> " . g:project_root . ""
" cd to directory of current file
map c :cd %:p:h
" kill F1 (doesn't seem to actually work)
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
" move to a line like 'private String itsBlah;' and this will create
" getters/setters for you
map j yypcwpublic/itsxxxiget$i()lxkyyjpdwdwireturn ^i{ $a }kJkyyjpcwpublicwivoid setwwikddpkxxxkJx$xa(Jx$ai) { kkyyjjpdwdw$i = i$a }kJoj
" Open file implementing class under cursor in new pane
map  s:find <cword>.java
" Create canoncial equals method for base classes
map eb opublic boolean equals(Object o){}koif (o == this)return true;if (o == null)return false;if (!o.getClass().getName().equals(getClass().getName()))return false;// actual comparison here 
" Create canoncial equals method for derived classes
map ed opublic boolean equals(Object o){}koif (o == this)return true;if (super.equals(o))%li!oreturn false;// test derived class properties
" Put braces around one line
map b O{jo}k
" Convert an exception to a catch block
map x ^icatch (lywea pb~$a){}ko

" Stuff I'm not sure about
"map   :%s/<lf>1G

" Helpful abbreviations
:ab TRY try{}catch (SomeException e){}kklllllll
:ab ITER for (Iterator i = list.iterator(); i.hasNext(); ){}kkllllllllllllllllll
:ab JITER for (Iterator j = list.iterator(); j.hasNext(); ){}kkllllllllllllllllll
:ab CLOSEDAO if (dao != null){try{dao.closeDAO();}catch (Throwable t){t.printStackTrace();}}kkkkkk^
:ab IF if (){}else{}<Up><Up><Up><Up><Up><Up><Right><Right><Right><Right>
:ab FOR for (Object o: list){}kk^lllll
:ab OLDFOR for (int i=0;i<list.length; i++){}kk^lllll
:ab LOGGER itsLogger = Logger.getLogger(getClass().getName());
:ab LOG4J import org.apache.log4j.*;

" Abs for LaTeX
:ab ITEMIZE \begin{itemize} %(\end{itemize} %)O
:ab ENUMERATE \begin{enumerate} %(\end{enumerate} %)O
:ab DESCRIPTION \begin{description} %(\item{\textbf{}}\end{description} %)O
