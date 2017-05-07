if !has_key(g:, "mapping")
    let g:mapping = {}
endif

" Creates a child terminal that starts out invisible
function! g:CreateChild()
    " Get the current buffer id
    let current = bufnr('%')
    " store the current window view
    let view = winsaveview()
    " launch a terminal
    execute "terminal"
    " get that childs buffer number
    let child = bufnr('%')
    " switch back to the current buffer
    call g:HandySwitch(current, view)
    " store the mapping from current -> child in
    " the lookup table
    let g:mapping[current] = child
endfunction

" Switch buffers without messing anything up if possible
function! g:HandySwitch(bufid, restore)
    " save the window view
    let sv = winsaveview()
    " switch to the buffer
    execute "b" . a:bufid
    " if restore isn't the empty-dict, restore it
    call winrestview(a:restore)
    " return the stored window from before the switch
    return sv
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
            let reset = g:HandySwitch(target, {})
            " paste from @a
            normal! "ap
            " Switch back to current buffer and reset the
            " window positioning from before
            call g:HandySwitch(current, reset)
        finally
            " let @a = a_save
        endtry
    else
        echo "no child"
    endif
endfunction

