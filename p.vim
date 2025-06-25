let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/main/sequin
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +821 lua/sequin.lua
argglobal
%argdel
edit lua/sequin.lua
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
let s:cpo_save=&cpo
set cpo&vim
inoremap <buffer> <M-e> l<Cmd>lua require('nvim-autopairs.fastwrap').show()
nnoremap <buffer> K <Cmd>lua vim.lsp.buf.hover()
nnoremap <buffer> [d <Cmd>lua vim.diagnostic.goto_prev()
nnoremap <buffer> ]d <Cmd>lua vim.diagnostic.goto_next()
nnoremap <buffer> gl <Cmd>lua vim.diagnostic.open_float()
nnoremap <buffer> gs <Cmd>lua vim.lsp.buf.signature_help()
nnoremap <buffer> go <Cmd>lua vim.lsp.buf.type_definition()
nnoremap <buffer> <F4> <Cmd>lua vim.lsp.buf.code_action()
nnoremap <buffer> <F2> <Cmd>lua vim.lsp.buf.rename()
let &cpo=s:cpo_save
unlet s:cpo_save
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal nobinary
setlocal nobreakindent
setlocal breakindentopt=
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),0],:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinscopedecls=public,protected,private
setlocal cinwords=if,else,while,do,for,switch
setlocal colorcolumn=
setlocal comments=:---,:--
setlocal commentstring=--\ %s
setlocal complete=.,w,b,u,t
setlocal completefunc=
setlocal completeslash=
setlocal concealcursor=
setlocal conceallevel=0
setlocal nocopyindent
setlocal nocursorbind
setlocal nocursorcolumn
setlocal cursorline
setlocal cursorlineopt=both
setlocal define=\\<function\\|\\<local\\%(\\s\\+function\\)\\=
setlocal nodiff
setlocal eventignorewin=
setlocal expandtab
if &filetype != 'lua'
setlocal filetype=lua
endif
setlocal fillchars=eob:\ ,fold:\ ,foldopen:,foldsep:\ ,foldclose:
setlocal fixendofline
setlocal foldcolumn=1
setlocal foldenable
setlocal foldexpr=v:lua.vim.treesitter.foldexpr()
setlocal foldignore=#
setlocal foldlevel=99
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=v:lua.require'ufo.main'.foldtext()
setlocal formatexpr=v:lua.vim.lsp.formatexpr()
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal formatoptions=jcroql
setlocal iminsert=0
setlocal imsearch=-1
setlocal include=\\<\\%(\\%(do\\|load\\)file\\|require\\)\\s*(
setlocal includeexpr=v:lua.require'vim._ftplugin.lua'.includeexpr(v:fname)
setlocal indentexpr=nvim_treesitter#indent()
setlocal indentkeys=0{,0},0),0],:,0#,!^F,o,O,e,0=end,0=until
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal lhistory=10
setlocal nolinebreak
setlocal nolisp
setlocal lispoptions=
setlocal list
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=bin,hex
setlocal number
setlocal numberwidth=2
setlocal omnifunc=v:lua.vim.lsp.omnifunc
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norelativenumber
setlocal norightleft
setlocal rightleftcmd=search
setlocal scrollback=-1
setlocal noscrollbind
setlocal shiftwidth=2
setlocal signcolumn=yes
setlocal smartindent
setlocal nosmoothscroll
setlocal softtabstop=2
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\\t\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal spelloptions=noplainbuffer
setlocal statuscolumn=
setlocal suffixesadd=.lua
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != ''
setlocal syntax=
endif
setlocal tabstop=2
setlocal tagfunc=v:lua.vim.lsp.tagfunc
setlocal textwidth=0
setlocal undofile
setlocal varsofttabstop=
setlocal vartabstop=
setlocal winbar=%{%v:lua.dropbar()%}
setlocal winblend=0
setlocal nowinfixbuf
setlocal nowinfixheight
setlocal nowinfixwidth
setlocal winhighlight=
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
sil! 11,15fold
sil! 8,16fold
sil! 5,18fold
sil! 20,22fold
sil! 25,27fold
sil! 32,35fold
sil! 30,36fold
sil! 28,38fold
sil! 43,45fold
sil! 48,53fold
sil! 46,54fold
sil! 55,59fold
sil! 39,60fold
sil! 65,67fold
sil! 68,70fold
sil! 74,76fold
sil! 71,77fold
sil! 78,80fold
sil! 63,82fold
sil! 61,84fold
sil! 87,89fold
sil! 94,96fold
sil! 91,97fold
sil! 90,98fold
sil! 100,102fold
sil! 109,111fold
sil! 106,112fold
sil! 105,113fold
sil! 118,120fold
sil! 116,121fold
sil! 114,124fold
sil! 133,137fold
sil! 142,146fold
sil! 140,147fold
sil! 155,159fold
sil! 161,175fold
sil! 176,180fold
sil! 154,181fold
sil! 184,188fold
sil! 183,189fold
sil! 192,196fold
sil! 198,202fold
sil! 191,203fold
sil! 190,204fold
sil! 150,205fold
sil! 209,213fold
sil! 138,214fold
sil! 218,221fold
sil! 216,225fold
sil! 131,226fold
sil! 229,231fold
sil! 3,233fold
sil! 243,247fold
sil! 240,248fold
sil! 237,250fold
sil! 251,253fold
sil! 255,257fold
sil! 261,263fold
sil! 268,271fold
sil! 266,272fold
sil! 264,274fold
sil! 282,284fold
sil! 279,285fold
sil! 286,288fold
sil! 277,290fold
sil! 275,292fold
sil! 295,297fold
sil! 302,304fold
sil! 299,305fold
sil! 298,306fold
sil! 308,310fold
sil! 317,319fold
sil! 314,320fold
sil! 313,321fold
sil! 326,328fold
sil! 324,329fold
sil! 322,332fold
sil! 341,345fold
sil! 350,354fold
sil! 348,355fold
sil! 359,363fold
sil! 366,370fold
sil! 365,371fold
sil! 358,372fold
sil! 376,380fold
sil! 346,381fold
sil! 385,388fold
sil! 383,392fold
sil! 339,393fold
sil! 396,398fold
sil! 235,400fold
sil! 405,407fold
sil! 410,412fold
sil! 413,419fold
sil! 402,422fold
sil! 424,432fold
sil! 435,437fold
sil! 438,440fold
sil! 441,443fold
sil! 434,445fold
sil! 448,454fold
sil! 447,455fold
sil! 458,474fold
sil! 486,490fold
sil! 492,496fold
sil! 485,499fold
sil! 484,500fold
sil! 507,509fold
sil! 512,514fold
sil! 517,519fold
sil! 457,521fold
sil! 543,545fold
sil! 523,547fold
sil! 551,556fold
sil! 550,557fold
sil! 549,558fold
sil! 565,567fold
sil! 563,568fold
sil! 560,570fold
sil! 573,575fold
sil! 579,581fold
sil! 583,585fold
sil! 591,593fold
sil! 590,594fold
sil! 601,609fold
sil! 614,616fold
sil! 613,617fold
sil! 572,618fold
sil! 621,629fold
sil! 640,642fold
sil! 637,643fold
sil! 651,655fold
sil! 648,656fold
sil! 620,658fold
sil! 661,669fold
sil! 673,676fold
sil! 683,685fold
sil! 679,687fold
sil! 698,700fold
sil! 660,702fold
sil! 709,711fold
sil! 738,747fold
sil! 737,748fold
sil! 753,755fold
sil! 761,763fold
sil! 750,766fold
sil! 749,767fold
sil! 771,773fold
sil! 778,780fold
sil! 769,783fold
sil! 768,784fold
sil! 785,788fold
sil! 789,792fold
sil! 793,795fold
sil! 799,801fold
sil! 796,803fold
sil! 807,809fold
sil! 804,813fold
sil! 707,815fold
sil! 705,816fold
sil! 819,822fold
sil! 817,823fold
sil! 704,824fold
let &fdl = &fdl
549
sil! normal! zo
let s:l = 556 - ((27 * winheight(0) + 21) / 42)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 556
normal! 07|
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
