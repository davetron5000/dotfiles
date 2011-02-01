if exists("did_load_filetypes")
    finish
endif
augroup filetypedetect
    " markdown filetype file
    au! BufRead,BufNewFile *.md   setfiletype mkd
    au! BufRead,BufNewFile *.mkd   setfiletype mkd
    au! BufRead,BufNewFile *.markdown   setfiletype mkd
augroup END
