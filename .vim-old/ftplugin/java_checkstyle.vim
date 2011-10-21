" File: java_checkstyle.vim
" Author: Xandy Johnson
" Update: Minto Tsai
" Version: 0.4
" Last Modified: July 11, 2003
"
" Credits
" -------
" The structure of this filetype plugin is based on the grep.vim plugin by
" Yegappan Lakshmanan (see
" <http://vim.sourceforge.net/script.php?script_id=311>), who generously gave
" permission for this use.  Many thanks to Yegappan.
"
" Special thanks are also due to Doug Kearns, who wrote a compiler plugin with
" essentially the same purpose as this filetype plugin, namely the integration
" of Checkstyle and Vim (see
" <http://mugca.its.monash.edu.au/~djkea2/vim/compiler/checkstyle.vim>).
" Using his errorformat allowed the use of Checkstyle directly, eliminating
" several dependencies.  I also thank Salman Halim, who sent me Doug Kearns'
" compiler plugin.  Both Doug and Salman helpfully explained things for me and
" graciously allowed me to use their work.
" 
" Thanks go to Thomas Regner for supplying a patch to support configuration of
" the Checkstyle properties.
"
" Thanks to Minto Tsai for updating to Checkstyle 3.0.
"
" Thanks to David McReynolds for a fix to correct handling of spaces in the
" Checkstyle command-line arguments.
"
" Also, quite obviously, many thanks are due to the Checkstyle developers, as
" well as Bram Moolenaar and the other developers of Vim.
"
" Usage
" -----
" java_checkstyle.vim is a filetype plugin for Java files that introduces the
" following command:
"
" :Checkstyle - runs Checkstyle <http://checkstyle.sourceforge.net/> on the
"               current file and opens the results in an errorfile
"
"
" Configuration
" -------------
" The 'Checkstyle_Classpath' variable is used to specify the classpath to be
" used for running Checkstyle.  If you are using Java 1.4 or later, you simply
" need the checkstyle-all jar file from the Checkstyle distribution.  By
" default, this is set to /opt/checkstyle/checkstyle-all-3.1.jar.  If you are
" using Java 1.3, you also need a JAXP compliant XML parser.  You can change
" this using something like the following let command (which you may want to
" put in your vimrc file):
"
"       :let Checkstyle_Classpath = 'C:\checkstyle-3.1\checkstyle-all-3.1.jar'
"
" The 'Checkstyle_XML' variable is used to specify the file from which
" Checkstyle will read the configuration of its modules and their properties.
" The default is
" '/opt/checkstyle/contrib/examples/conf/BlochEffectiveJava.xml' (chosen in
" part because it contains no Ant variables).  If you would like to use
" another configuration file, you can specify one using something like the
" following let command (which you may want to put in your vimrc file):
"
" 	:let Checkstyle_XML = '/opt/checkstyle/docs/sun_checks.xml'

:let Checkstyle_Classpath = '/Users/davec/Projects/checkstyle-all-4.4.jar'
:let Checkstyle_XML = '/Users/davec/Projects/pose/pose-parent/checkstyle.xml'
:let Checkstyle_SourceRoot = '/Users/davec/Projects/pose/report/src/main/java'

if exists("loaded_java_checkstyle") || &cp
    finish
endif
let loaded_java_checkstyle = 1

" Location of the checkstyle-all jar file
if !exists("Checkstyle_Classpath")
    let Checkstyle_Classpath = '/opt/checkstyle/checkstyle-all-3.1.jar'
endif

if !exists("Checkstyle_XML")
    let Checkstyle_XML = '/opt/checkstyle/contrib/examples/conf/BlochEffectiveJava.xml'
endif

" RunCheckstyle()
" This function runs Checkstyle using the jar file represented by
" Checkstyle_Classpath as the classpath, redirects the output to a temp
" file, uses that file as an errorfile, and cleans up.
function! s:RunCheckstyle(flag)

    " Setup and invoke the command
    let filename = expand("%:p")
    let checkstyle_cmd = 'java -cp "' . g:Checkstyle_Classpath . '"'
    let checkstyle_cmd = checkstyle_cmd . ' com.puppycrawl.tools.checkstyle.Main'
    let checkstyle_cmd = checkstyle_cmd . ' -c "' . g:Checkstyle_XML . '"'
    if a:flag == "all"
      let checkstyle_cmd = checkstyle_cmd . ' -r "' . g:Checkstyle_SourceRoot . '"'
    else
      let checkstyle_cmd = checkstyle_cmd . ' "' . filename . '"'
    endif

    let cmd_output = system(checkstyle_cmd)

    " Redirect the output to a temp file
    let tmpfile = tempname()
    execute "redir! > " . tmpfile
    silent echon cmd_output
    redir END

    " store the existing errorformat so that it can be restored later
    let old_errorformat = &errorformat

    set errorformat=%f:%l:%c\ %m,%f:%l:%v:\ %m,%f:%l:\ %m,%-G%.%#

    " Read the error file
    execute "silent! cfile " . tmpfile

    " restore the previously existing error format
    let &errorformat = old_errorformat

    " Show the first error message error if there is one (making sure not to
    " cause a Vim error if there are no Checkstyle errors).
    let v:errmsg = ""
    silent! verbose cc
    if v:errmsg == ""
	cc
    endif

    "call delete(tmpfile)
endfunction

" Define the command
command! -nargs=* Checkstyle call s:RunCheckstyle("this")

command! CheckstyleAll call s:RunCheckstyle("all")
