set nocompatible
filetype off

" --- Vundle ---
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'vim-syntastic/syntastic'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'hashivim/vim-terraform'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'pearofducks/ansible-vim'
set rtp+=/opt/homebrew/opt/fzf
Plugin 'junegunn/fzf.vim'

call vundle#end()
filetype plugin indent on

" --- Search (fzf + rg) ---
if executable('rg')
  set grepprg=rg\ --color=never
endif

" --- General ---
set ttyfast
syntax on
set encoding=utf-8
set number
set ignorecase
set smartcase
set list
set listchars=tab:»\ ,trail:·
set history=10000
set backupdir=/tmp
set autoindent
set smartindent
set shiftwidth=2
set tabstop=4
set softtabstop=0
set expandtab
set smarttab
set backspace=indent,eol,start
set hlsearch
set incsearch
set showcmd
set laststatus=2
set statusline=%f%m%r%h%w\ [%Y\ %{&ff}]\ [%l/%L\ (%p%%)]
colorscheme desert

" --- Filetype overrides ---
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=120 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

au BufNewFile,BufRead *.js,*.html,*.css,*.sh
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2

" --- Keys ---
let mapleader = "\<Space>"
vnoremap . :normal .<CR>

" --- Airline ---
let g:airline_powerline_fonts = 1
let g:airline_theme='bubblegum'
