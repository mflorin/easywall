" Vim syntax file
" Language:	generic configure file
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last Change:	2001 Apr 25

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn keyword	fwTodo	contained TODO FIXME XXX
syn match 	fwComment "#.*$"
syn keyword	fwKeyword in out forw snat dnat masq port alias prerouting postrouting mac iface oface syn
syn match	fwKeyword "\snlgroup\s" 
syn match	fwKeyword "\suprefix\s" 
syn match	fwKeyword "\scprange\s" 
syn match	fwKeyword "\sqthreshold\s" 
syn match	fwKeyword "\slevel\s" 
syn match	fwKeyword "\sprefix\s" 
syn match	fwKeyword "\stcp-seq\s"
syn match	fwKeyword "\stcp-opt\s" 
syn match	fwKeyword "\sip-opt\s"
syn match	fwKeyword "\icmp-type\s"
syn keyword	fwKeyword options need acl module policy proto state limit burst
syn match	fwIP "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*"
syn match	fwIP "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\/[0-9]*"
syn match	fwProc "\sproc\s"
syn keyword	fwInclude include run load
syn keyword	fwScope    src dst dport sport
syn keyword	fwTarget   drop accept log ulog mark tos ttl

hi def link	fwKeyword		Keyword 
hi def link	fwProc			Keyword
hi def link	fwInclude		Include
hi def link	fwTarget		Identifier
hi def link	fwScope			Type
hi def link	fwIP			Special
hi def link 	fwComment 		Comment

" vim: ts=8 sw=2
