local M = {}

local config_files = {
  'oxlint.config.ts',
  'oxlint.config.js',
  'oxlint.config.mjs',
  'oxlint.config.cjs',
  '.oxlintrc.json',
  'oxlintrc.json',
}

local lockfile_to_cmd = {
  ['pnpm-lock.yaml'] = { 'pnpm', 'exec', 'oxlint' },
  ['package-lock.json'] = { 'npx', '--no-install', 'oxlint' },
  ['yarn.lock'] = { 'yarn', 'run', 'oxlint' },
  ['bun.lockb'] = { 'bunx', 'oxlint' },
  ['bun.lock'] = { 'bunx', 'oxlint' },
}

local function find_project_root(filepath)
  local dir = vim.fs.dirname(filepath)

  for _, name in ipairs(config_files) do
    local match = vim.fs.find(name, { path = dir, upward = true })[1]
    if match then
      return vim.fs.dirname(match)
    end
  end

  -- Fallback: find nearest package.json
  local pkg = vim.fs.find('package.json', { path = dir, upward = true })[1]
  if pkg then
    return vim.fs.dirname(pkg)
  end

  return vim.fn.getcwd()
end

local function build_cmd(root)
  for lockfile, cmd in pairs(lockfile_to_cmd) do
    if vim.uv.fs_stat(root .. '/' .. lockfile) then
      return cmd
    end
  end
  return nil
end

function M.setup()
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or client.name ~= 'oxlint' then
        return
      end

      local bufnr = args.buf

      vim.api.nvim_create_autocmd('BufWritePost', {
        buffer = bufnr,
        callback = function()
          local filepath = vim.api.nvim_buf_get_name(bufnr)
          local root = find_project_root(filepath)
          local cmd = build_cmd(root)
          if not cmd then
            return
          end

          cmd = vim.list_extend(vim.deepcopy(cmd), { '--fix', filepath })
          vim.system(cmd, { cwd = root }, function()
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(bufnr) then
                vim.api.nvim_buf_call(bufnr, function()
                  vim.cmd('checktime')
                end)
              end
            end)
          end)
        end,
      })
    end,
  })
end

return M
