return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',

    opts = {
        ensure_installed = {
        "c", "go", "query", "elixir", "heex", "html", "lua", "vim", "javascript", 
        "typescript", "vimdoc",
        },
        auto_install = true, -- Automatically installs missing parsers
        highlight = {
        enable = true, -- Enable syntax highlighting
        },
        indent = {
            enable = true, -- Enable indentation
        },
    },
    config = function(_, opts)
        -- This function runs the final setup
        require("nvim-treesitter.config").setup(opts)
    end,
}
