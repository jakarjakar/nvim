-- Statusline: show active Python venv + relative file path.
-- Detection priority:
--   1. $VIRTUAL_ENV (nvim launched with venv active)
--   2. nearest .venv/ or venv/ found upward from buffer dir
--   3. pyright LSP setting python.pythonPath (per-project override)

local cache = {}

local function venv_name_from_path(p)
  p = p:gsub("/+$", "")
  local base = vim.fn.fnamemodify(p, ":t")
  if base == ".venv" or base == "venv" then
    return vim.fn.fnamemodify(p, ":h:t")
  end
  return base
end

local function detect_venv(buf_dir)
  if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
    return venv_name_from_path(vim.env.VIRTUAL_ENV)
  end

  if buf_dir == "" then return nil end
  if cache[buf_dir] ~= nil then return cache[buf_dir] end

  local found = vim.fs.find({ ".venv", "venv" }, {
    upward = true,
    type = "directory",
    path = buf_dir,
    stop = vim.loop.os_homedir(),
  })[1]

  if found then
    cache[buf_dir] = venv_name_from_path(found)
    return cache[buf_dir]
  end

  for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
    local pp = vim.tbl_get(client.config.settings or {}, "python", "pythonPath")
    if pp and pp ~= "" then
      cache[buf_dir] = venv_name_from_path(vim.fn.fnamemodify(pp, ":h:h"))
      return cache[buf_dir]
    end
  end

  cache[buf_dir] = false
  return nil
end

function _G.user_winbar()
  local buf = vim.api.nvim_buf_get_name(0)
  local dir = buf ~= "" and vim.fs.dirname(buf) or vim.fn.getcwd()
  local venv = detect_venv(dir)

  local path = buf ~= "" and vim.fn.fnamemodify(buf, ":~:.") or "[No Name]"
  if vim.bo.modified then path = path .. " [+]" end

  if venv then
    return "venv:" .. venv .. " │ " .. path
  end
  return path
end

vim.o.statusline = "%{v:lua.user_winbar()}"

vim.api.nvim_create_autocmd({ "DirChanged", "LspAttach" }, {
  callback = function() cache = {} end,
})

vim.api.nvim_create_user_command("VenvShow", function()
  local v = vim.env.VIRTUAL_ENV
  if v and v ~= "" then
    vim.notify("VIRTUAL_ENV=" .. v)
  else
    local d = detect_venv(vim.fn.expand("%:p:h"))
    vim.notify(d and ("project venv: " .. d) or "no venv detected")
  end
end, {})
