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

  local function clean_output(text)
    local clean = text:gsub("\27%[[0-9;]*[mK]", "")
    clean = clean:gsub("\r", "")
    return clean
  end

  local build_dir = vim.fn.fnamemodify(filename_full_path, ":h")

  local term_to_run = terminal_module.Terminal:new({
    cmd = run_cmd,
    dir = build_dir,
    direction = "horizontal",
    focus = true,
    close_on_exit = false,

    on_open = function(t)
      vim.cmd("startinsert!")

      -- Ensure 'q' works in both Terminal and Normal modes
      vim.keymap.set({ "n", "t" }, "q", function()
        vim.cmd("close")
        vim.api.nvim_buf_delete(t.bufnr, { force = true })
      end, { buffer = t.bufnr, desc = "Kill terminal buffer" })

      -- Standard Escape to just scroll
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = t.bufnr, silent = true })
    end,

    on_exit = function(t, job, exit_code, name)
      -- 1. IMMEDIATELY drop to Normal Mode regardless of success/fail.
      -- This stops the "press any key to close" behavior.
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, true, true), "n", false)

      if exit_code == 0 then
        vim.notify("success!", vim.log.levels.INFO)
        -- We stay in the terminal window, but now in Normal Mode.
        -- 'q' will now trigger your custom Lua function instead of closing the term.
      else
        -- Failure Logic
        t:close()
        vim.notify("failed (" .. exit_code .. ")", vim.log.levels.ERROR)

        local raw_lines = vim.api.nvim_buf_get_lines(t.bufnr, 0, -1, false)
        local clean_lines = {}
        for _, line in ipairs(raw_lines) do
          local cleaned = clean_output(line)
          if cleaned ~= "" then
            table.insert(clean_lines, cleaned)
          end
        end

        vim.fn.setqflist({}, "r", {
          title = "Compiler Errors",
          lines = clean_lines,
          efm = vim.api.nvim_get_option_value("errorformat", { scope = "global" }),
        })

        vim.cmd("lcd " .. build_dir)
        vim.cmd("botright copen")
      end
    end,
  })

  term_to_run:toggle()
end

-----WORKING
--local function runGeneric(filename_full_path, run_cmd)
--  local status_ok, terminal_module = get_toggleterm()
--  if not status_ok then
--    return
--  end
--
--  -- Robust ANSI & Carriage Return stripper
--  local function clean_output(text)
--    local clean = text:gsub("\27%[[0-9;]*[mK]", "") -- Strip ANSI colors
--    clean = clean:gsub("\r", "") -- Strip carriage returns
--    return clean
--  end
--
--  local build_dir = vim.fn.fnamemodify(filename_full_path, ":h")
--
--  local term_to_run = terminal_module.Terminal:new({
--    cmd = run_cmd,
--    dir = build_dir,
--    direction = "horizontal",
--    focus = true,
--    close_on_exit = false,
--
--    on_open = function(t)
--      vim.cmd("startinsert!")
--      -- q now handles window closing and buffer deletion
--      vim.keymap.set({ "n", "t" }, "q", function()
--        vim.cmd("close")
--        vim.api.nvim_buf_delete(t.bufnr, { force = true })
--      end, { buffer = t.bufnr })
--    end,
--
--    on_exit = function(t, job, exit_code, name)
--      if exit_code == 0 then
--        vim.notify("Build Success!", vim.log.levels.INFO)
--        -- Optional: close terminal on success after 2 seconds
--        -- vim.defer_fn(function() t:close() end, 2000)
--      else
--        -- 1. Close the terminal window immediately to fix the UI clutter
--        -- The buffer stays alive so we can still grab the text
--        t:close()
--
--        vim.notify("Build Failed - Opening Quickfix", vim.log.levels.ERROR)
--
--        -- 2. Grab and clean the lines
--        local raw_lines = vim.api.nvim_buf_get_lines(t.bufnr, 0, -1, false)
--        local clean_lines = {}
--        for _, line in ipairs(raw_lines) do
--          local cleaned = clean_output(line)
--          if cleaned ~= "" then
--            table.insert(clean_lines, cleaned)
--          end
--        end
--
--        -- 3. Populate Quickfix
--        -- We use 'efm' as a string, not a table, to ensure setqflist parses it
--        vim.fn.setqflist({}, "r", {
--          title = "Compiler Errors",
--          lines = clean_lines,
--          efm = vim.api.nvim_get_option_value("errorformat", { scope = "global" }),
--        })
--
--        -- 4. Change directory context so Neovim finds the files
--        vim.cmd("lcd " .. build_dir)
--
--        -- 5. Open Quickfix at the very bottom
--        vim.cmd("botright copen")
--      end
--    end,
--  })
--
--  term_to_run:toggle()
--end
--
---

--local function runGeneric(filename_full_path, run_cmd)
--  local status_ok, terminal_module = get_toggleterm()
--  if not status_ok then
--    return
--  end
--
--  local comp_cmd = string.format("%s", run_cmd)
--
--  local term_to_run = terminal_module.Terminal:new({
--    cmd = comp_cmd,
--    dir = vim.fn.fnamemodify(filename_full_path, ":h"),
--    direction = "horizontal",
--    focus = true,
--    close_on_exit = false,
--
--    on_open = function(t)
--      -- switch to start-insert so you can see it run
--      vim.cmd("startinsert!")
--
--      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = t.bufnr, silent = true })
--
--      -- Add a separate keybind if you REALLY want to kill the buffer
--      --      vim.keymap.set("t", "<C-c>", "<Cmd>close<CR><Cmd>bdelete! " .. t.bufnr .. "<CR>", { buffer = t.bufnr })
--      vim.keymap.set({ "n", "t" }, "q", function()
--        vim.cmd("close")
--        vim.api.nvim_buf_delete(t.bufnr, { force = true })
--      end, { buffer = t.bufnr, desc = "Kill terminal buffer" })
--    end,
--
--    -- This is the "magic" that lets you scroll immediately after it finishes
--    on_exit = function(t, job, exit_code, name)
--      if exit_code == 0 then
--        vim.notify("success!", vim.log.levels.INFO)
--      else
--        vim.notify("failed with code " .. exit_code, vim.log.levels.ERROR)
--      end
--      -- Force the terminal into Normal Mode so you can use 'G', 'gg', and scroll
--      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, true, true), "n", false)
--    end,
--  })
--
--  term_to_run:toggle()
--end

local function runGo(filename_full_path) end

-- Global or local table to hold your command history
_G.compile_stack = _G.compile_stack or {}

local function run_new_compile()
  -- Default prompt value - adjust this to your typical g++ or make command
  local default_cmd = ""
  local last_cmd = _G.compile_stack[#_G.compile_stack]
  if last_cmd then
    default_cmd = last_cmd
  else
    default_cmd = "make -j"
  end
  local filename_full_path = vim.fn.expand("%:p")

  local output_name = "./" .. vim.fn.expand("%:t:r") .. ".exe"
  local filetype = vim.bo.filetype

  vim.cmd("write")

  vim.ui.input({
    prompt = "Compile Command: ",
    default = default_cmd,
  }, function(input)
    if input and input ~= "" then
      table.insert(_G.compile_stack, input)
      runGeneric(filename_full_path, input)
      --      if type(_G.runGeneric) == "function" then
      --       _G.runGeneric(input)
      --    else
      --      end
      --     vim.notify("runGeneric logic not found", vim.log.levels.ERROR)
    end
  end)
end

local function run_last_compile()
  local last_cmd = _G.compile_stack[#_G.compile_stack]
  local filename_full_path = vim.fn.expand("%:p")
  if last_cmd then
    vim.notify("Re-running: " .. last_cmd, vim.log.levels.INFO)
    runGeneric(filename_full_path, last_cmd)
  else
    vim.notify("Compile stack is empty!", vim.log.levels.WARN)
  end
end

vim.keymap.set("n", "<leader>cc", run_new_compile, { desc = "e-compile" })
vim.keymap.set("n", "<leader>cC", run_last_compile, { desc = "run last e-compile" })
local wk = require("which-key")
wk.add({
  { "<leader>c", group = "Compiler/Stack" },
})

--keymap("n", "<leader>r", function()
--  local filename_full_path = vim.fn.expand("%:p")
--  local output_name = "./" .. vim.fn.expand("%:t:r") .. ".exe"
--  local filetype = vim.bo.filetype
--
--  vim.cmd("write")
--
--  if filetype == "python" then
--    runPython(filename_full_path)
--  elseif filetype == "c" or filetype == "cpp" then
--    local CC = (filetype == "c") and "gcc" or "g++"
--    runCCPP(filename_full_path, output_name, CC)
--  elseif filetype == "ruby" then
--    runRuby(filename_full_path)
--  elseif filetype == "go" then
--    runGeneric(filename_full_path, "go")
--  elseif filetype == "perl" then
--    runGeneric(filename_full_path, "perl")
--  else
--    print("Unsupported filetype: " .. filetype)
--  end
--end, { desc = "Run File (ToggleTerm)" })
