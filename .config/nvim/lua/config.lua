local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'gs', vim.lsp.buf.document_symbol, opts)
  vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', 'dn', function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
  vim.keymap.set('n', 'dp', function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
  vim.keymap.set('n', 'do', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', opts)
  vim.keymap.set('n', '<C-o>', function()
    vim.cmd('split')
    vim.lsp.buf.definition()
  end, { buffer = bufnr, noremap = true, silent = true })


  vim.lsp.inlay_hint.enable()
  vim.lsp.completion.enable(true, client.id, bufnr, {
    autotrigger = true,
    convert = function(item)
      return { abbr = item.label:gsub('%b()', '') }
    end,
  })
  if client and client.server_capabilities.semanticTokensProvider then
    vim.lsp.semantic_tokens.start(bufnr,client.id)
  end
end

local project_config = vim.fn.getcwd() .. "/.nvim.lua"
if vim.fn.filereadable(project_config) == 1 then
  dofile(project_config)
end

if useLSP == nil then
  useLSP = false
end

if useLSP then
  vim.o.signcolumn = "yes"
  vim.o.completeopt = vim.o.completeopt .. ",menuone,noselect,popup"

  local lspconfig = require('lspconfig')
  lspconfig.ruby_lsp.setup({
    cmd = { 'dx/exec', 'bash', '-lc', 'ruby-lsp', },
    on_attach = on_attach,
    init_options = {
      featuresConfiguration = {
        inlayHint = {
          enableAll = true
        }
      },
    }
  })
  lspconfig.cssls.setup({
    cmd = { 'dx/exec', 'bash', '-lc', 'npx vscode-css-language-server --stdio' },
    on_attach = on_attach,
    before_init = function(params)
      params.processId = vim.NIL
    end,
  })
  lspconfig.ts_ls.setup({
    cmd = { 'dx/exec', 'bash', '-lc', 'npx typescript-language-server --stdio --log-level 4' },
    on_attach = on_attach,
    before_init = function(params)
      params.processId = vim.NIL
    end,
  })
end

require("CopilotChat").setup({
  window = {
    layout = 'horizontal'
  }
})
