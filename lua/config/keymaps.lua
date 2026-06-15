local map = vim.keymap.set

-- Window navigation
map("", "<C-h>", "<C-w>h")
map("", "<C-j>", "<C-w>j")
map("", "<C-k>", "<C-w>k")
map("", "<C-l>", "<C-w>l")

-- Buffer list + system-clipboard yank/paste
map("", "<leader>ls", "<cmd>ls<cr>")
map("", "<leader>y", '"+y')
map("", "<leader>p", '"+p')

-- Tab navigation
map("n", "H", "gT")
map("n", "L", "gt")

-- Insert-mode escape + arrows
map("i", "jj", "<Esc><Right>")
map("i", "<C-j>", "<Down>")
map("i", "<C-k>", "<Up>")
map("i", "<C-l>", "<Right>")

-- Leave terminal mode with <Esc>
map("t", "<Esc>", [[<C-\><C-n>]])
