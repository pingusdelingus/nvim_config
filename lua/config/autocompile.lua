local keymap = vim.keymap.set

local function get_toggleterm()
  local status_ok, terminal_module = pcall(require, "toggleterm.terminal")
  if not status_ok then
    vim.cmd("Lazy load toggleterm.nvim")
    status_ok, terminal_module = pcall(require, "toggleterm.terminal")
  end
  return status_ok, terminal_module
end

local function runPython(filename_full_path)
  print("Compiling Python ...")
  local status_ok, terminal_module = get_toggleterm()
  if not status_ok then
    return
  end

  local pycwd = vim.fn.fnamemodify(filename_full_path, ":h")
  local pyruncmd = "python3 " .. vim.fn.shellescape(filename_full_path)

  local term_to_run = terminal_module.Terminal:new({
    cmd = pyruncmd,
    dir = pycwd,
    direction = "horizontal",
    focus = true,
    close_on_exit = false,
    on_open = function(t)
      vim.keymap.set(
        "t",
        "<Esc>",
        "<Cmd>close<CR><Cmd>bdelete! " .. t.bufnr .. "<CR>",
        { buffer = t.bufnr, silent = true }
      )
    end,
  })
  term_to_run:toggle()
end

local function checkForRakefile()
  local paths = {
    vim.fn.getcwd() .. "/Rakefile",
    vim.fn.getcwd() .. "/rakefile",
    vim.fn.expand("%:p:h") .. "/Rakefile",
    vim.fn.expand("%:p:h") .. "/rakefile",
    vim.fn.expand("%:p:h") .. "/../Rakefile",
    vim.fn.expand("%:p:h") .. "/../rakefile",
    vim.fn.expand("%:p:h") .. "/../build/Rakefile",
    vim.fn.expand("%:p:h") .. "/../build/rakefile",
  }

  for _, path in ipairs(paths) do
    if vim.fn.filereadable(path) == 1 then
      return vim.fn.simplify(vim.fn.fnamemodify(path, ":h")), vim.fn.simplify(path)
    end
  end
  return nil, nil
end

local function checkForMakefile()
  local paths = {
    vim.fn.getcwd() .. "/Makefile",
    vim.fn.getcwd() .. "/makefile",
    vim.fn.expand("%:p:h") .. "/Makefile",
    vim.fn.expand("%:p:h") .. "/makefile",
    vim.fn.expand("%:p:h") .. "/../Makefile",
    vim.fn.expand("%:p:h") .. "/../makefile",
    vim.fn.expand("%:p:h") .. "/../build/Makefile",
    vim.fn.expand("%:p:h") .. "/../build/makefile",
  }

  for _, path in ipairs(paths) do
    if vim.fn.filereadable(path) == 1 then
      return vim.fn.simplify(vim.fn.fnamemodify(path, ":h")), vim.fn.simplify(path)
    end
  end
  return nil, nil
end

local function runCCPP(filename_full_path, output_name, CC)
  -- Use vim.fn.system to compile silently first
  local run_cmd = ""
  local make_dir, make_path = checkForMakefile()
  print("Compiling C/C++...")
  local comp_cmd = ""

  if make_path then
    comp_cmd = string.format("cd %s && make", vim.fn.shellescape(make_dir))
    run_cmd = output_name
  else
    comp_cmd = string.format("%s -Wall %s -o %s", CC, vim.fn.shellescape(filename_full_path), output_name)
    run_cmd = output_name
  end

  local output = vim.fn.system(comp_cmd)
  if vim.v.shell_error ~= 0 then
    print("Compilation failed:\n" .. output)
    return
  end

  local status_ok, terminal_module = get_toggleterm()
  if not status_ok then
    return
  end

  local term_to_run = terminal_module.Terminal:new({
    name = "compilation term",
    cmd = run_cmd,
    close_on_exit = false,
    focus = true,

    dir = make_dir or vim.fn.fnamemodify(filename_full_path, ":h"),
    direction = "horizontal",
    on_open = function(t)
      vim.cmd("startinsert!")
      vim.keymap.set(
        "t",
        "<Esc>",
        "<Cmd>close<CR><Cmd>bdelete! " .. t.bufnr .. "<CR>",
        { buffer = t.bufnr, silent = true }
      )
    end,
  })
  term_to_run:toggle()
end

local function runRuby(filename_full_path)
  local make_dir, make_path = checkForRakefile()
  print("Compiling Ruby...")
  local comp_cmd = ""

  if make_path then
    comp_cmd = string.format("cd %s && rake", vim.fn.shellescape(make_dir))
  else
    comp_cmd = string.format("ruby %s", filename_full_path)
  end

  local status_ok, terminal_module = get_toggleterm()
  if not status_ok then
    return
  end

  local term_to_run = terminal_module.Terminal:new({
    cmd = comp_cmd,
    dir = make_dir or vim.fn.fnamemodify(filename_full_path, ":h"),
    direction = "horizontal",
    focus = true,
    close_on_exit = false,
    on_open = function(t)
      vim.keymap.set(
        "t",
        "<Esc>",
        "<Cmd>close<CR><Cmd>bdelete! " .. t.bufnr .. "<CR>",
        { buffer = t.bufnr, silent = true }
      )
    end,
  })
  term_to_run:toggle()
end

local function runGeneric(filename_full_path, run_cmd)
  local status_ok, terminal_module = get_toggleterm()
  if not status_ok then
    return
  end
  local comp_cmd = string.format("%s ", run_cmd)
  local term_to_run = terminal_module.Terminal:new({
    cmd = comp_cmd,
    dir = vim.fn.fnamemodify(filename_full_path, ":h"),
    direction = "horizontal",
    focus = true,
    close_on_exit = false,
    on_open = function(t)
      vim.keymap.set(
        "t",
        "<Esc>",
        "<Cmd>close<CR><Cmd>bdelete! " .. t.bufnr .. "<CR>",
        { buffer = t.bufnr, silent = true }
      )
    end,
  })
  term_to_run:toggle()
end

local function runGo(filename_full_path) end

keymap("n", "<leader>r", function()
  local filename_full_path = vim.fn.expand("%:p")
  local output_name = "./" .. vim.fn.expand("%:t:r") .. ".exe"
  local filetype = vim.bo.filetype

  vim.cmd("write")

  if filetype == "python" then
    runPython(filename_full_path)
  elseif filetype == "c" or filetype == "cpp" then
    local CC = (filetype == "c") and "gcc" or "g++"
    runCCPP(filename_full_path, output_name, CC)
  elseif filetype == "ruby" then
    runRuby(filename_full_path)
  elseif filetype == "go" then
    runGo(filename_full_path)
  elseif filetype == "perl" then
    runGeneric(filename_full_path, "perl")
  else
    print("Unsupported filetype: " .. filetype)
  end
end, { desc = "Run File (ToggleTerm)" })
