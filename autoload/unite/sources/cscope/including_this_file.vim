let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#cscope#including_this_file#define() "{{{
  return s:source
endfunction "}}}

let s:source = {
\ 'name' : 'cscope/including_this_file',
\ 'description' : 'Find files including this file',
\}

function! s:source.change_candidates(args, context) "{{{
  call unite#print_message('[cscope/including_this_file] ')
  if len(a:args) == 0
    let a:context.input = input('Find files including this file: ')
  else
    let a:context.input = a:args[0]
  endif
  
  if !unite#util#has_vimproc()
    call unite#print_source_message(
          \ 'vimproc plugin is not installed.', self.name)
    let a:context.is_async = 0
    return []
  endif

  if a:context.is_redraw
    let a:context.is_async = 1
  endif

  let query = cscope#including_this_file(a:context.input)
  let currentDir = getcwd()
  execute 'cd ' . g:unite_source_cscope_dir
  
  try
    let a:context.source__proc = vimproc#plineopen2(
          \ vimproc#util#iconv(
          \   query, &encoding, 'char'), 1)
  catch
    execute 'cd ' . currentDir
    call unite#print_error(v:exception)
    let a:context.is_async = 0
    return []
  endtry
  execute 'cd ' . currentDir

  return self.async_gather_candidates(a:args, a:context)
endfunction

function! s:source.async_gather_candidates(args, context) "{{{
  let stdout = a:context.source__proc.stdout
  if stdout.eof
    let a:context.is_async = 0
    call a:context.source__proc.waitpid()
  endif

  let data = map(map(unite#util#read_lines(stdout, 1000),
          \ "substitute(unite#util#iconv(v:val, 'char', &encoding), '\\e\\[\\u', '', 'g')"),
          \ "cscope#line_parse(v:val)")

  return map(data, '{
\   "word": v:val.line,
\   "source": s:source.name,
\   "kind": "jump_list",
\   "action__path": v:val.file_name,
\   "action__line": v:val.line_number
\  }')
endfunction"}}}

" context getter {{{
function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

function! unite#sources#cscope#including_this_file#__context__()
  return { 'sid': s:SID, 'scope': s: }
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
