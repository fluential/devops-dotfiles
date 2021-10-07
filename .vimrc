
set nocompatible              " required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
" Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-syntastic/syntastic'
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'hashivim/vim-terraform'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'pearofducks/ansible-vim'
set rtp+=~/.fzf
Plugin 'junegunn/fzf.vim'
" add all your plugins here (note older versions of Vundle
" used Bundle instead of Plugin)

" ...

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

if executable('rg')
  set grepprg=rg\ --color=never
  let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
  let g:ctrlp_use_caching = 0
endif

" filetype on
" filetype plugin indent on
 set ttyfast
 syntax on
 set autoindent
 set encoding=utf-8
" autocmd filetype python setlocal ts=4 sw=4 sts=4 et
 set number
 set ignorecase
 set list
 set listchars=tab:»\ ,trail:·
 set history=10000
 set backupdir=/tmp
" set paste
 set smartindent
 set shiftwidth=2
 set backspace=2
 set smarttab
 set hlsearch
" set winwidth=79
" set foldmethod=indent
 set incsearch
 set showcmd
" set foldlevel=1000
" set nolinebreak
" set scrolloff=3
 set tabstop=4
 set softtabstop=0
" autocmd BufRead * set tw=9999
" setlocal textwidth=999
:colorscheme desert
 set expandtab
 set backspace=indent,eol,start
" set scrolloff=3
set statusline=%f%m%r%h%w\ [%Y\ %{&ff}]\ [%l/%L\ (%p%%)]
set laststatus=2
" set colorcolumn=79
let mapleader = "\<Space>"
vnoremap . :normal .<CR>
" Install via https://github.com/powerline/fonts
:let g:airline_powerline_fonts = 1
:let g:airline_theme='bubblegum'

