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

	-- debug prints
	-- print("Data directory: ", vim.fn.stdpath('data'))
	-- print("Target DB path: ", config.db_path)

	-- Ensure the directory exists
	local db_dir = vim.fn.fnamemodify(config.db_path, ":h")
	vim.fn.mk_dir(db_dir, "p")

	-- Try to load sqlite
	local has_sqlite, sqlite = pcall(require, "sqlite")
	if not has_sqlite then
		vim.notify("Failed to require sqlite: " .. tostring(sqlite), vim.log.levels.ERROR)
		return false
	end

	-- "super-lazy constructor"?
	local success, connection_or_error = pcall(function()
		return sqlite({
			uri = config.db_path,

			-- define the habits table
			habits = {
				-- id == true creates an integer primary key
				id = true,

				-- plugin schema
				title = "text", -- TEXT NOT NULL
				created_at = "text", -- TEXT NOT NULL
				interval = "text",
				active = "integer", -- INTEGER NOT NULL DEFAULT 1

				-- ensure=true => CREATE TABLE IF NOT EXISTS
				ensure = true,
			},

			-- define the habit instances table
			habit_instances = {
				id = true,
				habit_id = "integer", -- INTEGER NOT NULL
				instance_timestamp = "text", -- TEXT NOT NULL
			},
		}):open()
	end)

	if not success or not connection_or_error then
		vim.notify("Failed to create DB connection: " .. tostring(connection_or_error), vim.log.levels.ERROR)
		return false
	end

	db = connection_or_error

	-- create indices
	local success_idx, err_idx = pcall(function()
		db:eval([[
      CREATE INDEX IF NOT EXISTS idx_habit_title 
      ON habits(title)
      ]])
	end)

	-- TODO: create index for the instance_timstamp column
	-- TODO: create foreign key for habit_id => habit.id

	if not success_idx then
		vim.notify("Failed to create index: " .. tostring(err_idx), vim.log.leveles.ERROR)
		return false
	end

	-- create indices
	success_idx, err_idx = pcall(function()
		db:eval([[
      CREATE INDEX IF NOT EXISTS idx_habit_instance_timestamp
      ON habit_instances(instance_timestamp)
      ]])
	end)

	if not success_idx then
		vim.notify("Failed to create index: " .. tostring(err_idx), vim.log.leveles.ERROR)
		return false
	end

	return true
end

return M
