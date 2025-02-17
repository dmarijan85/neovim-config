-- VIM OPTIONS
-- Line numbers and mouse support
vim.opt.number = true
vim.opt.mouse = "a"

-- Indentation
vim.opt.autoindent = true
vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.smartindent = true

-- UI
--vim.opt.colorcolumn = "80"
--vim.opt.list = true

-- History
vim.opt.history = 1000

-- VIM OPTIONS

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- MY PLUGINS

		{ -- TRANSPARENCY
			"xiyaowong/transparent.nvim",
		},
		{ -- COLORSCHEME
			"iagorrr/noctis-high-contrast.nvim",
			lazy = false,
			priority=1000
		},
		{ -- TELESCOPE
			'nvim-telescope/telescope.nvim', tag = '0.1.8',
			dependencies = { 'nvim-lua/plenary.nvim' }
		},
		{ -- TREESITTER
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate"
		},
		{ -- NEO TREE
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
				"MunifTanjim/nui.nvim",
				-- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
			}
		},
		{ -- BARBAR (for tabs / buffers)
			'romgrk/barbar.nvim',
			dependencies = {
				'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
				'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
			},
			init = function() vim.g.barbar_auto_setup = false end,
			opts = {
				-- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
				-- animation = true,
				-- insert_at_start = true,
				-- …etc.
			},
			version = '^1.0.0', -- optional: only update when a new 1.x version is released
		},
		{ -- WHICH-KEY
			"folke/which-key.nvim",
			opts = {} 
		},
		{
			"fraso-dev/nvim-listchars",
			event = "BufEnter",
			config = function()
				require("nvim-listchars").setup({
					save_state = false,
					listchars = {
						trail = "-",
						eol = "↲",
						tab = "» ",
						space = "·",
					},
					notifications = true,
					exclude_filetypes = {
						"markdown"
					},
					lighten_step = 10,
				})
			end,
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- COLORSCHEME CONFIG
vim.cmd.colorscheme("noctishc")

-- TELESCOPE CONFIG (simplified)
local builtin = require('telescope.builtin')
require('telescope').setup({
	defaults = {
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--hidden",       -- Include hidden files
			"--glob=!**/.git/*"  -- Exclude .git directory
		}
	},
	pickers = {
		find_files = {
			find_command = {
				"rg", "--files", "--hidden", "--glob", "!**/.git/*"
			}
		},
		live_grep = {
			additional_args = { "--hidden" }  -- Include hidden files in live_grep
		}
	}
})
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope: Find Files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope: Live Grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope: Buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope: Help Tags' })

-- TREESITTER CONFIG
local configs = require("nvim-treesitter.configs")
configs.setup(
	{
		ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
		sync_install = false,
		highlight = { enable = true },
		indent = { enable = true },  
	})

-- NEOTREE CONFIG
require("neo-tree").setup({
	window = {
		width = 25,  -- This is the correct location for width
		auto_expand_width = false,
	},
})

vim.keymap.set('n', '<leader>T', '<cmd>Neotree toggle<CR>', { desc = 'Neotree: Toggle' })

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- Open NeoTree only if no file is specified when launching NeoVim
		if vim.fn.argc() == 0 then
			vim.cmd("Neotree action=show")
		end
	end,
})

vim.api.nvim_create_autocmd("QuitPre", {
	callback = function()
		local invalid_win = {}
		local wins = vim.api.nvim_list_wins()
		for _, w in ipairs(wins) do
			local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
			if bufname:match("neo%-tree") then
				table.insert(invalid_win, w)
			end
		end
		if #invalid_win == #wins - 1 then
			-- Should quit, close all invalid windows
			for _, w in ipairs(invalid_win) do
				vim.api.nvim_win_close(w, true)
			end
		end
	end,
})

require("transparent").setup({
  -- table: default groups
  groups = {
    'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
    'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
    'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
    'SignColumn', 'CursorLine', 'CursorLineNr', 'StatusLine', 'StatusLineNC',
    'EndOfBuffer',
  },
  -- table: additional groups that should be cleared
  extra_groups = {},
  -- table: groups you don't want to clear
  exclude_groups = {},
  -- function: code to be executed after highlight groups are cleared
  -- Also the user event "TransparentClear" will be triggered
  on_clear = function() end,
})
-- BARBAR CONFIG
require('barbar').setup({
	clickable = false,
	auto_hide = true,  -- Auto-hide when only NeoTree remains
})

vim.keymap.set('n', '<C-Down>', function()
	if #vim.fn.getbufinfo({buflisted = 1}) > 1 then
		vim.cmd('BufferClose')
	else
		vim.cmd('q')
	end
end, { noremap = true, silent = true })
vim.keymap.set('n', '<C-Right>', '<cmd>BufferNext<CR>', { desc = 'Buffer: Next', noremap = true, silent = true })
vim.keymap.set('n', '<C-Left>', '<cmd>BufferPrevious<CR>', { desc = 'Buffer: Previous', noremap = true, silent = true })

-- WHICH-KEY CONFIG
local wk = require("which-key")
wk.setup({
	plugins = { spelling = { enabled = false } },
	disable = { filetypes = { "TelescopePrompt", "neo-tree" } }
})

-- ENABLE TRANSPARENCY
vim.g.transparent_enabled = true
--vim.opt.termguicolors = false
vim.cmd('set guicursor=n-v-c-sm:block,n:blinkon150')

-- TODO 
-- fix column width Neotree
-- keep watching vids ig too
-- git test
