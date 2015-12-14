let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#cscope#find_file#define() "{{{
  return s:source
endfunction "}}}

let s:source = {
\ 'name' : 'cscope/find_file',
\ 'description' : 'disp find_files',
\}

function! s:source.gather_candidates(args, context) "{{{
  call unite#print_message('[cscope/find_file] ')
  call unite#print_message('find this file')

  let keyword = input("Find this file: ")
  let data = cscope#find_file(keyword)

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

function! unite#sources#cscope#find_file#__context__()
  return { 'sid': s:SID, 'scope': s: }
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
