

-- keymaps to open a terminal instance
vim.keymap.set("n", "<leader>th", function()

    vim.cmd("rightbelow vsplit | terminal")

end)

vim.keymap.set("n", "<leader>tv", function()

    vim.cmd("belowright split | terminal")

end)

-- disable line numbers in terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function()
        vim.wo.number = false
        vim.wo.relativenumber = false
    end
})

-- send selected text to terminal
vim.api.nvim_create_user_command("SendToTerminal", function()
    -- Find active terminal buffers
    local active_terms = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local success, job_id = pcall(function() 
            return vim.api.nvim_buf_get_var(buf, 'terminal_job_id') 
        end)
        
        if success and job_id then
            table.insert(active_terms, {buf = buf, job_id = job_id})
        end
    end
    
    if #active_terms == 0 then
        print("No active terminals found")
        return
    end
    
    -- Use the last terminal
    local term = active_terms[#active_terms]
    local job_id = term.job_id
    
    -- Get visual selection
    local text = vim.fn.getreg('"')
    
    -- Send text to terminal
    vim.fn.chansend(job_id, text .. "\n")
end, {})

vim.keymap.set('v', '<Leader>ts', 'y:SendToTerminal<CR>', { silent = true })
vim.keymap.set('n', '<Leader>tl', 'Vy:SendToTerminal<CR>', { silent = true })

-- send selected text to system clipboard and run %paste in terminal
vim.api.nvim_create_user_command("SendToIPython", function()
    -- Find active terminal buffers
    local active_terms = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local success, job_id = pcall(function() 
            return vim.api.nvim_buf_get_var(buf, 'terminal_job_id') 
        end)
        
        if success and job_id then
            table.insert(active_terms, {buf = buf, job_id = job_id})
        end
    end
    
    if #active_terms == 0 then
        print("No active terminals found")
        return
    end
    
    -- Use the last terminal
    local term = active_terms[#active_terms]
    local job_id = term.job_id
    
    -- Get visual selection (already yanked via the mapping)
    local text = vim.fn.getreg('"')
    
    -- Copy to system clipboard
    vim.fn.setreg('+', text)
    
    -- Send %paste to terminal
    vim.fn.chansend(job_id, "%paste\n")
end, {})

-- Map the command to visual mode with leader key
vim.keymap.set('v', '<Leader>tp', 'y:SendToIPython<CR>', { silent = true })



-- Terminal mode navigation mappings
-- Exit terminal mode and move in all four directions
vim.keymap.set('t', '<S-h>', '<C-\\><C-n><C-w>h', { noremap = true, silent = true }) -- left
vim.keymap.set('t', '<S-j>', '<C-\\><C-n><C-w>j', { noremap = true, silent = true }) -- down
vim.keymap.set('t', '<S-k>', '<C-\\><C-n><C-w>k', { noremap = true, silent = true }) -- up
vim.keymap.set('t', '<S-l>', '<C-\\><C-n><C-w>l', { noremap = true, silent = true }) -- right


