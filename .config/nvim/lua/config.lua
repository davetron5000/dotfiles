local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'gs', vim.lsp.buf.document_symbol, opts)
  vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', 'gn', function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
  vim.keymap.set('n', 'gp', function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
  vim.keymap.set('n', 'go', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', opts)
  -- vim.keymap.set('n', '<C-o>', function()
  --   vim.cmd('split')
  --   vim.lsp.buf.definition()
  -- end, { buffer = bufnr, noremap = true, silent = true })


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
    cmd = { 'dx/exec', 'ruby-lsp', },
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
    cmd = { 'dx/exec', 'npx vscode-css-language-server --stdio' },
    on_attach = on_attach,
    before_init = function(params)
      params.processId = vim.NIL
    end,
  })
  lspconfig.ts_ls.setup({
    cmd = { 'dx/exec', 'npx typescript-language-server --stdio --log-level 4' },
    on_attach = on_attach,
    before_init = function(params)
      params.processId = vim.NIL
    end,
  })
end

local function short_path()
  local filepath = vim.api.nvim_buf_get_name(0) -- full path
  if filepath == '' then return '' end

  local cwd = vim.fn.getcwd()
  if vim.fn.fnamemodify(filepath, ':p:h') == cwd then
    return vim.fn.fnamemodify(filepath, ':t') -- just filename
  end

  local parts = vim.split(filepath, '/')
  local count = #parts
  if count >= 3 then
    return table.concat({ parts[count - 2], parts[count - 1], parts[count] }, '/')
  else
    return table.concat(parts, '/')
  end
end


require('lualine').setup({
  sections = {
    lualine_a = { short_path },
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {},
    lualine_x = { 'lsp_status' },
    lualine_y = { 'filetype' },
  }
})
