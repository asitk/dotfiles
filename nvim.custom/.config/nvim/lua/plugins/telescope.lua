return {
        'nvim-telescope/telescope.nvim', tag = '*',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- optional but recommended
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },

        opts = {
                extensions = {
                    fzf = {
                        fuzzy = true,                       -- false will only do exact matching
                        override_generic_sorter = true,     -- override the generic sorter
                        override_file_sorter = true,        -- override the file sorter
                        case_mode = "smart_case",           -- or "ignore_case" or "respect_case"
                                                            -- the default case_mode is "smart_case"
                    }
                }
            }
}
