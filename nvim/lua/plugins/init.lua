-- lua/plugins/init.lua
return {
	-- Theme: One Dark
	{
		"navarasu/onedark.nvim",
		priority = 1000,
		config = function()
			require("onedark").setup({
				style = "dark", -- "dark", "darker", "cool", "deep", "warm", "warmer"
				transparent = false,
				term_colors = true,
				code_style = { comments = "italic" },
				diagnostics = { darker = true, undercurl = true, background = false },
			})
			require("onedark").load()
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"bash",
					"json",
					"yaml",
					"toml",
					"markdown",
					"markdown_inline",
					"typescript",
					"tsx",
					"javascript",
					"python",
					"go",
					"rust",
					"html",
					"css",
				},
				highlight = { enable = true },
				indent = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "v",
						node_incremental = "v",
						node_decremental = "V",
						scope_incremental = "gV",
					},
				},
			})
		end,
	},

	-- LSP management
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"ts_ls", -- formerly tsserver via typescript-language-server
					"pyright",
					"gopls",
					"rust_analyzer",
					"bashls",
					"jsonls",
					"yamlls",
					"html",
					"cssls",
					"marksman",
				},
				automatic_installation = true,
			})

			local lsp = require("lspconfig")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			local on_attach = function(_, bufnr)
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end
				-- Helix-like LSP keys
				map("n", "gd", vim.lsp.buf.definition, "Go to definition")
				map("n", "gr", vim.lsp.buf.references, "References")
				map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
				map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
				map("n", "K", vim.lsp.buf.hover, "Hover")
				map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
				map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
				map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
				map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
				map("n", "gl", vim.diagnostic.open_float, "Line diagnostics")
				map("n", "<leader>f", function()
					vim.lsp.buf.format({ async = true })
				end, "Format")
			end

			local servers = require("mason-lspconfig").get_installed_servers()
			for _, server in ipairs(servers) do
				local opts = { capabilities = capabilities, on_attach = on_attach }
				if server == "lua_ls" then
					opts.settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							workspace = { checkThirdParty = false },
							telemetry = { enable = false },
						},
					}
				end
				require("lspconfig")[server].setup(opts)
			end
		end,
	},

	-- Autocomplete
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "buffer" },
					{ name = "luasnip" },
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
			})
		end,
	},

	-- Diagnostics UI and code actions preview
	{
		"folke/trouble.nvim",
		cmd = { "Trouble" },
		opts = {},
	},

	-- Fuzzy finding (Helix-like picker)
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", ":Telescope find_files<CR>",     desc = "Find files" },
			{ "<leader>fg", ":Telescope live_grep<CR>",      desc = "Live grep" },
			{ "<leader>fb", ":Telescope buffers<CR>",        desc = "Buffers" },
			{ "<leader>fh", ":Telescope help_tags<CR>",      desc = "Help" },
			{ "gr",         ":Telescope lsp_references<CR>", desc = "LSP references" },
		},
		opts = {
			defaults = {
				layout_strategy = "flex",
				layout_config = { prompt_position = "top" },
				sorting_strategy = "ascending",
			},
		},
	},

	-- File explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
		keys = {
			{ "<leader>e", ":Neotree toggle<CR>", desc = "Explorer" },
		},
		opts = {
			filesystem = { follow_current_file = { enabled = true } },
			window = { width = 32 },
		},
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "onedark",
					section_separators = "",
					component_separators = "",
				},
			})
		end,
	},

	-- Commenting, surround, git signs
	{ "numToStr/Comment.nvim",  opts = {} },
	{ "kylechui/nvim-surround", opts = {} },
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "契" },
				topdelete = { text = "契" },
				changedelete = { text = "▎" },
			},
		},
	},

	-- Multi-cursor-like functionality
	{ "mg979/vim-visual-multi",  branch = "master" },

	-- Inline rename in buffer (nice UX)
	{ "smjonas/inc-rename.nvim", opts = {} },
}
