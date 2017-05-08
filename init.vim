if !has_key(s:, "mapping")
    let s:mapping = {}
endif

" Switch buffers without messing anything up if possible
function! s:HandySwitch(bufid, restore)
    " save the window view
    let sv = winsaveview()
    " switch to the buffer
    execute "b" . a:bufid
    " if restore isn't the empty-dict, restore it
    call winrestview(a:restore)
    " return the stored window from before the switch
    return sv
endfunction

" Creates a child terminal that starts out invisible
function! s:CreateChild()
    " Get the current buffer id
    let current = bufnr('%')
    " store the current window view
    let view = winsaveview()
    " launch a terminal
    execute "terminal"
    " get that childs buffer number
    let child = bufnr('%')
    " switch back to the current buffer
    call s:HandySwitch(current, view)
    " store the mapping from current -> child in
    " the lookup table
    let s:mapping[current] = child
endfunction

" does the thing
function! s:SendLines(l1, l2)
    " Save the current contents of @a
    let a_save = @a
    " Find the id for the currently opened buffer
    let current = bufnr('%')
    " Only run if there is a child for this buffer
    if has_key(s:mapping, current)
        try
            " Yank between the line ranges
            execute a:l1 . ',' . a:l2 . 'ya a'

            " Append a newline to the end so that the command
            " gets executed
            let @a = @a . "\n"

            " Lookup the target buffer
            let target = s:mapping[current]
            " Switch to target buffer
            let reset = s:HandySwitch(target, {})
            " paste from @a
            normal! "ap
            " Switch back to current buffer and reset the
            " window positioning from before
            call s:HandySwitch(current, reset)
        finally
            " Restore the @a register
            " let @a = a_save
        endtry
    else
        echo "no child"
    endif
endfunction

command! -range EntangleSend call s:SendLines(<line1>, <line2>)
command! EntangleTerminal call s:CreateChild()
