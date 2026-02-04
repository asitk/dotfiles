return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      -- Enables real-time updates from terminal actions
      use_libuv_file_watcher = true, 
      filtered_items = {
        visible = true,          -- Show hidden files but dimmed
        hide_dotfiles = false,    -- Don't hide files starting with '.'
        hide_gitignored = false,  -- Show files in .gitignore
      },
      follow_current_file = {
        enabled = true,          -- Auto-focus the file you're editing
      },
    },
  },
}
