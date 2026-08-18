-- Global statusline on the last screen line (cmdheight=0 + laststatus=3).
-- Segments: filetype icon + path │  venv │  branch + counts │  date time
--
-- Venv detection priority:
--   1. $VIRTUAL_ENV (nvim launched with venv active)
--   2. nearest .venv/ or venv/ found upward from buffer dir
--   3. pyright LSP setting python.pythonPath (per-project override)
--
-- Git info is collected asynchronously (vim.system) and cached per repo root,
-- so the statusline never blocks on a git call.

local M = {}

--------------------------------------------------------------------- icons ---

-- Nerd Font glyphs written as escapes: the raw private-use-area characters do
-- not survive every editor/pipe, so \u{...} keeps them intact.
local icons = {
  python = "\u{e73c}", -- nf-dev-python
  git = "\u{e725}", -- nf-dev-git_branch
  clock = "\u{f017}", -- nf-fa-clock_o
  file = "\u{f15b}", -- nf-fa-file
}

-- nvim-web-devicons is loaded by snacks.lua; degrade to a plain glyph if absent.
local function file_icon(path)
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return icons.file
  end
  local name = vim.fn.fnamemodify(path, ":t")
  local ext = vim.fn.fnamemodify(path, ":e")
  local icon = devicons.get_icon(name, ext, { default = true })
  return icon or icons.file
end

--------------------------------------------------------------------- venv ----

local venv_cache = {}

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

  if buf_dir == "" then
    return nil
  end
  if venv_cache[buf_dir] ~= nil then
    return venv_cache[buf_dir] or nil
  end

  local found = vim.fs.find({ ".venv", "venv" }, {
    upward = true,
    type = "directory",
    path = buf_dir,
    stop = vim.uv.os_homedir(),
  })[1]

  if found then
    venv_cache[buf_dir] = venv_name_from_path(found)
    return venv_cache[buf_dir]
  end

  for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
    local pp = vim.tbl_get(client.config.settings or {}, "python", "pythonPath")
    if pp and pp ~= "" then
      venv_cache[buf_dir] = venv_name_from_path(vim.fn.fnamemodify(pp, ":h:h"))
      return venv_cache[buf_dir]
    end
  end

  venv_cache[buf_dir] = false
  return nil
end

---------------------------------------------------------------------- git ----

-- git_cache[root] = { branch = "main", added = 1, changed = 2, removed = 0,
--                     untracked = 1, ahead = 0, behind = 0 }
local git_cache = {}
local git_pending = {}

local function buf_dir()
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= "" and vim.bo.buftype == "" then
    return vim.fs.dirname(name)
  end
  return vim.fn.getcwd()
end

local function git_root(dir)
  local found = vim.fs.find(".git", { upward = true, path = dir, stop = vim.uv.os_homedir() })[1]
  return found and vim.fs.dirname(found) or nil
end

-- Parse `git status --porcelain=v2 --branch` output.
local function parse_status(out)
  local st = { branch = nil, changed = 0, added = 0, removed = 0, untracked = 0, ahead = 0, behind = 0 }
  for line in out:gmatch("[^\n]+") do
    if line:match("^# branch%.head ") then
      local head = line:sub(#"# branch.head " + 1)
      st.branch = head ~= "(detached)" and head or nil
    elseif line:match("^# branch%.ab ") then
      st.ahead = tonumber(line:match("%+(%d+)")) or 0
      st.behind = tonumber(line:match("%-(%d+)")) or 0
    elseif line:match("^%?") then
      st.untracked = st.untracked + 1
    elseif line:match("^[12u] ") then
      -- field 2 is XY: staged/unstaged status codes
      local xy = line:match("^[12u] (..)")
      if xy and xy:find("A") then
        st.added = st.added + 1
      elseif xy and xy:find("D") then
        st.removed = st.removed + 1
      else
        st.changed = st.changed + 1
      end
    end
  end
  if st.branch == nil then
    st.branch = "detached"
  end
  return st
end

local function refresh_git(dir)
  local root = git_root(dir)
  if not root or git_pending[root] then
    return
  end
  git_pending[root] = true

  vim.system(
    { "git", "-C", root, "--no-optional-locks", "status", "--porcelain=v2", "--branch" },
    { text = true },
    function(res)
      git_pending[root] = nil
      local st = res.code == 0 and parse_status(res.stdout or "") or false
      vim.schedule(function()
        git_cache[root] = st
        vim.cmd.redrawstatus()
      end)
    end
  )
end

local function git_segment(dir)
  local root = git_root(dir)
  local st = root and git_cache[root]
  if not st then
    return nil
  end

  local parts = { icons.git .. " " .. st.branch }
  if st.added > 0 then
    parts[#parts + 1] = "+" .. st.added
  end
  if st.changed > 0 then
    parts[#parts + 1] = "~" .. st.changed
  end
  if st.removed > 0 then
    parts[#parts + 1] = "-" .. st.removed
  end
  if st.untracked > 0 then
    parts[#parts + 1] = "?" .. st.untracked
  end
  if st.ahead > 0 then
    parts[#parts + 1] = "↑" .. st.ahead
  end
  if st.behind > 0 then
    parts[#parts + 1] = "↓" .. st.behind
  end
  return table.concat(parts, " ")
end

--------------------------------------------------------------- statusline ----

function _G.user_statusline()
  local name = vim.api.nvim_buf_get_name(0)
  local dir = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()

  local path = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"
  if vim.bo.modified then
    path = path .. " [+]"
  end
  if vim.bo.readonly then
    path = path .. " [RO]"
  end

  local left = { file_icon(name) .. " " .. path }

  local venv = detect_venv(dir)
  if venv then
    left[#left + 1] = icons.python .. " " .. venv
  end

  local git = git_segment(dir)
  if git then
    left[#left + 1] = git
  end

  -- %= pushes the clock to the right edge; %l:%c gives cursor position back
  -- (ruler is disabled globally).
  local clock = icons.clock .. " " .. os.date("%d-%b %H:%M")
  return " " .. table.concat(left, " │ ") .. " %=%l:%c │ " .. clock .. " "
end

vim.o.statusline = "%{%v:lua.user_statusline()%}"
vim.o.laststatus = 3 -- global statusline, sits on the last screen line

------------------------------------------------------------------ refresh ----

local group = vim.api.nvim_create_augroup("user_statusline", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained", "DirChanged", "VimResume" }, {
  group = group,
  callback = function()
    refresh_git(buf_dir())
  end,
})

vim.api.nvim_create_autocmd({ "DirChanged", "LspAttach" }, {
  group = group,
  callback = function()
    venv_cache = {}
  end,
})

-- Clock tick + periodic git poll (picks up changes made outside nvim).
local timer = vim.uv.new_timer()
timer:start(
  1000,
  20000,
  vim.schedule_wrap(function()
    refresh_git(buf_dir())
    vim.cmd.redrawstatus()
  end)
)

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = function()
    if timer and not timer:is_closing() then
      timer:stop()
      timer:close()
    end
  end,
})

refresh_git(buf_dir())

vim.api.nvim_create_user_command("VenvShow", function()
  local v = vim.env.VIRTUAL_ENV
  if v and v ~= "" then
    vim.notify("VIRTUAL_ENV=" .. v)
  else
    local d = detect_venv(vim.fn.expand("%:p:h"))
    vim.notify(d and ("project venv: " .. d) or "no venv detected")
  end
end, {})

return M
