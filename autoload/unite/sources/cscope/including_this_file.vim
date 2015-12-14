let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#cscope#including_this_file#define() "{{{
  return s:source
endfunction "}}}

let s:source = {
\ 'name' : 'cscope/including_this_file',
\ 'description' : 'disp including_this_files',
\}

function! s:source.gather_candidates(args, context) "{{{
  call unite#print_message('[cscope/including_this_file] ')
  call unite#print_message('find files including this file')

  let keyword = input("Find files including this file: ")
  let data = cscope#including_this_file(keyword)

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

function! unite#sources#cscope#including_this_file#__context__()
  return { 'sid': s:SID, 'scope': s: }
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
