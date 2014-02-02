"===============================================================================
" Startup Pathogen
"===============================================================================
filetype off
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()
syntax on
filetype on
filetype plugin indent on

"===============================================================================
" General vim settings.
"===============================================================================
set nocompatible
set modelines=5
set tabstop=4
set shiftwidth=4
set softtabstop=4
set encoding=utf-8
set number
set list
set scrolloff=3
set pastetoggle=<F6>
set cursorline
if version >= 703
	set colorcolumn=80
	set listchars=tab:▸\ ,eol:¬,nbsp:¶,eol:¬,extends:»,precedes:«,trail:• "
endif

"===============================================================================
" enable plugins
"===============================================================================
au FocusLost * :wa
au BufRead,BufNewFile *.cf set ft=cf3

"===============================================================================
" Colors..
"===============================================================================
colorscheme jellybeans

"===============================================================================
" Variables for template interpolation
"===============================================================================
let email_address = "code@hurlic.com"
let fullname      = "Keith Hurlic"
let company_name  = "home"
let template_date_format_string = "%a %b %d %Y"

"===============================================================================
" => Statusline
"===============================================================================
set laststatus=2
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{CurDir()}%h\ \ \Line:\ %l/%L:%c
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
function! CurDir()
	let curdir = substitute(getcwd(), '/home/khurlic', "~/", "g")
	return curdir
endfunction

function! HasPaste()
	if &paste
		return 'PASTE MODE  '
	else
		return ''
	endif
endfunction
