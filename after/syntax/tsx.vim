" Prologue; load in XML syntax.
if exists('b:current_syntax')
  let s:current_syntax=b:current_syntax
  unlet b:current_syntax
endif
syn include @XMLSyntax syntax/xml.vim
if exists('s:current_syntax')
  let b:current_syntax=s:current_syntax
endif

" Officially, vim-jsx depends on the amadeus/vim-typescript syntax package
" (and is tested against it exclusively).  These are the
" plugin-to-syntax-element correspondences:
"
"   - amadeus/vim-typescript:      tsBlock, tsExpression


" JSX attributes should color as JS.  Note the trivial end pattern; we let
" tsBlock take care of ending the region.
syn region xmlString contained start=+{+ end=++ contains=tsBlock,javascriptBlock

" JSX comments inside XML tag should color as comment.  Note the trivial end pattern; we let
" tsComment take care of ending the region.
syn region xmlString contained start=+//+ end=++ contains=tsComment
syn region xmlString contained start=+/\*+ end=++ contains=tsComment fold extend keepend

" JSX child blocks behave just like JSX attributes, except that (a) they are
" syntactically distinct, and (b) they need the syn-extend argument, or else
" nested XML end-tag patterns may end the outer tsxRegion.
syn region tsxChild contained start=+{+ end=++ contains=tsBlock,javascriptBlock
  \ extend

" Highlight JSX regions as XML; recursively match.
"
" Note that we prohibit JSX tags from having a < or word character immediately
" preceding it, to avoid conflicts with, respectively, the left shift operator
" and generic Flow type annotations (http://flowtype.org/).
syn region tsxRegion
  \ contains=@Spell,@XMLSyntax,tsxRegion,tsxChild,tsBlock,javascriptBlock
  \ start=+\%(<\|\w\)\@<!<\z([a-zA-Z_][a-zA-Z0-9:\-.]*\>[:,]\@!\)\([^>]*>(\)\@!+
  \ skip=+<!--\_.\{-}-->+
  \ end=+</\z1\_\s\{-}>+
  \ end=+/>+
  \ keepend
  \ extend

" Shorthand fragment support
"
" Note that since the main tsxRegion contains @XMLSyntax, we cannot simply
" adjust the regex above since @XMLSyntax will highlight the opening `<` as an
" XMLError. Instead we create a new group with the same name that does not
" include @XMLSyntax and instead uses matchgroup to get the same highlighting.
syn region tsxRegion
  \ contains=@Spell,tsxRegion,tsxChild,tsBlock,javascriptBlock
  \ matchgroup=xmlTag
  \ start=/<>/
  \ end=/<\/>/
  \ keepend
  \ extend

" Add tsxRegion to the lowest-level JS syntax cluster.
syn cluster tsExpression add=tsxRegion

" Allow tsxRegion to contain reserved words.
syn cluster javascriptNoReserved add=tsxRegion
