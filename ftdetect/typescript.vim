"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim ftdetect file
"
" Language: TSX (TypeScript)
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:tsx_pragma_pattern = '\%^\_s*\/\*\*\%(\_.\%(\*\/\)\@!\)*@tsx\_.\{-}\*\/'

" if g:tsx_check_react_import == 1
"   parse the first line of ts file (skipping comments). When it has a 'react'
"   importation, we guess the user writes tsx
" endif
let s:tsx_prevalent_pattern =
      \ '\v\C%^\_s*%(%(//.*\_$|/\*\_.{-}\*/)@>\_s*)*%(import\s+\k+\s+from\s+|%(\l+\s+)=\k+\s*\=\s*require\s*\(\s*)[`"'']react>'

" Whether to set the TSX filetype on *.ts files.
fu! <SID>EnableTSX()
  " Whether the .tsx extension is required.
  if !exists('g:tsx_ext_required')
    let g:tsx_ext_required = 0
  endif

  " Whether the @tsx pragma is required.
  if !exists('g:tsx_pragma_required')
    let g:tsx_pragma_required = 0
  endif

  if g:tsx_pragma_required && !exists('b:tsx_ext_found')
    " Look for the @tsx pragma.  It must be included in a docblock comment
    " before anything else in the file (except whitespace).
    let b:tsx_pragma_found = search(s:tsx_pragma_pattern, 'npw')
  endif

  if g:tsx_pragma_required && !b:tsx_pragma_found | return 0 | endif
  if g:tsx_ext_required && !exists('b:tsx_ext_found') &&
        \ !(get(g:,'tsx_check_react_import') && search(s:tsx_prevalent_pattern, 'nw'))
    return 0
  endif
  return 1
endfu

augroup typescript_tsx_syntax_detection
  autocmd!
  autocmd BufNewFile,BufRead *.tsx let b:tsx_ext_found = 1
  autocmd BufNewFile,BufRead *.tsx set filetype=typescript.tsx
  autocmd BufNewFile,BufRead *.ts
    \ if <SID>EnableTSX() | set filetype=typescript.tsx | endif
augroup END
