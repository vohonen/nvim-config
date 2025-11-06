require('conform').setup({
  formatters_by_ft = {
    python = { 'ruff_format', 'ruff_organize_imports' },
    tex = { 'latexindent' },
    lua = { 'stylua' },
    markdown = { 'prettier' },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
