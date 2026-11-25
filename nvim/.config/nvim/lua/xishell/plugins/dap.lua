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
