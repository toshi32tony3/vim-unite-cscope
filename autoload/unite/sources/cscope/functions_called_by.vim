let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#cscope#functions_called_by#define() "{{{
  return s:source
endfunction "}}}

let s:source = {
\ 'name' : 'cscope/functions_called_by',
\ 'description' : 'Find functions called by this function',
\}

function! s:source.gather_candidates(args, context) "{{{
  call unite#print_message('[cscope/functions_called_by] ')
  call unite#print_message('find functions called by')

  let keyword = input("Find functions called by: ")
  let data = cscope#functions_called_by(keyword)

  return map(data, '{
\   "word": v:val.line,
\   "source": s:source.name,
\   "kind": "jump_list",
\   "action__path": v:val.file_name,
\   "action__line": v:val.line_number
\  }')
endfunction "}}}

" context getter {{{
function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

function! unite#sources#cscope#functions_called_by#__context__()
  return { 'sid': s:SID, 'scope': s: }
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__