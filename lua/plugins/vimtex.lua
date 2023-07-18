
vim.g.vimtex_view_method = 'zathura'
-- vim.g['tex_flavor'] = 'latex'
-- hide warnings (also hides errors, comment out when debugging compilation)
vim.g.vimtex_quickfix_mode = 0

vim.cmd [[
	let g:vimtex_compiler_latexmk = {
    \ 'out_dir' : 'build',
    \}	
]]

-- vim.cmd([[let g:vimtex_log_ignore = [
--         \ 'Underfull',
--         \ 'Overfull',
--         \ 'specifier changed to',
--         \ 'Token not allowed in a PDF string',
--       \ ]
-- 	  ]])

