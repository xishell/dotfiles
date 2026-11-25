---@module "lazy"
---@type LazySpec
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional Breakpoint" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      -- thread list stays empty until the first stop, so fetch it before pausing
      { "<leader>dp", function()
        local s = require("dap").session()
        if not s then return end
        s:update_threads(function(err)
          if err then return vim.notify("threads: " .. tostring(err), vim.log.levels.ERROR) end
          require("dap").pause()
        end)
      end, desc = "Pause" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Eval Expression", mode = { "n", "v" } },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- UI setup
      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      -- Auto open/close UI on debug sessions
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Breakpoint signs
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "DapStoppedLine" })

      -- C/C++ via codelldb
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.c = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.cpp = dap.configurations.c

      -- stm32 via probe-rs, which speaks dap natively
      dap.adapters["probe-rs-debug"] = {
        type = "server",
        port = "${port}",
        executable = { command = "probe-rs", args = { "dap-server", "--port", "${port}" } },
      }

      -- project root is the nearest dir with a cubemx .ioc above the buffer
      local function stm32_root()
        local ioc = vim.fs.find(function(name) return name:match("%.ioc$") end,
          { path = vim.fn.expand("%:p:h"), upward = true, type = "file" })[1]
        return ioc and vim.fs.dirname(ioc) or vim.fn.getcwd()
      end

      table.insert(dap.configurations.c, {
        name = "STM32 (probe-rs)",
        type = "probe-rs-debug",
        request = "launch",
        cwd = stm32_root,
        chip = "STM32L476RGTx",
        flashingConfig = { flashingEnabled = true, haltAfterReset = false },
        -- top level so ABORT is honoured, build first so the flashed elf matches the buffer
        coreConfigs = function()
          local root = stm32_root()
          local out = vim.fn.system({ "make", "-C", root, "build" })
          local elf = vim.fn.glob(root .. "/build/Debug/*.elf", false, true)[1]
          if vim.v.shell_error ~= 0 or not elf then
            vim.notify(out, vim.log.levels.ERROR)
            return dap.ABORT
          end
          return { { coreIndex = 0, rttEnabled = true, programBinary = elf } }
        end,
      })

      -- rtt stays silent until the client acks each channel
      dap.listeners.before["event_probe-rs-rtt-channel-config"]["probe-rs"] = function(session, body)
        session:request("rttWindowOpened", { body.channelNumber, true })
      end
      dap.listeners.before["event_probe-rs-rtt-data"]["probe-rs"] = function(_, body)
        require("dap.repl").append(body.data)
      end
      dap.listeners.before["event_probe-rs-show-message"]["probe-rs"] = function(_, body)
        vim.notify("probe-rs: " .. body.message)
      end

      -- Python via debugpy
      dap.adapters.python = function(cb, config)
        if config.request == "attach" then
          local port = (config.connect or config).port
          local host = (config.connect or config).host or "127.0.0.1"
          cb({ type = "server", port = port, host = host })
        else
          cb({
            type = "executable",
            command = vim.fn.stdpath("data") .. "/mason/bin/debugpy-adapter",
          })
        end
      end

      dap.configurations.python = {
        {
          name = "Launch file",
          type = "python",
          request = "launch",
          program = "${file}",
          pythonPath = function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then return venv .. "/bin/python" end
            return "python3"
          end,
        },
      }

      -- Go is handled by go.nvim (dap_debug = true)
    end,
  },
}
