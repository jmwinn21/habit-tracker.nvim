local M = {}
local config = nil
local db = nil

-- Default configuration
local default_config = {
	db_path = vim.fn.stdpath("data") .. "/habit-tracker.db",
}

-- Initialize the database & create tables
local function init_database()
	if not config or not config.db_path then
		vim.notify("invalid configuration", vim.log.levels.ERROR)
		return false
	end
end

return M
