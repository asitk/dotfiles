-- Enable backup and writebackup
vim.opt.backup = true
vim.opt.writebackup = true

-- Specify backup directory (ensure this folder exists)
-- The // at the end builds a unique filename from the full path
vim.opt.backupdir = vim.fn.expand("~/.local/state/nvim/backup//")

-- Optional: Set a custom extension (default is "~")
vim.opt.backupext = ".bak"

