" vim:fdm=marker:nowrap:ts=4:
" --------------------------------------------------------------------
" db_ext.vim
" Database Utility
" --------------------------------------------------------------------
" Version:	0.61
" Author:	Peter Bagyinszki <petike1@dpg.hu>
" Based on: sqlplus.vim (author: Jamis Buck <jgb3@email.byu.edu>)
" Created:	2002-05-24
" Last modified:	2002-12-03 19:34 CET
" Contributors: David Fisburn	<fishburn@sybase.com>
"		Joerg Schoppet	<joerg.schoppet@web.de>
" http://vim.sourceforge.net/script.php?script_id=356

" Working db types: 
" Mysql (Bagyinszki)
" PostgreSQL (Bagyinszki)
" Sybase Adaptive Server Anywhere (Fishburn)
" Sybase Adaptive Server Enterprise (Fishburn)
" Ingres (Schoppet)
" Interbase (Bagyinszki)
" Microsoft SQL Server (Fishburn)
" Oracle (Fishburn)
" DB2 (Fishburn)

" TODO:/*{{{*/
" - Add new db types
" - Add inputtable() and inputfield() function to provide table and field name
"	autocompletion. (eg. to use with describe_table, or when adding where
"	clause.)
" - Alapvetõ ötlet a fake delete, hogy ha egy delete statementet talál, akkor
"	kiszelekteli, hogy miket is törölne, és update esetén kiszelekteli, hogy
"	miket is updatézna
" - Ne felejtsem el, hogy a php-ban tömbök is lehetnek változók/*}}}*/

if exists('g:loaded_db_ext') || &cp
	finish
endif
let g:loaded_db_ext = 1
" Must be uppercase
let s:db_types = '#INFORMIX#PGSQL#MYSQL#ASA#ASE#INGRES#INTERBASE#SQLSRV#ORA#DB2#'
" ? - look for a question mark
" w - MUST have word characters after it
" W - cannot have any word characters after it
" Q - CANNOT be surrounded in quotes
" q - MUST be surrounded in quotes
let s:db_ext_variable_def = '?Wq;@wQ;$wQ;'

" Conf. variables (may be set in ~/.vimrc) 

"--Commands, Mappings, Menus to be mapped----------------"{{{
if !exists("g:default_db_ext_maps")
    let g:default_db_ext_maps = 1
endif 

if !exists(':ExecVisualSQL')
    command! -nargs=0 -range ExecVisualSQL 
                \ :call <SID>DB_exec_sql(DB_get_visual_block())
    vmap <unique> <script> <Plug>ExecVisualSQL :ExecVisualSQL<CR>
    if !hasmapto('<Plug>ExecVisualSQL') && (g:default_db_ext_maps == 1)
        vmap <unique> <Leader>se <Plug>ExecVisualSQL
    endif 
    if has("gui_running") && has("menu")
        vnoremenu <script> Plugin.db_ext.Execute\ SQL :ExecVisualSQL<CR>
    endif
end
if !exists(':ExecSQLUnderCursor')
    command! -nargs=0 ExecSQLUnderCursor 
                \ :call <SID>DB_exec_sql(s:DB_get_query_under_cursor())
    nmap  <unique> <script> <Plug>ExecSQLUnderCursor  :ExecSQLUnderCursor<CR>
    if !hasmapto('<Plug>ExecSQLUnderCursor') && (g:default_db_ext_maps == 1)
        nmap <unique> <Leader>se <Plug>ExecSQLUnderCursor
    endif 
    if has("gui_running") && has("menu")
        noremenu <script> Plugin.db_ext.Execute\ SQL :ExecSQLUnderCursor<CR>
    endif
end
if !exists(':ExecSQL')
    command! -nargs=0 ExecSQL 
                \ :call <SID>DB_exec_sql(s:DB_parse_query(
                \ s:DB_get_query_under_cursor()
                \ ))
    nmap  <unique> <script> <Plug>ExecSQL  :ExecSQL<CR>
    if !hasmapto('<Plug>ExecSQL') && (g:default_db_ext_maps == 1)
        nmap <unique> <Leader>sq <Plug>ExecSQL
    endif 
    if has("gui_running") && has("menu")
        " noremenu <script> Plugin.db_ext.Execute\ SQL :ExecSQLUnderCursor<CR>
    endif
end
if !exists(':SelectFromTable')
    command! -nargs=* -range SelectFromTable 
                \ :call DB_exec_sql_with_default("select * from ", <f-args>)
    nmap  <unique> <script> <Plug>SelectFromTable  :SelectFromTable<CR>
    if !hasmapto('<Plug>SelectFromTable') && (g:default_db_ext_maps == 1)
        nmap <unique> <Leader>st <Plug>SelectFromTable
        vmap <unique> <silent> <Leader>st 
                    \ :<C-U>let table_name=DB_get_visual_block()<CR> \| 
                    \ :call DB_exec_sql_with_default("select * from ", 
                    \ table_name)<CR>
    endif 
    if has("gui_running") && has("menu")
        noremenu  <script> Plugin.db_ext.Select\ Table 
                    \ :SelectFromTable<CR>
        inoremenu <script> Plugin.db_ext.Select\ Table 
                    \ <C-O>:SelectFromTable<CR>
        vnoremenu <script> Plugin.db_ext.Select\ Table  
                    \ :<C-U>let table_name=DB_get_visual_block()<CR> \| 
                    \ :call DB_exec_sql_with_default("select * from ", 
                    \ table_name)<CR>
    endif
end
if !exists(':SelectFromTableWithWhere')
    command! -nargs=0 SelectFromTableWithWhere 
                \ :call <SID>DB_exec_sql("select * from " . 
                \ s:DB_get_word_under_cursor() . " where " . 
                \ input("Please enter where clause: "))
    nmap  <unique> <script> <Plug>SelectFromTableWithWhere
                \ :SelectFromTableWithWhere<CR>
    if !hasmapto('<Plug>SelectFromTableWithWhere') && 
                \ (g:default_db_ext_maps == 1)
        nmap <unique> <Leader>stw <Plug>SelectFromTableWithWhere
    endif 
    if has("gui_running") && has("menu")
        noremenu  <script> Plugin.db_ext.Select\ Table\ Where 
                    \ :SelectFromTableWithWhere<CR>
        inoremenu <script> Plugin.db_ext.Select\ Table\ Where 
                    \ <C-O>:SelectFromTableWithWhere<CR>
    endif
end
if !exists(':SelectFromTableAskName')
    command! -nargs=0 SelectFromTableAskName 
                \ :call <SID>DB_select_table_prompt()
    nmap  <unique> <script> <Plug>SelectFromTableAskName  
                \ :SelectFromTableAskName<CR>
    if !hasmapto('<Plug>SelectFromTableAskName') && 
                \ (g:default_db_ext_maps == 1)
        nmap <unique> <Leader>sta <Plug>SelectFromTableAskName
    endif 
    if has("gui_running") && has("menu")
        noremenu  <script> Plugin.db_ext.Select\ Table\ Ask 
                    \ :SelectFromTableAskName<CR>
        inoremenu <script> Plugin.db_ext.Select\ Table\ Ask 
                    \ <C-O>:SelectFromTableAskName<CR>
    endif
end
if !exists(':DescribeTable')
    command! -nargs=* -range DescribeTable 
                \ :call <SID>DB_describe_table(<f-args>)
    nmap  <unique> <script> <Plug>DescribeTable	 :DescribeTable<CR>
    if !hasmapto('<Plug>DescribeTable') && (g:default_db_ext_maps == 1)
        nmap <unique> <Leader>sdt <Plug>DescribeTable
        vmap <unique> <silent> <Leader>sdt 
                    \ :<C-U>let table_name=DB_get_visual_block()<CR> \| 
                    \ :exec 'DescribeTable '.table_name<CR>
    endif 
    if has("gui_running") && has("menu")
        noremenu  <script> Plugin.db_ext.Describe\ Table  
                    \ :DescribeTable<CR>
        inoremenu <script> Plugin.db_ext.Describe\ Table 
                    \ <C-O>:DescribeTable<CR>
        vnoremenu <script> Plugin.db_ext.Describe\ Table 
                    \ :<C-U>let table_name=DB_get_visual_block()<CR> \| 
                    \ :exec 'DescribeTable '.table_name<CR>
    endif
end
if !exists(':DescribeTableAskName')
    command! -nargs=0 DescribeTableAskName 
                \ :call <SID>DB_describe_table_prompt()
    nmap  <unique> <script> <Plug>DescribeTableAskName
                \ :DescribeTableAskName<CR>
    if !hasmapto('<Plug>DescribeTableAskName') && 
                \ (g:default_db_ext_maps == 1)
        nmap <unique> <Leader>sdta <Plug>DescribeTableAskName
    endif 
    if has("gui_running") && has("menu")
        noremenu  <script> Plugin.db_ext.Describe\ Table\ Ask  
                    \ :DescribeTableAskName<CR>
        inoremenu <script> Plugin.db_ext.Describe\ Table\ Ask 
                    \ <C-O>:DescribeTableAskName<CR>
    endif
end
if !exists(':DescribeProcedure')
    command! -nargs=* -range DescribeProcedure 
                \ :call <SID>DB_describe_procedure(<f-args>)
    nmap  <unique> <script> <Plug>DescribeProcedure	 :DescribeProcedure<CR>
    if !hasmapto('<Plug>DescribeProcedure') && (g:default_db_ext_maps == 1)
        nmap <unique> <Leader>sdp <Plug>DescribeProcedure
        vmap <unique> <silent> <Leader>sdp 
                    \ :<C-U>let proc_name=DB_get_visual_block()<CR> \| 
                    \ :exec 'DescribeProcedure '.proc_name<CR>
    endif 
    if has("gui_running") && has("menu")
        noremenu  <script> Plugin.db_ext.Describe\ Procedure   
                    \ :DescribeProcedure<CR>
        inoremenu <script> Plugin.db_ext.Describe\ Procedure 
                    \ <C-O>:DescribeProcedure<CR>
        vnoremenu <script> Plugin.db_ext.Describe\ Procedure      
                    \ :<C-U>let proc_name=DB_get_visual_block()<CR> \| 
                    \ :exec 'DescribeProcedure '.proc_name<CR>
    endif
end
if !exists(':DescribeProcedureAskName')
    command! -nargs=0 DescribeProcedureAskName 
                \ :call <SID>DB_describe_procedure_prompt()
    nmap  <unique> <script> <Plug>DescribeProcedureAskName	
                \ :DescribeProcedureAskName<CR>
    if !hasmapto('<Plug>DescribeProcedureAskName') && 
                \ (g:default_db_ext_maps == 1)
        nmap <unique> <Leader>sdpa <Plug>DescribeProcedureAskName
    endif 
    if has("gui_running") && has("menu")
        noremenu  <script> Plugin.db_ext.Describe\ Procedure\ Ask 
                    \ :DescribeProcedureAskName<CR>
        inoremenu <script> Plugin.db_ext.Describe\ Procedure\ Ask 
                    \ <C-O>:DescribeProcedureAskName<CR>
    endif
end
if !exists(':PromptForBufferParameters')
    command! -nargs=0 PromptForBufferParameters 
                \ :call <SID>DB_prompt_for_buffer_parameters()
    nmap  <unique> <script> <Plug>PromptForBufferParameters	 
                \ :PromptForBufferParameters<CR>
    if !hasmapto('<Plug>PromptForBufferParameters') && 
                \ (g:default_db_ext_maps == 1)
        nmap <unique> <Leader>sbp <Plug>PromptForBufferParameters
    endif 
    if has("gui_running") && has("menu")
        noremenu  <script> Plugin.db_ext.Prompt\ Connect\ Info		
                    \ :PromptForBufferParameters<CR>
    endif
end

"}}}
" -- pgsql exec ----------------
function! <SID>PGSQL_exec_sql(str) "{{{
	if !exists("b:db_ext_cmd_terminator")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_terminator")
                let b:db_ext_cmd_terminator = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_terminator
            else
                let b:db_ext_cmd_terminator = ""
            endif
	endif

	if !exists("b:db_ext_cmd_options")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_options")
                let b:db_ext_cmd_options = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_options
            else
                let b:db_ext_cmd_options = ""
            endif
	endif

	let l:db = s:DB_get_dbname()
	let cmd = s:DB_full_path2bin('psql')
	let cmd = cmd . ' -d' . l:db .
                    \' ' . b:db_ext_cmd_options .
                    \' -c "' . escape(a:str,'\$') . '"'
	let cmd = cmd . b:db_ext_cmd_terminator 
	call DB_RunCmd(cmd, a:str)
	return
endfunction "}}}
function! <SID>PGSQL_describe_table(table_name) "{{{
	return s:PGSQL_exec_sql('\d '.a:table_name)
endfunction "}}}
function! <SID>PGSQL_describe_procedure(procedure_name) "{{{
	echo 'Feature not yet available'
	" return s:PGSQL_exec_sql('\d '.a:procedure_name)
endfunction "}}}
" -- mysql exec ----------------
function! <SID>MYSQL_exec_sql(str) "{{{
	if !exists("b:db_ext_cmd_terminator")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_terminator")
                let b:db_ext_cmd_terminator = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_terminator
            else
                let b:db_ext_cmd_terminator = ""
            endif
	endif

	if !exists("b:db_ext_cmd_options")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_options")
                let b:db_ext_cmd_options = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_options
            else
                let b:db_ext_cmd_options = ""
            endif
	endif

	let l:db = s:DB_get_dbname()
	let cmd = s:DB_full_path2bin('mysql')
	let cmd = s:DB_add_option(cmd, ' -u ', b:db_ext_user, '')
	let cmd = s:DB_add_option(cmd, ' -p ', b:db_ext_passwd, '')
	let cmd = s:DB_add_option(cmd, ' -h ', b:db_ext_host, '')
	let cmd = cmd . ' -D ' . l:db .
                    \' ' . b:db_ext_cmd_options .
                    \' -e "' . escape(a:str,'\$') . '"'
	let cmd = cmd . b:db_ext_cmd_terminator 
	call DB_RunCmd(cmd, a:str)
	return
endfunction "}}}
function! <SID>MYSQL_describe_table(table_name) "{{{
	return s:MYSQL_exec_sql("describe ".a:table_name.";")
endfunction "}}}
function! <SID>MYSQL_describe_procedure(procedure_name) "{{{
	echo 'Feature not yet available'
	" return s:MYSQL_exec_sql("describe ".a:procedure_name.";")
endfunction "}}}
" -- ASA exec ---------------
function! <SID>ASA_exec_sql(str) "{{{
	if !exists("b:db_ext_cmd_terminator")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_terminator")
                let b:db_ext_cmd_terminator = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_terminator
            else
                let b:db_ext_cmd_terminator = ";"
            endif
	endif

	if !exists("b:db_ext_cmd_options")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_options")
                let b:db_ext_cmd_options = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_options
            else
                let b:db_ext_cmd_options = "-nogui"
            endif
	endif

    let l:str = a:str

	let tempfile = tempname()
	let output = l:str 
    " Only include a command terminator if one has not already
    " been added
    if output !~ b:db_ext_cmd_terminator . '[^\n\s]*$'
        let output = output . b:db_ext_cmd_terminator
    endif
	exe 'redir! > ' . tempfile
	silent echo output
	redir END
	
	let cmd = s:DB_full_path2bin('dbisql')
	let cmd = cmd . ' ' . b:db_ext_cmd_options
	if( strlen(b:db_ext_on_error) == 0 )
        let cmd = s:DB_add_option(cmd, ' -onerror ', 'exit', '')
	else
        let cmd = s:DB_add_option(cmd, ' -onerror ', b:db_ext_on_error, '')
	endif

    let cmd = cmd . ' -c "'
    let cmd = s:DB_add_option(cmd, 'uid=', b:db_ext_user, ';')
    let cmd = s:DB_add_option(cmd, 'pwd=', b:db_ext_passwd, ';')
    let cmd = s:DB_add_option(cmd, 'dsn=', b:db_ext_dsnname, ';')
    let cmd = s:DB_add_option(cmd, 'eng=', b:db_ext_srvname, ';')
    let cmd = s:DB_add_option(cmd, 'dbn=', b:db_ext_dbname, ';')
	let cmd = cmd . '" ' . b:db_ext_cmd_options
	let cmd = cmd . ' read ' . tempfile

	call DB_RunCmd(cmd, output)

	let rc = delete(tempfile)
	if rc != 0
		echo 'failed to delete: '.tempfile.'  rc: '.rc
	endif

	return 
endfunction "}}}
function! <SID>ASA_describe_table(table_name) "{{{
	return s:ASA_exec_sql("call sp_jdbc_columns( '".a:table_name."');")
endfunction "}}}
function! <SID>ASA_describe_procedure(proc_name) "{{{
	return s:ASA_exec_sql("call sp_sproc_columns( '".a:proc_name."');")
endfunction "}}}
" -- DB2 exec ---------------
function! <SID>DB2_exec_sql(str) "{{{
    if !exists("b:db_ext_cmd_terminator")
        if exists("g:default_db_ext_{b:db_ext_type}_cmd_terminator")
            let b:db_ext_cmd_terminator = 
                        \g:default_db_ext_{b:db_ext_type}_cmd_terminator
        else
            let b:db_ext_cmd_terminator = ";"
        endif
    endif

    if !exists("b:db_ext_cmd_options")
        if exists("g:default_db_ext_{b:db_ext_type}_cmd_options")
            let b:db_ext_cmd_options = 
                        \g:default_db_ext_{b:db_ext_type}_cmd_options
        else
            " -q off - db2batch info, headings, and query results.
            " -s off - Summary Table off
            let b:db_ext_cmd_options = "-q off -s off"
        endif
    endif

    let tempfile = tempname()
    let output = escape(a:str,'\$') 
    " if a terminator is not already present, add one;   
    " DB2 reports errors if there are additional command
    " temrinators
    if output !~ b:db_ext_cmd_terminator . '[^\n\s]*$'
        let output = output . b:db_ext_cmd_terminator
    endif
    exe 'redir! > ' . tempfile
    silent echo output
    redir END

    let cmd = s:DB_full_path2bin('db2batch')
    let cmd = cmd . ' '
    if b:db_ext_user != ""
        let cmd = cmd . '-a ' . b:db_ext_user   . '/'
        let cmd = cmd . ''    . b:db_ext_passwd . ' '
    endif
    let cmd = s:DB_add_option(cmd, ' -H ', b:db_ext_host, ' ')
    let cmd = s:DB_add_option(cmd, ' -d ', b:db_ext_dbname, ' ')
    let cmd = s:DB_add_option(cmd, ' ', b:db_ext_cmd_options, ' ')
    let cmd = s:DB_add_option(cmd, ' -l ', b:db_ext_cmd_terminator, ' ')
    let cmd = cmd . ' -f ' . tempfile

    " call Decho( "Command: '". cmd . "'" )
    " echom cmd
    call DB_RunCmd(cmd, output)
    return

    let rc = delete(tempfile)

    if rc != 0
        echo 'failed to delete: '.tempfile.'  rc: '.rc
    endif

    return 
endfunction "}}}
function! <SID>DB2_describe_table(table_name) "{{{

    " Another option is:
    " db2 describe table db2inst1.org
    let cmd = s:DB_full_path2bin('db2look')
    let cmd = cmd . ' '
    if b:db_ext_user != ""
        let cmd = cmd . '-i ' . b:db_ext_user   . ' '
    endif 
    if b:db_ext_passwd != ""
        let cmd = cmd . '-w '    . b:db_ext_passwd . ' '
    endif
    if b:db_ext_user != ""
        let cmd = cmd . '-u ' . b:db_ext_user . ' '
    endif 
    if b:db_ext_dbname != ""
        let cmd = cmd . '-d ' . b:db_ext_dbname . ' '
    endif 
    let cmd = cmd . '-e -t ' . a:table_name

    " call Decho( "Command: '". cmd . "'" )
    " echom cmd
    call DB_RunCmd(cmd, cmd)

    return 
endfunction "}}}
function! <SID>DB2_describe_procedure(procedure_name) "{{{
    " echo 'Feature not tested'
    " let  query = "select parm_signature from syscat.procedures ".
    "             \ "where procname = '" . a:procedure_name . "'"
    
    " The owner regex matches a word at the start of the string which is
    " followed by a dot, but doesn't include the dot in the result.
    let owner = matchstr( a:procedure_name, '^\w*\ze\.' )
    " The proc regex matches a word at the start of the string, skipping over
    " any owner name if there is one.  Only the proc name is returned.
    let proc  = matchstr( a:procedure_name, '^\(\w*\.\)\?\zs\w*' )

    " Using CAST as VARCHAR to make the output more readable
    let  query =  "select ordinal " .
                \ "     , CAST(parmname AS VARCHAR(40)) AS parmname " .
                \ "     , CAST(typename AS VARCHAR(10)) AS typename " .
                \ "     , length " .
                \ "     , scale " .
                \ "     , CAST(nulls AS VARCHAR(1)) AS nulls " .
                \ "     , CAST(procschema AS VARCHAR(30)) AS procschema " .
                \ "  from syscat.procparms " .
                \ " where procname = '" . toupper(proc) . "' "
    if strlen(owner) > 0
        let query = query . " and procschema = '" . toupper(owner) . "' "
    endif

    let query = query . " order by ordinal"
    " echom query

    return s:DB2_exec_sql( query )
    " return s:DB2_exec_sql("exec sp_help ".a:procedure_name)
endfunction "}}}
" -- ASE exec ---------------
function! <SID>ASE_exec_sql(str) "{{{
	if !exists("b:db_ext_cmd_terminator")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_terminator")
                let b:db_ext_cmd_terminator = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_terminator
            else
                let b:db_ext_cmd_terminator = "\ngo"
            endif
	endif

	if !exists("b:db_ext_cmd_options")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_options")
                let b:db_ext_cmd_options = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_options
            else
                let b:db_ext_cmd_options = "-w 10000"
            endif
	endif

	" call Decho( a:str )
	let tempfile = tempname()
	let output = escape(a:str,'\$') 
	let output = output . b:db_ext_cmd_terminator
	exe 'redir! > ' . tempfile
	silent echo output
	redir END
	
	let cmd = s:DB_full_path2bin('isql')
	let cmd = cmd . ' '
	" Always include the userid
	let cmd = cmd . '-U ' . b:db_ext_user . ' '
	" Always include the password
	let cmd = cmd . '-P ' . b:db_ext_passwd . ' '
    let cmd = s:DB_add_option(cmd, ' -H ', b:db_ext_host, ' ')
    let cmd = s:DB_add_option(cmd, ' -S ', b:db_ext_srvname, ' ')
    let cmd = s:DB_add_option(cmd, ' -D ', b:db_ext_dbname, ' ')
	let cmd = cmd . ' ' . b:db_ext_cmd_options
	let cmd = cmd . ' -i ' . tempfile

	" call Decho( "Command: '". cmd . "'" )
	" echom cmd
	call DB_RunCmd(cmd, output)
	" return

	let rc = delete(tempfile)
	if rc != 0
		echo 'failed to delete: '.tempfile.'  rc: '.rc
	endif

	return 
endfunction "}}}
function! <SID>ASE_describe_table(table_name) "{{{
	return s:ASE_exec_sql("exec sp_help ".a:table_name)
endfunction "}}}
function! <SID>ASE_describe_procedure(procedure_name) "{{{
	return s:ASE_exec_sql("exec sp_help ".a:procedure_name)
endfunction "}}}
" -- SQLSRV exec ---------------
function! <SID>SQLSRV_exec_sql(str) "{{{
	if !exists("b:db_ext_cmd_terminator")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_terminator")
                let b:db_ext_cmd_terminator = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_terminator
            else
                let b:db_ext_cmd_terminator = ""
            endif
	endif

	if !exists("b:db_ext_cmd_options")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_options")
                let b:db_ext_cmd_options = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_options
            else
                let b:db_ext_cmd_options = "-w 10000 -r -b"
            endif
	endif

	let tempfile = tempname()
	let output = escape(a:str,'\$') 
	let output = output . b:db_ext_cmd_terminator
	exe 'redir! > ' . tempfile
	silent echo output
	redir END
	
	let cmd = s:DB_full_path2bin('isql')
	let cmd = cmd . ' '
	" Always include the userid
	let cmd = cmd . '-U' . b:db_ext_user . ' '
	" Always include the password
	let cmd = cmd . '-P' . b:db_ext_passwd . ' '
    let cmd = s:DB_add_option(cmd, ' -H ', b:db_ext_host, ' ')
    let cmd = s:DB_add_option(cmd, ' -S ', b:db_ext_srvname, ' ')
    let cmd = s:DB_add_option(cmd, ' -d ', b:db_ext_dbname, ' ')
    let cmd = s:DB_add_option(cmd, ' ', b:db_ext_cmd_options, '')
	let cmd = cmd . ' -i ' . tempfile

	call DB_RunCmd(cmd, output)

	let rc = delete(tempfile)
	if rc != 0
		echo 'failed to delete: '.tempfile.'  rc: '.rc
	endif

	return 
endfunction "}}}
function! <SID>SQLSRV_describe_table(table_name) "{{{
	return s:SQLSRV_exec_sql("exec sp_help ".a:table_name)
endfunction "}}}
function! <SID>SQLSRV_describe_procedure(procedure_name) "{{{
	return s:SQLSRV_exec_sql("exec sp_help ".a:procedure_name)
endfunction "}}}
" -- Oracle exec ---------------
function! <SID>ORA_exec_sql(str) "{{{
	if !exists("b:db_ext_cmd_terminator")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_terminator")
                let b:db_ext_cmd_terminator = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_terminator
            else
                let b:db_ext_cmd_terminator = ";\nquit;"
            endif
	endif

	if !exists("b:db_ext_cmd_options")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_options")
                let b:db_ext_cmd_options = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_options
            else
                let b:db_ext_cmd_options = ""
            endif
	endif

	let tempfile = tempname()  
	let output = a:str 
	let output = output . b:db_ext_cmd_terminator
	exe 'redir! > ' . tempfile
	silent echo output
	redir END
	
	let cmd = s:DB_full_path2bin('sqlplus')
    let cmd = s:DB_add_option(cmd, ' ', b:db_ext_cmd_options, '')
    let cmd = s:DB_add_option(cmd, ' ', b:db_ext_user, '')
    let cmd = s:DB_add_option(cmd, '/', b:db_ext_passwd, '')
    let cmd = s:DB_add_option(cmd, '@', b:db_ext_srvname, '')
	let cmd = cmd . ' @' . tempfile

	call DB_RunCmd(cmd, output)

	let rc = delete(tempfile)
	if rc != 0
		echo 'failed to delete: '.tempfile.'  rc: '.rc
	endif
	return 
endfunction "}}}
function! <SID>ORA_describe_table(table_name) "{{{
	return s:ORA_exec_sql("desc ".a:table_name)
endfunction "}}}
function! <SID>ORA_describe_procedure(procedure_name) "{{{
	return s:ORA_exec_sql("desc ".a:procedure_name)
endfunction "}}}
" -- ingres exec ---------------
function! <SID>INGRES_exec_sql(str) "{{{
	if !exists("b:db_ext_cmd_terminator")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_terminator")
                let b:db_ext_cmd_terminator = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_terminator
            else
                let b:db_ext_cmd_terminator = '\p\g'
            endif
	endif

	if !exists("b:db_ext_cmd_options")
            if exists("g:default_db_ext_{b:db_ext_type}_cmd_options")
                let b:db_ext_cmd_options = 
                            \g:default_db_ext_{b:db_ext_type}_cmd_options
            else
                let b:db_ext_cmd_options = ""
            endif
	endif

	let l:db = s:DB_get_dbname()
	let tempfile = tempname()
	let output = escape(a:str,'\$') 
	let output = output . b:db_ext_cmd_terminator
	exe 'redir! > ' . tempfile
	silent echo output
	redir END
	let cmd = s:DB_full_path2bin('sql')
	let cmd = cmd . ' -s ' . l:db . ' ' . b:db_ext_cmd_options
	let cmd = cmd . ' < ' . tempfile
	call DB_RunCmd(cmd, output)
	return
endfunction "}}}
function! <SID>INGRES_describe_table(table_name) "{{{
	return s:INGRES_exec_sql("help ".a:table_name.";")
endfunction "}}}
function! <SID>INGRES_describe_procedure(procedure_name) "{{{
	echo 'Feature not yet available'
	" return s:INGRES_exec_sql("help ".a:procedure_name.";")
endfunction "}}}
" -- interbase exec ------------
function! <SID>INTERBASE_exec_sql(str) "{{{
	if !exists("b:db_ext_cmd_terminator")
            if exists("g:default_db_ext_INTERBASE_cmd_terminator")
                let b:db_ext_cmd_terminator = 
                            \g:default_db_ext_INTERBASE_cmd_terminator
            else
                let b:db_ext_cmd_terminator = ""
            endif
	endif

	if !exists("b:db_ext_cmd_options")
            if exists("g:default_db_ext_INTERBASE_cmd_options")
                let b:db_ext_cmd_options = 
                            \g:default_db_ext_INTERBASE_cmd_options
            else
                let b:db_ext_cmd_options = ""
            endif
	endif

	let l:db = s:DB_get_dbname()
	let tempfile = tempname()
	let output = a:str 
	let output = output . "\n" . b:db_ext_cmd_terminator
	exe 'redir! > ' . tempfile
	silent echo output
	redir END
	let cmd = s:DB_full_path2bin('isql')
	let cmd = cmd . ' -username ' . b:db_ext_user .
                    \' -password ' . b:db_ext_passwd .
                    \' ' . b:db_ext_cmd_options .
                    \' -input ' . tempfile .
                    \' ' . l:db
	" let cmd =	 s:db_ext_interbase_path .
        " \'isql -username ' . b:db_ext_user .
        " \' -password ' . b:db_ext_passwd .
        " \' -input ' . tempfile .
        " \' ' . l:db
	call DB_RunCmd(cmd, output)
	return
endfunction "}}}
function! <SID>INTERBASE_describe_table(table_name) "{{{
	return s:INTERBASE_exec_sql("show table ".a:table_name.";")
endfunction "}}}
function! <SID>INTERBASE_describe_procedure(procedure_name) "{{{
	echo 'Feature not yet available'
	" return s:INTERBASE_exec_sql("show procedure ".a:procedure_name.";")
endfunction "}}}
" -- INFORMIX exec ---------------
function! <SID>INFORMIX_exec_sql(str) "{{{

    let tempfile = tempname()
    let output = escape(a:str,'\%') 
    let output = substitute(output,"\n","","g") 

    exe 'redir! > ' . tempfile
    silent echo output
    redir END

    let cmd = g:default_db_ext_javacmd . ' ' . g:default_db_ext_jdbcdriver . ' ' 
    let cmd = cmd . '"jdbc:informix-sqli://' . g:default_db_ext_host . ':' 
    let cmd = cmd . g:default_db_ext_port . '/' 
    let cmd = cmd . g:default_db_ext_dbname . ':INFORMIXSERVER=' 
    let cmd = cmd . g:default_db_ext_informixserver .  '" ' 
    let cmd = cmd . g:default_db_ext_user . ' ' . g:default_db_ext_passwd . ' '
    let cmd = cmd . g:default_db_ext_schema . ' ' . g:default_db_ext_max_cell_width . ' ' . g:default_db_ext_max_row_count
    let cmd = cmd . ' "' . output . '"'

    call DB_RunCmd(cmd, ' ')
    return

    let rc = delete(tempfile)

    if rc != 0
        echo 'failed to delete: '.tempfile.'  rc: '.rc
    endif

    return 
endfunction "}}}
" -- selector ------------------
function! DB_exec_sql_with_default(...) " {{{
    " Made this a public function to be used in the vmapping 
        if(a:0 > 0) 
            let sql = a:1
        else
            echo "No statement to execute!"
            return
        endif

        if(a:0 > 1) 
            let sql = sql . a:2
        else 
            let sql = sql . expand("<cword>")
        endif

	if !exists("b:db_ext_buffers_defaulted")
		call s:DB_set_buffer_defaults()
        if !exists("b:db_ext_buffers_defaulted")
            return
        endif
	endif

	return s:{b:db_ext_type}_exec_sql(sql)
endfunction "}}}
function! <SID>DB_exec_sql(query) "{{{
    let l:query = a:query

	if strlen(l:query) == 0 
		echo "No statement to execute!"
		return
	endif
	
	if !exists("b:db_ext_buffers_defaulted")
		call s:DB_set_buffer_defaults()
        if !exists("b:db_ext_buffers_defaulted")
            return
        endif
	endif

    if b:db_ext_prompt_for_parameters == 1
        let l:query = s:DB_parse_query(l:query)
    endif

	return s:{b:db_ext_type}_exec_sql(l:query)
endfunction "}}}
function! <SID>DB_describe_table(...) "{{{
    if(a:0 > 0) 
        " Strip any leading or trailing spaces
        let table_name = substitute(a:1,'\s*\(\w*\)\s*','\1','')
    else
        let table_name = s:DB_get_word_under_cursor()
    endif

    if !exists("b:db_ext_buffers_defaulted")
        call s:DB_set_buffer_defaults()
        if !exists("b:db_ext_buffers_defaulted")
            return
        endif
    endif

    return s:{b:db_ext_type}_describe_table(table_name)
endfunction "}}}
function! <SID>DB_describe_procedure(...) "{{{
    if(a:0 > 0) 
        let procedure_name = a:1
    else
        let procedure_name = s:DB_get_word_under_cursor()
    endif

	if !exists("b:db_ext_buffers_defaulted")
		call s:DB_set_buffer_defaults()
        if !exists("b:db_ext_buffers_defaulted")
            return
        endif
	endif

	return s:{b:db_ext_type}_describe_procedure(procedure_name)
endfunction "}}}
" -- general -------------------
function! s:DB_warning_msg(msg) "{{{
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfunction "}}}
function! <SID>DB_get_srvname() "{{{
	while b:db_ext_srvname == ""
		let b:db_ext_srvname=input("Please enter the name of the server: ")
	endwhile
	return b:db_ext_srvname
endfunction "}}}
function! <SID>DB_get_dbname() "{{{
	while b:db_ext_dbname == ""
		let b:db_ext_dbname=input("Please enter the name of the database: ")
	endwhile
	return b:db_ext_dbname
endfunction "}}}
function! <SID>DB_set_db(...) "{{{
	if a:0 > 2 "Too many parameters
		echohl ErrorMsg
		echo "Error: too many parameters"
		echohl Normal
		return
	endif
	if a:0 >= 1
		if a:0 >= 2
			if(s:DB_set_db_type(a:2) == "" )
				return
			endif
		endif
		if a:1 != "" "Set db name
			let b:db_ext_dbname = a:1
		endif
	endif
	echo b:db_ext_dbname . '/' . b:db_ext_type
	return b:db_ext_dbname . '/' . b:db_ext_type
endfunction "}}}
function! <SID>DB_set_db_type(db_type) "{{{
	let l:db_type = toupper(a:db_type)
	if stridx(s:db_types, '#'.l:db_type.'#') > -1 "Set db type
		let b:db_ext_type = l:db_type
		return b:db_ext_type
	else
		echohl ErrorMsg
		echo "\n\rError: db type not supported"
		echohl Normal
		return ""
	endif
endfunction "}}}
function! <SID>DB_add_cmd_terminator(str) "{{{
        " I dont believe this routine is necessary anymore since
        " the exec_sql functions automatically add the command
        " terminator
        return a:str
	" return substitute(a:str,b:db_ext_cmd_terminator.'\=\s*$',
        "            \b:db_ext_cmd_terminator,'g')
	" return substitute(a:str,';\=\s*$',';','g')
endfunction "}}}
function! <SID>DB_full_path2bin(executable_name) "{{{
	if b:db_ext_bin_path != ""
		" Expand environment variables
		let full_exe = expand(b:db_ext_bin_path)
		" Remove any double quotes
		let full_exe = substitute( full_exe, '"', "", "g" )
		" Remove any trailing spaces and a ending slash
		let full_exe = substitute( full_exe, "[\\\\\/]\s*$", "", "ge" )
		if has("win32") 
			let full_exe = full_exe . "\\" . a:executable_name
		else
			let full_exe = full_exe . "/" . a:executable_name
		endif
		if has("win32") && full_exe =~ " "
			let full_exe = '"' . full_exe . '"'
		endif
	else
		let full_exe = a:executable_name
	endif
	return full_exe
endfunction "}}}
function! <SID>DB_get_query_under_cursor() "{{{
	" Mi van olyankor, ha az idezojelben van pontosvesszo, vagy kulcsszo?
	" Van egy hiba gifem, majd meg kell nezni mi a rossz
	let l:old_sel = &sel
	let &sel = 'inclusive'
	let saveWrapScan=&wrapscan
	let saveSearch=@/ 
    let l:reg_z = @z
    let &wrapscan=0
    let @z = ''

    " Must default the command terminator
    let l:db_ext_cmd_terminator = ";"

    " If a command terminator has already been specified, use it
    " It is necessary to default it first, since this function
    " can be called before a buffer has setup which database it
    " will connect to.  The command terminator is different for
    " many databases.
    if exists("b:db_ext_cmd_terminator")
        let l:db_ext_cmd_terminator = b:db_ext_cmd_terminator
    else
        if exists("g:default_db_ext_{b:db_ext_type}_cmd_terminator")
            let l:db_ext_cmd_terminator = 
                        \g:default_db_ext_{b:db_ext_type}_cmd_terminator
        endif
    endif

    " Mark the current line to return to
    let curline     = line(".")
    let curcol      = virtcol(".")
    
	let sql_commands = '\c\<\(select\|update\|create\|grant' .
                \ '\|delete\|alter\|call\|exec\|insert\)\>'
	" Search backwards and do NOT wrap
	if search(sql_commands, 'bW' ) > 0
        " Note: escape the command terminator with \ incase the 
        " string choosen is a special string.
        " I have tested this with the following terminators
        " ; ~ go
        " Note: I added the /e to the search string, since vim 
        " was not picking up the command terminator as part of the 
        " yank.  This is generally not an issue since each of the 
        " database exec sql routines add one, but if your 
        " terminator is multiple characters (ie go - ASE and SQL Server)
        " then you get an invalid command since it was stripping
        " the "o" from "go"
        exe 'silent! norm! v/\'.l:db_ext_cmd_terminator."/e\n".'"zy``'
	endif

    " Return to previous location
    exe 'norm! '.curline.'G'.curcol."\<bar>"

	noh
	let l:query = @z
	let @z = l:reg_z
	let @/=saveSearch
	let &wrapscan=saveWrapScan
	let &sel = l:old_sel

	return l:query
endfunction "}}}
function! <SID>DB_get_word_under_cursor() "{{{
	return expand("<cword>");
endfunction "}}}
function! <SID>DB_select_table_prompt() "{{{
	return s:DB_exec_sql("select * from " .
                    \input("Please enter the name of the table to select from: "))
endfunction "}}}
function! <SID>DB_describe_table_prompt() "{{{
	return s:DB_describe_table(
                    \input("Please enter the name of the table to describe: "))
endfunction "}}}
function! <SID>DB_describe_procedure_prompt() "{{{
	return s:DB_describe_procedure(input("Please enter the name of the procedure to describe: "))
endfunction "}}}
function! <SID>DB_add_option(cmd, param, value, separator) "{{{
	if a:value == ""
		return a:cmd
	else
		return a:cmd . a:param . a:value . a:separator
	endif
endfunction "}}}
function! DB_get_visual_block() range " {{{
    " Made this a public function to be used in the vmapping 
	let saveSearch=@/ 
	silent normal gvy
	let l:vis_cmd = @"
	let @/=saveSearch
	return l:vis_cmd
endfunction "}}}
" -- Update Result Buffer -------------------
function! DB_RunCmd( cmd, sql ) "{{{
	" Store current window number so we can return to it
	let cur_winnr = winnr()
    let show_cmd_line = b:db_ext_display_cmd_line 


	if b:db_ext_use_sep_result_buffer == 1
        " Get the file name (no extension)
        let res_buf_name = "Result-".expand("%:t:r")
        let buf_exists   = bufexists(res_buf_name)
        let res_buf_nbr  = bufnr(res_buf_name)
    else
        let res_buf_name = "Result"
        " Do not use bufexists("Result"), since it uses a fully qualified
        " path name to search for the buffer, which in effect opens
        " multiple buffers called "Result" if the files that you are 
        " executing the commands from are in different directories.
        let buf_exists   = bufexists(bufnr(res_buf_name))
        let res_buf_nbr  = bufnr(res_buf_name)
    endif

	if b:db_ext_use_result_buffer == 1
		if buf_exists == 0
			" Create the new buffer
			silent exec 'belowright '.b:db_ext_buffer_lines.'new '.res_buf_name
		else
			if bufwinnr( res_buf_nbr ) == -1
				" if the buffer is not visible, wipe it out
				" and recreate it, this will position us
				" in the new buffer
				exec 'bwipeout! ' . res_buf_nbr
				silent exec 'belowright '.b:db_ext_buffer_lines.'new '.res_buf_name
			else
				" If the buffer is visible, switch to it
				exec bufwinnr(res_buf_nbr) . "wincmd w"
			endif
		endif

		setlocal modified
		" Delete all the lines prior to this run
		%d

		" If the user wants to see the command line, echo it 
        " as the first line in the output
		if show_cmd_line == 1 
			put='Last command:'
			put=a:cmd
			put='Last SQL:'
			put=a:sql
        endif

		" Run the command and read it into the Result buffer
		" silent exec "read !" . a:cmd . " 2>&1"
		" Decho a:cmd
		" echom a:cmd
        exec 'silent! normal! G'
		silent exec "read !" . a:cmd 

		" If there was an error, show the command just executed
		" for debugging purposes
		if v:shell_error
			exec 'silent! normal! G'
			put='To change connection parameters:'
			put=':PromptForBufferParameters'
			put='Or'
			put=':let b:db_ext_[user,passwd,dsnname,srvname,dbname,host,port,on_error]=value'
			put='Last command:'
			put=a:cmd
			put='Last SQL:'
			put=a:sql
		endif

		" Since this is a small window, remove any blanks lines
		silent %g/^\s*$/d
		" Fix the ^M characters, if any
        silent execute "%s/\<C-M>\\+$//e"

		" Dont allow modifications, and do not wrap the text, since
		" the data may be lined up for columns
		setlocal nomodified
		setlocal nowrap

		" Go to top of output
		norm gg
		" Return to original window
		" exe "norm \<c-w>p\<c-w>l"
		exec cur_winnr . "wincmd w"
	else
		" If the user wants to see the command line, echo it 
                " as the first line in the output
		if b:db_ext_display_cmd_line == 1 
			echo a:cmd
                endif

		let result = system(a:cmd)
		echo result
	endif
endfunction "}}}
" -- parser --------------------
function! <SID>DB_parse_query(query) "{{{
	if &filetype=="php"
		return s:DB_parse_PHP_query(a:query)
    " elseif &filetype=="sql"
    else
		return s:DB_parse_SQL_query(a:query)
	endif
	return a:query
endfunction "}}}
function! <SID>DB_parse_PHP_query(query) "{{{
"eg. select * from users where {$pkey_name}_id=$id;
	let l:query = substitute(a:query, "\n", ' ', 'g')
	let l:var = matchstr(l:query, '{$\h\w*}')
	while l:var > ""
		let l:var_val = input("Enter value for " . strpart(l:var, 1, strlen(l:var)-2) . ": ")
		let l:query = substitute( l:query, l:var, l:var_val, 'g')
		let l:var = matchstr( l:query, '{$\h\w*}' )
	endwhile
	let l:var = matchstr(l:query, '$\h\w*')
	while l:var > ""
		let l:var_val = input("Enter value for " . l:var . ": ")
		let l:query = substitute( l:query, l:var . '\>', l:var_val, 'g')
		let l:var = matchstr( l:query, '$\h\w*' )
	endwhile
	return l:query
endfunction "}}}
function! <SID>DB_parse_SQL_query(query) "{{{
	let l:query = a:query

    " If query is a SELECT statement, remove any INTO clauses
    " Use an case insensitive comparison
	if l:query =~? '\c^[\n\s]*select'
        let l:query = substitute(a:query, '\cINTO.*FROM', 'FROM', 'g')
    endif

    " Must default the statements to parse
    let l:db_ext_parse_statements = "select,update,delete,insert,call,exec"

    " If a command terminator has already been specified, use it
    " It is necessary to default it first, since this function
    " can be called before a buffer has setup which database it
    " will connect to.  The command terminator is different for
    " many databases.
    if exists("b:db_ext_parse_statements")
        let l:db_ext_parse_statements = b:db_ext_parse_statements
    else
        if exists("g:default_db_ext_parse_statements")
            let l:db_ext_parse_statements = 
                        \g:default_db_ext_parse_statements
        endif
    endif

    " Verify the string is in the correct format
    let l:db_ext_parse_statements = 
                \ substitute( l:db_ext_parse_statements, ' ', '', 'g' )
    let l:db_ext_parse_statements = 
                \ substitute( l:db_ext_parse_statements, '^,','','')
    let l:db_ext_parse_statements = 
                \ substitute( l:db_ext_parse_statements, ',$','','')
    let l:db_ext_parse_statements = 
                \ substitute( l:db_ext_parse_statements, ',', '\\|', 'g' )

    " Only perform replacements if the first statement is one of the
    " following.  We do not want to parse the query if for example
    " we are creating a procedure which often uses declared 
    " variables within.
    if l:query =~? '^[\n\t ]*\('.l:db_ext_parse_statements.'\)'

        " Default response to no search and replace
        let response = 2

        " If the user didn't specify any settings, then use the default
        " variable definitions, otherwise use the users override
        if exists('b:db_ext_variable_def')
            let db_ext_variable_def = b:db_ext_variable_def
        else
            if exists('g:default_db_ext_variable_def')
                let db_ext_variable_def = g:default_db_ext_variable_def
            else
                let db_ext_variable_def = s:db_ext_variable_def
            endif
        endif

        let db_ext_variable_def = 
                    \ substitute(db_ext_variable_def,';\?\s*$',';','')

        " From the list of variable definitions, strip out only
        " the identifiers (ie ? @ $ )
        " ; - begins with a ;
        " . - we want this character
        " .\{-} - do not include following characters
        " \ze - end the match on the previous characters
        " ; - stop at the first ;
        let identifier_list = substitute(';'.db_ext_variable_def, 
                    \ ';\(.\)\(.\{-}\)\ze;', '\1', 'g' ) 
        " Remove the trailing ;
        let identifier_list = substitute( identifier_list, '\(.*\);\s*$',
                    \ '\1', 'g' ) 
        " If the statement has any of the following characters
        " ask if the user wants to be prompted for replacements
        " if l:query =~? '[?@:$]'
        if l:query =~? '['.identifier_list.']'
            let response = confirm("Do you want to prompt for input variables?"
                        \, "&Yes\n&No", 1 )
            " echom "\nresponse: ".response."\n"
        endif

        " If the user does not want to parse the query
        " return the query as is
        if response == 2
            return l:query
        endif

        " Process each variable definition, format is as follows:
        " identifier1[wW][qQ];identifier2[wW][qQ];identifier3[wW][qQ];
        let pos = 0
        while pos < strlen(db_ext_variable_def)
            " Check for format of string
            let end_pos = match(db_ext_variable_def, ';', pos)
            if end_pos == -1
                call s:DB_warning_msg("Invalid db_ext_variable_def format")
                return l:query
            endif
            " Extract the identified
            " Allow them to specify more than a single character for the 
            " search.  We must assume they follow the correct format 
            " though and the criteria ends with a WQ; (case insensitive)
            let identifier = strpart(db_ext_variable_def, pos, 
                        \ (end_pos-2-pos))
            if strlen(identifier) != 0
                " Make sure no word characters preceed the identifier
                let no_preceed_word = '\(\w\)\@<!'
            else
                call s:DB_warning_msg("Invalid identifier")
                return l:query
            endif
            let following_word_option = strpart(db_ext_variable_def,
                        \ (end_pos-2), 1 )
            " w - MUST have word characters after it
            " W - cannot have any word characters after it
            if following_word_option == 'w'
                let following_word = '\w*'
                let retrieve_ident = identifier . following_word
            elseif following_word_option == 'W'
                let following_word = '\(\w\)\@<!'
                let retrieve_ident = identifier
            else
                call s:DB_warning_msg("Invalid following word indicator")
                return l:query
            endif
            let quotes_option = strpart(db_ext_variable_def, (end_pos-1), 1)
            " q - MUST be surrounded in quotes
            " Q - CANNOT be surrounded in quotes
            if quotes_option == 'q'
                let quotes = "'".'\@<!'
            elseif quotes_option == 'Q'
                let quotes = ''
            else
                call s:DB_warning_msg("Invalid quotes indicator")
                return l:query
            endif

            let srch_cond = quotes . no_preceed_word .
                        \ identifier . following_word . quotes
            let l:query = s:DB_search_replace( l:query, srch_cond, 
                        \ retrieve_ident, 0 )

            let pos = end_pos + 1
        endwhile
    endif

    return l:query
endfunction "}}}
function! <SID>DB_parse_SQL_query_old(query) "{{{
	let l:query = a:query

    " If query is a SELECT statement, remove any INTO clauses
    " Use an case insensitive comparison
	if l:query =~? '\c^[\n\s]*select'
        let l:query = substitute(a:query, '\cINTO.*FROM', 'FROM', 'g')
    endif

    " Must default the statements to parse
    let l:db_ext_parse_statements = "select,update,delete,insert,call,exec"

    " If a command terminator has already been specified, use it
    " It is necessary to default it first, since this function
    " can be called before a buffer has setup which database it
    " will connect to.  The command terminator is different for
    " many databases.
    if exists("b:db_ext_parse_statements")
        let l:db_ext_parse_statements = b:db_ext_parse_statements
    else
        if exists("g:default_db_ext_parse_statements")
            let l:db_ext_parse_statements = 
                        \g:default_db_ext_parse_statements
        endif
    endif

    " Verify the string is in the correct format
    let l:db_ext_parse_statements = 
                \ substitute( l:db_ext_parse_statements, ' ', '', 'g' )
    let l:db_ext_parse_statements = 
                \ substitute( l:db_ext_parse_statements, '^,','','')
    let l:db_ext_parse_statements = 
                \ substitute( l:db_ext_parse_statements, ',$','','')
    let l:db_ext_parse_statements = 
                \ substitute( l:db_ext_parse_statements, ',', '\\|', 'g' )

    " Only perform replacements if the first statement is one of the
    " following.  We do not want to parse the query if for example
    " we are creating a procedure which often uses declared 
    " variables within.
    if l:query =~? '\c^[\n\s]*\('.l:db_ext_parse_statements.'\)'

        " Default response to no search and replace
        let response = 2

        " If the statement has any of the following characters
        " ask if the user wants to be prompted for replacements
        if l:query =~? '[?@:$]'
            let response = confirm("Do you want to prompt for input variables?"
                        \, "&Yes\n&No", 1 )
            " echom "\nresponse: ".response."\n"
        endif

        " If the user does not want to parse the query
        " return the query as is
        if response == 2
            return l:query
        endif

        " Search string break down
        "   "'".'\@<!  - Cannot be enclosed in quotes
        "   \(\w\)\@<! - cannot be any word character between 
        "                the single quote and what we are looking for
        "   ?          - What we are looking for (in this case)
        "   \(\w\)\@<! - Cannot have any word characters following the pattern
        "   "'".'\@!'  - Cannot be enclosed in quotes

        let srch_cond = "'".'\@<!\(\w\)\@<!?\(\w\)\@<!'."'".'\@<!'
        let l:query = s:DB_search_replace( l:query, srch_cond, '?', 1 )

        " Search string break down
        "   "'".'\@<!  - Cannot be enclosed in quotes
        "   \(\w\)\@<! - cannot be any word character between 
        "                the single quote and what we are looking for
        "   @          - What we are looking for (in this case)
        "   \w*        - Must have word characters following
        "   "'".'\@<!' - Cannot be enclosed in quotes

        let srch_cond = "'".'\@<!\(\w\)\@<!@\w*'."'".'\@<!'
        let l:query = s:DB_search_replace( l:query, srch_cond, '@\w*', 0 )

        " Search string break down
        "   "'".'\@<!  - Cannot be enclosed in quotes
        "   \(\w\)\@<! - cannot be any word character between 
        "                the single quote and what we are looking for
        "   :          - What we are looking for (in this case)
        "   \w*        - Must have word characters following
        "   "'".'\@<!' - Cannot be enclosed in quotes

        let srch_cond = "'".'\@<!\(\w\)\@<!:\w*'."'".'\@<!'
        let l:query = s:DB_search_replace( l:query, srch_cond, ':\w*', 0 )

        " Search string break down
        "   "'".'\@<!  - Cannot be enclosed in quotes
        "   \(\w\)\@<! - cannot be any word character between 
        "                the single quote and what we are looking for
        "   $          - What we are looking for (in this case)
        "   \w*        - Must have word characters following
        "   "'".'\@<!' - Cannot be enclosed in quotes

        let srch_cond = "'".'\@<!\(\w\)\@<!$\w*'."'".'\@<!'
        let l:query = s:DB_search_replace( l:query, srch_cond, '$\w*', 0 )

    endif

	return l:query
endfunction "}}}
function! <SID>DB_search_replace(str, exp_find_str, exp_get_value, count ) "{{{
	let l:str = a:str

    let count_nbr = 0
    " Find the string index position of the first match
    let index = match( l:str, a:exp_find_str )
    while index > -1
        let count_nbr = count_nbr + 1
        " Retrieve the name of what we found
        let l:var = matchstr( l:str, a:exp_get_value, index )
        let index = index + 1
        " Prompt the user using the name of the variable
        let dialog_msg = "Enter value for " . l:var 
        if a:count == 1
            " If there is no name (ie ?), then include the 
            " count of what was found so the user can 
            " distinguish between different ?s
            let dialog_msg = dialog_msg . " number " . count_nbr
        endif
        let dialog_msg = dialog_msg . ": "
        let l:var_val = inputdialog(dialog_msg)
        let response = 1
        " Ok or Cancel result in an empty string
        if l:var_val == ""
            " If empty, check if they want to leave it empty
            " of skip this variable
            let response = confirm("Your value is empty!"
                        \, "&Use blank\n&Skip\n&Stop Prompting")
        endif
        if response == 1
            " Replace the variable with what was entered
            let replace_sub = '\%'.index.'c'.'.\{'.strlen(l:var).'}'
            let l:str = substitute( l:str, replace_sub, l:var_val, '' )
            let index = match( l:str, a:exp_find_str, index+strlen(l:var_val) )
        elseif response == 2
            " Skip this match and move on to the next
            let index = match( l:str, a:exp_find_str, index+strlen(l:var) )
        else
            " Skip all remaining matches
            break
        endif
    endwhile

	return l:str
endfunction "}}}
" -- variable defaults --------------------
function! <SID>DB_set_global_defaults() "{{{
	"--Database type----------------
	if !exists("g:default_db_ext_type")
		" Force the user to specify a default database type
		" in their _vimrc file.
		" This prevents errors from being reported, if the wrong
		" RDBMS is chosen.
		
		" let g:default_db_ext_type = 'pgsql'
		" let g:default_db_ext_type = 'mysql'
		" let g:default_db_ext_type = 'asasql'
		" let g:default_db_ext_type = 'ingres'
		" let g:default_db_ext_type = 'interbase'
	endif
	"--Database name----------------
	if !exists("g:default_db_ext_dbname")
		" Force the user to specify a default database type
		" in their _vimrc file.
		" This prevents errors from being reported, if the wrong
		" RDBMS is chosen.
		" let g:default_db_ext_dbname = 'hotel'
		" let g:default_db_ext_dbname = 'c:\progra~1\borland\interb~1\bin\petike.gdb'
	endif
	"--User and password------------
	if !exists("g:default_db_ext_user")
		" Force the user to specify a default database type
		" in their _vimrc file.
		" This prevents errors from being reported, if the wrong
		" RDBMS is chosen.
		
		" let g:default_db_ext_user = 'SYSDBA'
		" let g:default_db_ext_user = 'DBA'
		" let g:default_db_ext_passwd = 'SQL'
	endif
	if !exists("g:default_db_ext_passwd")
		" Force the user to specify a default database type
		" in their _vimrc file.
		" This prevents errors from being reported, if the wrong
		" RDBMS is chosen.
		
		" let g:default_db_ext_passwd = 'masterkey'	 szallashely
	endif
	"--Host and port----------------
	if !exists("g:default_db_ext_host")
		let g:default_db_ext_host = ''
	endif
	if !exists("g:default_db_ext_port")
		let g:default_db_ext_port  = ''
	endif
	if !exists("g:default_db_ext_use_result_buffer")
		let g:default_db_ext_use_result_buffer	= 1
	endif
	if !exists("g:default_db_ext_buffer_lines")
		let g:default_db_ext_buffer_lines = 5
	endif
endfunction "}}}
function! <SID>DB_set_buffer_defaults() "{{{
    let b:db_ext_buffers_defaulted = 1

    if !exists("b:db_ext_use_sep_result_buffer")
        if exists("g:default_db_ext_use_sep_result_buffer")
            let b:db_ext_use_sep_result_buffer = g:default_db_ext_use_sep_result_buffer
        else
            let b:db_ext_use_sep_result_buffer = 0
        endif
        if b:db_ext_use_sep_result_buffer == 1
            " Also default use_result_buffer to "on" in this case
            let b:db_ext_use_result_buffer = 1
        endif
    endif
    if !exists("b:db_ext_use_result_buffer")
        if exists("g:default_db_ext_use_result_buffer")
            let b:db_ext_use_result_buffer = g:default_db_ext_use_result_buffer
        else
            let b:db_ext_use_result_buffer = 1
        endif
    endif
    if !exists("b:db_ext_buffer_lines")
        if exists("g:default_db_ext_buffer_lines")
            let b:db_ext_buffer_lines = g:default_db_ext_buffer_lines
        else
            let b:db_ext_buffer_lines = 5
        endif
    endif
    " This is optional.	 Some databases let the tool decide what
    " to do in the event of an error.  In ASA, the options are:
    " continue, exit
    " Exit would be the most appropriate default, which is set in
    " ASA_exec_sql.
    " I recommend setting this value in the corresponding function 
    " for each database.
    if !exists("b:db_ext_on_error")
        if exists("g:default_db_ext_on_error")
            let b:db_ext_on_error = g:default_db_ext_on_error
        else
            let b:db_ext_on_error = ''
        endif
    endif

    if !exists("b:db_ext_user")
        if exists("g:default_db_ext_user")
            let b:db_ext_user = g:default_db_ext_user
        else
            let b:db_ext_user = ""
        endif
    endif
    if !exists("b:db_ext_passwd")
        if exists("g:default_db_ext_passwd")
            let b:db_ext_passwd = g:default_db_ext_passwd
        else
            let b:db_ext_passwd = ""
        endif
    endif
    if !exists("b:db_ext_dsnname")
        if exists("g:default_db_ext_dsnname")
            let b:db_ext_dsnname = g:default_db_ext_dsnname
        else
            let b:db_ext_dsnname = ""
        endif
    endif
    if !exists("b:db_ext_srvname")
        if exists("g:default_db_ext_srvname")
            let b:db_ext_srvname = g:default_db_ext_srvname
        else
            let b:db_ext_srvname = ""
        endif
    endif
    if !exists("b:db_ext_dbname")
        if exists("g:default_db_ext_dbname")
            let b:db_ext_dbname = g:default_db_ext_dbname
        else
            let b:db_ext_dbname = ""
        endif
    endif
    if !exists("b:db_ext_host")
        if exists("g:default_db_ext_host")
            let b:db_ext_host = g:default_db_ext_host
        else
            let b:db_ext_host = ""
        endif
    endif
    if !exists("b:db_ext_port")
        if exists("g:default_db_ext_port")
            let b:db_ext_port = g:default_db_ext_port
        else
            let b:db_ext_port = ""
        endif
    endif
    if !exists("b:db_ext_bin_path")
        if exists("g:default_db_ext_bin_path")
            let b:db_ext_bin_path = g:default_db_ext_bin_path
        else
            let b:db_ext_bin_path = ""
        endif
    endif
    if !exists("b:db_ext_display_cmd_line")
        if exists("g:default_db_ext_display_cmd_line")
            let b:db_ext_display_cmd_line = 
                        \g:default_db_ext_display_cmd_line
        else
            let b:db_ext_display_cmd_line = 0
        endif
    endif
    if !exists("b:db_ext_prompt_for_parameters")
        if exists("g:default_db_ext_prompt_for_parameters")
            let b:db_ext_prompt_for_parameters = 
                        \g:default_db_ext_prompt_for_parameters
        else
            let b:db_ext_prompt_for_parameters = 1
        endif
    endif
    " The rest of these options are setup by the 
    " DB_prompt_for_buffer_parameters function.  So if db_ext_type has not
    " been set, prompt for the values.  If we prompt, then bypass the 
    " remainder of the function.
    if !exists("b:db_ext_type")
        if exists("g:default_db_ext_type")
            " let b:db_ext_type = toupper(g:default_db_ext_type)
            let b:db_ext_type = s:DB_set_db_type(g:default_db_ext_type)
        endif
    endif

    if !exists("b:db_ext_type")
        let b:db_ext_type = ""
    endif

    if b:db_ext_type == ""
        call s:DB_prompt_for_buffer_parameters()
        return
    endif

endfunction "}}}
function! <SID>DB_prompt_for_buffer_parameters() "{{{
    if !exists("b:db_ext_buffers_defaulted")
        call s:DB_set_buffer_defaults()
        return
    endif

    let db_types=substitute(s:db_types, '\(\w\)#\(\w\)', '\1, \2', 'g')
    let db_types=substitute(db_types, '#', '', 'g')

    let l:db_ext_prev_type = b:db_ext_type

    " Allow them to default the value to what is already being used
    let b:db_ext_type=toupper(inputdialog(db_types.
            \ "\nPlease choose database type (from above ie ASA): ",
            \ b:db_ext_type ))

    " If the type is empty they hit the cancel button so abort
    " the settings
    if b:db_ext_type == ""
        " Unset this option so that if the user executing something else
        " they will be forced to set the database options
        unlet b:db_ext_buffers_defaulted
        return
    endif

    " But ensure they have entered something
    " while b:db_ext_type == ""
    "     let b:db_ext_type=toupper(inputdialog(db_types.
    "             \ "\nPlease choose database type (from above ie ASA): ",
    "             \ b:db_ext_type ))
    "     let b:db_ext_type = s:DB_set_db_type(b:db_ext_type)
    " endwhile

    " These options are database specific, so if the user has
    " chosen a different database, remove these options so they
    " are reset in the *exec_sql functions.
    if l:db_ext_prev_type != b:db_ext_type
        if exists("b:db_ext_cmd_terminator")
            unlet b:db_ext_cmd_terminator
        endif
        if exists("b:db_ext_cmd_options")
            unlet b:db_ext_cmd_options
        endif
    endif

    let b:db_ext_user = inputdialog("[Optional] Database user: ", 
                \b:db_ext_user)
    let b:db_ext_passwd = inputdialog("[O] User password: ", b:db_ext_passwd)
    let b:db_ext_dsnname = inputdialog("[O] ODBC DSN: ", b:db_ext_dsnname)
    let b:db_ext_srvname = inputdialog("[O] Server name: ", b:db_ext_srvname)
    let b:db_ext_dbname = inputdialog("[O] Database name: ", b:db_ext_dbname)
    let b:db_ext_host = inputdialog("[O] Host name: ", b:db_ext_host)
    let b:db_ext_port = inputdialog("[O] Port name: ", b:db_ext_port)
    let b:db_ext_bin_path = inputdialog("[O] Directory for database tools: ", 
                \b:db_ext_bin_path)

    if !has("gui_running")
        " Work around an issue with the input command and redir.
        " The file would be offset by the length of the previous input
        " text.
        " silent! exec 'echo('."\n".')'
        echo("\n")
    endif
endfunction "}}}
" -- Commands --------------------
" commands "{{{
command! -nargs=* DB		:call <SID>DB_set_db(<f-args>)
command! -nargs=+ ExecSQL	:call <SID>DB_exec_sql(<SID>DB_add_cmd_terminator(<q-args>))
command! -nargs=+ Select	:call <SID>DB_exec_sql(<SID>DB_add_cmd_terminator("select ".<q-args>))
command! -nargs=+ Update	:echo <SID>DB_exec_sql(<SID>DB_add_cmd_terminator("update ".<q-args>))
command! -nargs=+ Insert	:echo <SID>DB_exec_sql(<SID>DB_add_cmd_terminator("insert ".<q-args>))
command! -nargs=+ Delete	:echo <SID>DB_exec_sql(<SID>DB_add_cmd_terminator("delete ".<q-args>))
command! -nargs=+ Drop		:echo <SID>DB_exec_sql(<SID>DB_add_cmd_terminator("drop ".<q-args>))
command! -nargs=+ Alter		:echo <SID>DB_exec_sql(<SID>DB_add_cmd_terminator("alter ".<q-args>))
command! -nargs=+ Create	:echo <SID>DB_exec_sql(<SID>DB_add_cmd_terminator("create ".<q-args>))
"}}}

" Assign script defaults including globals
call s:DB_set_global_defaults()
" autocmd BufNewFile,BufRead * call s:DB_set_buffer_defaults()

