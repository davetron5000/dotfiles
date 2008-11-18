" Vim script file                                           vim600:fdm=marker:
" FileType:	XML
" Maintainer:	Devin Weaver <vim@tritarget.com>
" Last Change:  $Date: 2002/06/13 02:34:48 $
" Version:      $Revision: 1.10 $
" Location:	http://tritarget.com/pub/vim/ftplugin/xml.vim
" Contributors: "Brad Phelan" <bphelan@mathworks.co.uk>,
"               "Ma, Xiangjiang" <Xiangjiang.Ma@broadvision.com>

" This script provides some convenience when editing XML (and some SGML)
" formated documents.

" Note: If you used the 5.x version of this file (xmledit.vim) you'll need to
" comment out the section where you called it since it is no longer used in
" version 6.x. 

" Kudos to "Brad Phelan" for completing tag matching and visual tag completion.
" Kudos to "Ma, Xiangjiang" for pointing out VIM 6.0 map <buffer> feature.

" PLEASE READ the associated documentation that came with this plugin for
" usage, mappings, and settings.

"==============================================================================

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" WrapTag -> Places an XML tag around a visual selection.            {{{1
" Brad Phelan: Wrap the argument in an XML tag
" Added nice GUI support to the dialogs. 
if !exists("*s:WrapTag") 
function s:WrapTag(text)
    if strlen(a:text) > 10
	let input_text = strpart(a:text, 0, 10) . '...'
    else
	let input_text = a:text
    endif
    let wraptag = inputdialog('Tag to wrap "' . input_text . '" : ')
    let atts = inputdialog('Attributes in <' . wraptag . '> : ')
    if strlen(atts)==0                                                        
	let text = '<'.wraptag.'>'.a:text.'</'.wraptag.'>'                     
    else                                                                      
	let text = '<'.wraptag.' '.atts.'>'.a:text.'</'.wraptag.'>'            
    endif                                                                     
    return text                                                               
endfunction
endif

" NewFileXML -> Inserts <?xml?> at top of new file.                  {{{1
if !exists("*s:NewFileXML")
function s:NewFileXML( )
    " Where is g:did_xhtmlcf_inits defined?
    if &filetype == 'xml' || (!exists ("g:did_xhtmlcf_inits") && exists ("g:xml_use_xhtml") && &filetype == 'html')
	if append (0, '<?xml version="1.0"?>')
	    normal! G
	endif
    endif
endfunction
endif


" IsParsableTag -> Check to see if the tag is a real tag.            {{{1
if !exists("*s:IsParsableTag")
function s:IsParsableTag( tag )
    " The "Should I parse?" flag.
    let parse = 1

    " make sure a:tag has a proper tag in it and is not a instruction or end tag.
    if a:tag !~ '^<[[:alnum:]_:\-].*>$'
	let parse = 0
    endif

    " make sure this tag isn't already closed.
    if strpart (a:tag, strlen (a:tag) - 2, 1) == '/'
	let parse = 0
    endif
    
    return parse
endfunction
endif


" ParseTag -> The major work hourse for tag completion.              {{{1
if !exists("*s:ParseTag")
function s:ParseTag( )
    " Save registers
    let old_reg_save = @"

    if (!exists("g:xml_no_auto_nesting") && strpart (getline ("."), col (".") - 2, 2) == '>>')
	let multi_line = 1
	execute "normal! \"xX"
    else
	let multi_line = 0
    endif

    let @" = ""
    execute "normal! \"xy%%"
    let ltag = @"
    if (&filetype == 'html') && (!exists ("g:xml_no_html"))
	let html_mode = 1
	let ltag = substitute (ltag, '[^[:graph:]]\+', ' ', 'g')
	let ltag = substitute (ltag, '<\s*\([^[:alnum:]_:\-[:blank:]]\=\)\s*\([[:alnum:]_:\-]\+\)\>', '<\1\2', '')
    else
	let html_mode = 0
    endif

    if <SID>IsParsableTag (ltag)
	" find the break between tag name and atributes (or closing of tag)
	" Too bad I can't just grab the position index of a pattern in a string.
	let index = 1
	while index < strlen (ltag) && strpart (ltag, index, 1) =~ '[[:alnum:]_:\-]'
	    let index = index + 1
	endwhile

	let tag_name = strpart (ltag, 1, index - 1)

	" That (index - 1) + 2    2 for the '</' and 1 for the extra character the
	" while includes (the '>' is ignored because <Esc> puts the curser on top
	" of the '>'
	let index = index + 2

	" print out the end tag and place the cursor back were it left off
	if html_mode && tag_name =~? '^\(img\|input\|param\|frame\|br\|hr\|meta\|link\|base\|area\)$'
	    if exists ("g:xml_use_xhtml")
		execute "normal! i /\<Esc>l"
	    endif
	else
	    if multi_line
		" Can't use \<Tab> because that indents 'tabstop' not 'shiftwidth'
		" Also >> doesn't shift on an empty line hence the temporary char 'x'
		let com_save = &comments
		set comments-=n:>
		execute "normal! a\<Cr>\<Cr>\<Esc>kAx\<Esc>>>$\"xx"
		execute "set comments=" . com_save
		startinsert!
		return ""
	    else
		execute "normal! a</" . tag_name . ">\<Esc>" . index . "h"
	    endif
	endif
    endif

    " restore registers
    let @" = old_reg_save

    if col (".") < strlen (getline ("."))
	execute "normal! l"
	startinsert
    else
	startinsert!
    endif
endfunction
endif


" BuildTagName -> Grabs the tag's name for tag matching.             {{{1
if !exists("*s:BuildTagName")
function s:BuildTagName( )
  "First check to see if we
  "Are allready on the end
  "of the tag. The / search
  "forwards command will jump
  "to the next tag otherwise
  exec "normal! v\"xy"
  if @x=='>'
     " Don't do anything
  else
     exec "normal! />/\<Cr>"
  endif

  " Now we head back to the < to reach the beginning.
  exec "normal! ?<?\<Cr>"

  " Capture the tag (a > will be catured by the /$/ match)
  exec "normal! v/\\s\\|$/\<Cr>\"xy"

  " We need to strip off any junk at the end.
  let @x=strpart(@x, 0, match(@x, "[[:blank:]>\<C-J>]"))

  "remove <, >
  let @x=substitute(@x,'^<\|>$','','')

  " remove spaces.
  let @x=substitute(@x,'/\s*','/', '')
  let @x=substitute(@x,'^\s*','', '')
endfunction
endif

" TagMatch1 -> First step in tag matching.                           {{{1 
" Brad Phelan: First step in tag matching.
if !exists("*s:TagMatch1")
function s:TagMatch1()
  " Save registers
  let old_reg_save = @"

  "Drop a marker here just in case we have a mismatched tag and
  "wish to return (:mark looses column position)
  normal! mz

  call <SID>BuildTagName()

  "Check to see if it is an end tag
  "If it is place a 1 in the register y
  if match(@x, '^/')==-1
    let endtag = 0
  else
    let endtag = 1  
  endif

 " Extract the tag from the whole tag block
 " eg if the block =
 "   tag attrib1=blah attrib2=blah
 " we will end up with 
 "   tag
 " with no trailing or leading spaces
 let @x=substitute(@x,'^/','','g')

 " Make sure the tag is valid.
 " Malformed tags could be <?xml ?>, <![CDATA[]]>, etc.
 if match(@x,'^[[:alnum:]_:\-]') != -1
     " Pass the tag to the matching 
     " routine
     call <SID>TagMatch2(@x, endtag)
 endif
 " Restore registers
 let @" = old_reg_save
endfunction
endif


" TagMatch2 -> Second step in tag matching.                          {{{1
" Brad Phelan: Second step in tag matching.
if !exists("*s:TagMatch2")
function s:TagMatch2(tag,endtag)
  let match_type=''

  " Build the pattern for searching for XML tags based
  " on the 'tag' type passed into the function.
  " Note we search forwards for end tags and
  " backwards for start tags
  if a:endtag==0
     "let nextMatch='normal /\(<\s*' . a:tag . '\(\s\+.\{-}\)*>\)\|\(<\/' . a:tag . '\s*>\)'
     let match_type = '/'
  else
     "let nextMatch='normal ?\(<\s*' . a:tag . '\(\s\+.\{-}\)*>\)\|\(<\/' . a:tag . '\s*>\)'
     let match_type = '?'
  endif

  if a:endtag==0
     let stk = 1 
  else
     let stk = 1
  end

 " wrapscan must be turned on. We'll recored the value and reset it afterward.
 " We have it on because if we don't we'll get a nasty error if the search hits
 " BOF or EOF.
 let wrapval = &wrapscan
 let &wrapscan = 1

  "Get the current location of the cursor so we can 
  "detect if we wrap on ourselves
  let lpos = line(".")
  let cpos = col(".")

  if a:endtag==0
      " If we are trying to find a start tag
      " then decrement when we find a start tag
      let iter = 1
  else
      " If we are trying to find an end tag
      " then increment when we find a start tag
      let iter = -1
  endif

  "Loop until stk == 0. 
  while 1 
     " exec search.
     " Make sure to avoid />$/ as well as /\s$/ and /$/.
     exec "normal! " . match_type . '<\s*\/*\s*' . a:tag . '\([[:blank:]>]\|$\)' . "\<Cr>"

     " Check to see if our match makes sence.
     if a:endtag == 0
	 if line(".") < lpos
	     call <SID>MisMatchedTag (0, a:tag)
	     break
	 elseif line(".") == lpos && col(".") <= cpos
	     call <SID>MisMatchedTag (1, a:tag)
	     break
	 endif
     else
	 if line(".") > lpos
	     call <SID>MisMatchedTag (2, '/'.a:tag)
	     break
	 elseif line(".") == lpos && col(".") >= cpos
	     call <SID>MisMatchedTag (3, '/'.a:tag)
	     break
	 endif
     endif

     call <SID>BuildTagName()

     if match(@x,'^/')==-1
	" Found start tag
	let stk = stk + iter 
     else
	" Found end tag
	let stk = stk - iter
     endif

     if stk == 0
	break
     endif    
  endwhile

  let &wrapscan = wrapval
endfunction
endif

" MisMatchedTag -> What to do if a tag is mismatched.                {{{1
if !exists("*s:MisMatchedTag")
function s:MisMatchedTag( id, tag )
    "Jump back to our formor spot
    normal! `z
    normal zz
    echohl WarningMsg
    " For debugging
    "echo "Mismatched tag " . a:id . ": <" . a:tag . ">"
    " For release
    echo "Mismatched tag <" . a:tag . ">"
    echohl None
endfunction
endif

" Mappings and Settings.                                             {{{1
" This makes the '%' jump between the start and end of a single tag.
setlocal matchpairs+=<:>

" Have this as an escape incase you want a literal '>' not to run the
" ParseTag function.
inoremap <buffer> <Leader>. >
inoremap <buffer> <Leader>> >

" Jump between the beggining and end tags.
nnoremap <buffer> <Leader>5 :call <SID>TagMatch1()<Cr>
nnoremap <buffer> <Leader>% :call <SID>TagMatch1()<Cr>

" Wrap selection in XML tag
vnoremap <buffer> <Leader>x "xx"=<SID>WrapTag(@x)<Cr>P

" Parse the tag after pressing the close '>'.
if !exists("g:xml_tag_completion_map")
    inoremap <buffer> > ><Esc>:call <SID>ParseTag()<Cr>
else
    execute "inoremap <buffer> " . g:xml_tag_completion_map . " ><Esc>:call <SID>ParseTag()<Cr>"
endif

augroup xml
    au!
    au BufNewFile * call <SID>NewFileXML()
augroup END
