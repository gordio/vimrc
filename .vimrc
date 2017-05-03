set nocompatible
lang mes C

" Esc timeout on Mac
set timeoutlen=500 ttimeoutlen=10

execute pathogen#infect()
syntax on
filetype plugin indent on

" Search down into subfolders
" provides tab-ompletion for all file related tasks
" useful for PROJECTS
"set path+=**

set omnifunc=syntaxcomplete#Complete

set background=dark
let g:gruvbox_bold = 1
let g:gruvbox_contrast_dark = "hard"

colorscheme gruvbox
hi Normal ctermfg=7
hi SignColumn ctermbg=8 guibg=darkgrey
hi SpecialKey ctermfg=8 guifg=gray
hi Folded ctermbg=0


set wildmenu " display all matching files when we tab complete
set list listchars=tab:❯\ ,trail:×
"set list listchars=tab:»·,trail:×


let g:netrw_banner=0 " Remove help info
let g:netrw_altv=1   " Open split at right
let g:netrw_liststyle=3

set nobackup          "don't save backup files
set number            "show line numbers
set hlsearch          "highlight search matches
set ignorecase smartcase
set hidden            "allow hiding buffers which have modifications
set linebreak         "break lines, not words
set breakindent       "break lines while preserving indentation
set showbreak=…       "prepend ellipsis and 2 spaces at break
set laststatus=2      "always show status
set backspace=2       " make backspace work


"default indentation
set smartindent
set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab " use tabs (like 4 spaces)
set textwidth=0 wrapmargin=0 " don't auto wrap
set colorcolumn=80


set sessionoptions=buffers,tabpages,help
if has('win32') || has('win64')
	set directory=~/vimfiles/sessions/swaps/
	set viewdir=~/vimfiles/sessions/views/
	set undodir=~/vimfiles/sessions/undos/
	set viminfo='128,/128,:128,<128,s10,h,n~/vimfiles/sessions/viminfo
else
	set directory=~/.vim/sessions/swaps/
	set viewdir=~/.vim/sessions/views/
	set undodir=~/.vim/sessions/undos/
	set viminfo='128,/128,:128,<128,s10,h,n~/.vim/sessions/viminfo
endif


" -- STATUSLINE {{{
function! SLUpdateColor(mode)
	if a:mode == 'i'
		hi statusline ctermfg=4 ctermbg=0 guibg=Cyan guifg=Black
	elseif a:mode == 'r'
		hi statusline ctermfg=1 ctermbg=0 guibg=Purple guifg=Black
	else
		hi statusline ctermfg=1 ctermbg=0 guibg=DarkRed guifg=Black
	endif
endfunction

au InsertEnter * call SLUpdateColor(v:insertmode)
au InsertLeave * hi StatusLine ctermfg=8 ctermbg=15 guibg=DarkGrey guifg=White
hi StatusLine ctermfg=8 ctermbg=15 guibg=DarkGrey guifg=White
hi StatusLineNC ctermfg=0 ctermbg=0 guibg=DarkGrey guifg=Black

fu! SLReadOnly()
	if &readonly || !&modifiable
		return ''
	else
		return ''
	endif
endfu

" Find out current buffer's size and output it.
fu! SLFileSize()
	let bytes = getfsize(expand('%:p'))
	if (bytes >= 1024)
		let kbytes = bytes / 1024
	endif
	if (exists('kbytes') && kbytes >= 1000)
		let mbytes = kbytes / 1000
	endif

	if (bytes <= 0)
		return '0'
	endif

	if (exists('mbytes'))
		return mbytes . 'MB'
	elseif (exists('kbytes'))
		return kbytes . 'KB'
	else
		return bytes . 'B'
	endif
endfu

fu! SLGitBranch()
	if exists('*fugitive#statusline')
		return substitute(fugitive#statusline(), '\c\v\[?GIT\(([a-z0-9\-_\./:]+)\)\]?', ':\1', 'g')
	else
		return ''
	endif
endfu

" now set it up to change the status line based on mode

set stl=
"set stl=\ %n\                  "buffer number
set stl+=%0*\ %{toupper(mode())}\ :
set stl+=%<%#sl_file#%F%*                                     " Filename
set stl+=%#sl_minor#%{&mod?'*':''}%h%r%*                      " Filemodes
set stl+=%{SLReadOnly()}
set stl+=%#sl_branch#%{SLGitBranch()}%*           " git branch name
set stl+=\ (%{SLFileSize()})
set stl+=%#sl_minor#
set stl+=\ ❯\ %*%{&ft!=''?&ft:'No-FT'}                        " filetype
set stl+=%{(&fenc!='utf-8'&&&fenc!='')?'\ \ >\ '.&fenc:''}    " file encoding
set stl+=%{(&ff!='unix'&&&ff!='')?'\ \ >\ '.&ff:''}           " file endings
set stl+=%*                                                   " use default color
set stl+=\ %=                                                 " vim stl left/right separator
"set stl+={%{synIDattr(synID(line('.'),col('.'),1),'name')}}   " highlight
"set stl+=\ \%w(%b,0x%B)                                       " char info
set stl+=\ %#sl_minor#%c%*                                    " cursor position
set stl+=\ (%l\ of\ %L)\ %P\                                  " offsets
" endSTATUSLINE }}}


" #-- Leader {{{
let mapleader="," "set leader

" Toggle
nmap <leader>tp :setl paste!<CR>
nmap <leader>ts :setl spell!<CR>
" Reindent file
nmap <leader>fi mzgg=G`z

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX files.
function! AppendModeline()
	let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set :", &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
	let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
	call append(line("$"), l:modeline)
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

map <silent><leader>v :tabnew $MYVIMRC<CR>
map <silent><leader>e :tabnew $MYVIMRC<CR>
if has('gui')
	map <silent><leader>u :call UpdateConfig()<CR>
else
	map <silent><leader>u :source $MYVIMRC<CR>
endif
"}}}


" Folding {{{
set foldtext=SimpleFoldText()
fu! SimpleFoldText()
	let nl = v:foldend - v:foldstart + 1
	let foldline = substitute(getline(v:foldstart), "^ *", "", 1)
	let nextline = substitute(getline(v:foldstart + 1), "^ *", "", 1)
	let txt = '+ ' .  foldline . repeat(' ', winwidth(0))
	let info = ' ' . nl . ' lines '
	let num_w = getwinvar(0, '&number') * getwinvar(0, '&numberwidth')
	let fold_w = getwinvar(0, '&foldcolumn')
	let txt = strpart(txt, 0, winwidth(0) - strlen(info) - num_w - fold_w - 2)
	return txt . info
endfu
"}}}


if !exists("*UpdateConfig")
	fu UpdateConfig()
		:source $MYVIMRC
		if has('gui')
			:source $MYGVIMRC
		endif
	endf
endif

if has('autocmd')
	" auto reload config after save
	au! BufWritePost .vimrc :call UpdateConfig()

	au! FileType svn,*commit*,*.txt,*.md setlocal spell spelllang=en,ru
endif



" ================================= Plugins ================================= "
" NERDCommenter {{{
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 0
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1
" Add your own custom formats or override the defaults
"let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

nnoremap <leader>cc :call NERDComment(0, "toggle")<CR>
vnoremap <leader>cc :call NERDComment(0, "toggle")<CR>
"}}}


" Jedi {{{
let g:jedi#auto_initialization = 0

" There are also some VIM options (like completeopt and key defaults) which are automatically initialized, but you can skip this:
"let g:jedi#auto_vim_configuration = 0

" You can make jedi-vim use tabs when going to a definition etc:
let g:jedi#use_tabs_not_buffers = 1

" If you are a person who likes to use VIM-splits, you might want to put this in your .vimrc:
let g:jedi#use_splits_not_buffers = "right"

let g:jedi#goto_command = "<leader>d"
let g:jedi#goto_assignments_command = "<leader>g"
let g:jedi#goto_definitions_command = "<leader>f"
let g:jedi#documentation_command = "K"
let g:jedi#usages_command = "<leader>n"
let g:jedi#completions_command = "<C-Space>"
let g:jedi#rename_command = "<leader>r"
"}}}


" UltiSnip {{{
let g:UltiSnipsSnippetDirectories = ['~/.vim/UltiSnips', 'UltiSnips']
"let g:UltiSnipsUsePythonVersion = 2
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

" If you want :UltiSnipsEdit to split your window.
"let g:UltiSnipsEditSplit="vertical"
nnoremap <leader>u :UltiSnipsEdit<CR>
"}}}


" Close tag {{{
let g:closetag_filenames = "*.html,*.xhtml,*.phtml"
"}}}


" Align {{{
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
"}}}


" GitGutter {{{
let g:gitgutter_sign_column_always = 1
let g:gitgutter_override_sign_column_highlight = 0
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '_'
let g:gitgutter_sign_removed_first_line = '^'
let g:gitgutter_sign_modified_removed = '*'
"}}}


" Clang-format {{{
let g:clang_format#style_options = {
            \ "IndentWidth" : 4,
            \ "AccessModifierOffset" : -4,
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "Standard" : "C++11",
            \ "BreakBeforeBraces" : "Stroustrup",
            \ "UseTab" : "Always"}

" map to <Leader>cf in C++ code
autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
" if you install vim-operator-user
autocmd FileType c,cpp,objc map <buffer><Leader>x <Plug>(operator-clang-format)
" Toggle auto formatting:
nmap <Leader>C :ClangFormatAutoToggle<CR>
"}}}
" vim: set fen fdm=marker ts=4 sw=4 tw=78 noet :
