local M = {}

M.help = [[
Rem allows you to setup reminders, from right inside the neovim. 

To setup a reminder, type 
:Rem <your-reminder-message> <time-in-minues>

Example
:Rem This is a reminder message 5

The above command will open up a reminder after 5 minutes. 
The reminder will be shown in a floating window. 
In case, neovim is closed before reaching the reminder time, 
the reminders will persist on disk, and will be shown the next time 
you open up neovim. Reminders are automatically deleted after they pop up on the screen. 
]]

M.show_help = function()
	print(M.help)
end

M.create_floating_window = function(message)
	local buf = vim.api.nvim_create_buf(false, true) -- Create a new empty buffer
	local width = 40
	local height = 3
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { message })
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "single",
	})
end

M.save_reminder = function(message, timer)
	local reminder_time = os.time() + (timer * 60)
	local reminder = {
		message = message,
		reminder_time = reminder_time,
	}
	-- Open the reminders file in append mode
	local file = io.open(vim.fn.stdpath("data") .. "/reminders.txt", "a")
	if file then
		file:write(vim.fn.json_encode(reminder) .. "\n")
		file:close()
	else
		vim.api.nvim_err_writeln("Error saving reminder.")
	end
end

-- Load reminders from the file and check if any should be triggered
M.load_reminders = function()
	local file = io.open(vim.fn.stdpath("data") .. "/reminders.txt", "r")
	if file then
		local reminders = {}
		local lines = {}
		for line in file:lines() do
			local reminder = vim.fn.json_decode(line)
			table.insert(reminders, reminder)
			table.insert(lines, line) -- Keep a copy of the lines for later
		end
		file:close()
		-- Create a list of reminders that need to be removed (those that have already triggered)
		local remaining_reminders = {}
		for _, reminder in ipairs(reminders) do
			if reminder.reminder_time <= os.time() then
				M.create_floating_window(reminder.message)
			else
				-- If not triggered yet, keep it in the remaining reminders list
				table.insert(remaining_reminders, reminder)
			end
		end
		-- Re-write the file with only the remaining (untriggered) reminders
		file = io.open(vim.fn.stdpath("data") .. "/reminders.txt", "w")
		if file then
			for _, reminder in ipairs(remaining_reminders) do
				file:write(vim.fn.json_encode(reminder) .. "\n")
			end
			file:close()
		end
	end
end

M.set_reminder = function(opts)
	local i, n = 1, #opts.fargs
	local text = ""
	while i < n do
		text = text .. " " .. opts.fargs[i]
		i = i + 1
	end
	-- The last argument should be the timer (in minutes)
	local timer = tonumber(opts.fargs[n])
	if timer == nil then
		vim.api.nvim_err_writeln("Please provide a valid time value at the end.")
		return
	end
	print("Reminder set for: " .. timer .. " minute(s)")
	M.save_reminder(text, timer)
	local delay_time = timer * 60 * 1000 -- Convert timer to minutes
	vim.defer_fn(function()
		M.create_floating_window(text)
	end, delay_time)
end

-- Command to set a reminder
vim.api.nvim_create_user_command("Rem", function(opts)
	M.set_reminder(opts)
end, { nargs = "*" })

-- help command
vim.api.nvim_create_user_command("Rem help", M.show_help, {})

-- Load reminders on startup
M.load_reminders()

return M
