let g:term_b_buf = 0
let g:term_w_buf = 0

function! termfloating#Toggle()
    let found = bufwinnr(g:term_w_buf)
    if found > 0
      if &buftype == 'terminal'
        execute found . ' wincmd q'
        execute bufwinnr(g:term_b_buf) . ' wincmd q'
      else
        execute found . ' wincmd w'
        xecute bufwinnr(g:term_b_buf) . ' wincmd w'
      endif
    else
      call s:openFloatTerm()
      setlocal colorcolumn=
      setlocal nobuflisted
    endif
endfunction



function! s:onCloseFloatTerm()
  call nvim_win_close(s:term_b_win, v:true)
  let g:term_b_buf = 0
  let g:term_w_buf = 0
  bdelete!
endfunction

function! s:openFloatTerm()

  let height = float2nr((&lines - 2) / 1.5)
  let row = float2nr((&lines - height) / 2)
  let width = float2nr(&columns / 1.5)
  let col = float2nr((&columns - width) / 2)
  " " Border Window
  let border_opts = {
    \ 'relative': 'editor',
    \ 'row': row - 1,
    \ 'col': col - 2,
    \ 'width': width + 4,
    \ 'height': height + 2,
    \ 'style': 'minimal'
    \ }
  let g:term_b_buf = nvim_create_buf(v:false, v:true)
  let s:term_b_win = nvim_open_win(g:term_b_buf, v:true, border_opts)
  setlocal colorcolumn=
  setlocal nobuflisted
  " Main Window
  let opts = {
    \ 'relative': 'editor',
    \ 'row': row,
    \ 'col': col,
    \ 'width': width,
    \ 'height': height,
    \ 'style': 'minimal'
    \ }
  if g:term_w_buf > 0
    call nvim_open_win(g:term_w_buf, v:true, opts)
  else
    let g:term_w_buf = nvim_create_buf(v:false, v:true)
    call nvim_open_win(g:term_w_buf, v:true, opts)
    terminal
    call setbufvar(bufnr('%'), 'term_floating_window', 1)
    " Hook up TermClose event to close both terminal and border windows
    augroup NvimCloseTermWin
      autocmd!
      autocmd TermClose <buffer> if &buftype=='terminal'
        \ && getbufvar(bufnr('%'), 'term_floating_window') == 1 |
        \ call s:onCloseFloatTerm() |
        \ endif
    augroup END
  endif
  startinsert
endfunction
