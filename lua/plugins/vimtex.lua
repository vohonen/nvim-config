
vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_quickfix_mode = 0
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_compiler_latexmk = {
    out_dir = 'build',
    callback = 1,
    continuous = 1,
    options = {
        '-pdf',
        '-pdflatex=pdflatex -interaction=nonstopmode -synctex=1 -file-line-error',
        '-bibtex',
        '-verbose',
        '-halt-on-error',
        '-use-make'
    }
}

