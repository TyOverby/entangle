let g:mapping = {}

" Creates a child terminal that starts out invisible
function! g:CreateChild()
    " Get the current buffer id
    let current = bufnr('%')
    " Get the curent mode
    let current_mode = mode()
    " launch a terminal
    execute "terminal"
    " get that childs buffer number
    let child = bufnr('%')
    " switch back to the current buffer
    execute "b" . current
    " store the mapping from current -> child in
    " the lookup table
    let g:mapping[current] = child
endfunction

" Switch buffers without messing anything up if possible
function! g:HandySwitch(bufid)
    " Dunno
    let t = 1
    " Dunno
    let x = 1
    while t <= tabpagenr('$')
        let x = 1
        for b in tabpagebuflist(t)
            " if the buffer id is the one that we're looking for
            if mb == a:bufid
                " execute "w" on it and return
                execute x . "wincmd w"
                return
            endif
            " lol
            let x += 1
        endfor
        " what is this even
        let t += 1
    endwhile
    execute "b" . bufid
endfunction

" does the thing
function! g:DoTheThing()
    " Save the current contents of @a
    let a_save = @a
    " Find the id for the currently opened buffer
    let current = bufnr('%')
    " Only run if there is a child for this buffer
    if has_key(g:mapping, current)
        try
            " Get the mode to see if we are in visual mode or not
            let m = mode()
            " Use case insensitive comparison
            if m ==? "v"
                " Yank all visual selection into @a
                normal! gv"ay
            else
                " Yank current line into @a
                let @a=getline('.')
            endif

            " Append a newline to the end so that the command
            " gets executed
            let @a = @a . "\<CR>"

            " Lookup the target buffer
            let target = g:mapping[current]
            " Switch to target buffer
            call g:HandySwitch(target)
            " paste from @a
            normal! "ap
            " Switch back to current buffer
            call g:HandySwitch(current)
        finally
            " let @a = a_save
        endtry
    else
        echo "no child"
    endif
endfunction

