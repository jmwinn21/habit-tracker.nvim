local M = {}

function M.setup(opts)
	opts = opts or {}

	vim.keymap.set("n", "<leader>h", function()
		if opts.name then
			print("hello, " .. opts.name)
		else
			print("hello from habit-tracker")
		end
	end)
end

return M
