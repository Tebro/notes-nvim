local M = {}

function M.ensure_dir(path)
  if not path or path == "" then
    return false
  end
  
  if vim.fn.isdirectory(path) == 0 then
    local success = vim.fn.mkdir(path, "p")
    if success == 0 then
      M.notify("Failed to create directory: " .. path, vim.log.levels.ERROR)
      return false
    end
  end
  return true
end

function M.file_exists(path)
  return vim.fn.filereadable(path) == 1
end

function M.get_file_extension(filename)
  return filename:match("^.+(%..+)$") or ""
end

function M.remove_extension(filename)
  return filename:match("(.+)%..+$") or filename
end

function M.sanitize_filename(name)
  if not name or name == "" then
    return "untitled"
  end
  
  -- Remove invalid characters and replace spaces with hyphens
  local sanitized = name:gsub("[^%w%s%-_.]", "")
                       :gsub("%s+", "-")
                       :gsub("%-+", "-")
                       :gsub("^%-+", "")
                       :gsub("%-+$", "")
                       :lower()
  
  return sanitized ~= "" and sanitized or "untitled"
end

function M.get_timestamp()
  return os.date("%Y-%m-%d-%H-%M-%S")
end

function M.get_date()
  return os.date("%Y-%m-%d")
end

function M.scan_directory(dir, pattern)
  local files = {}
  
  if not dir or not M.ensure_dir(dir) then
    return files
  end
  
  local handle = vim.loop.fs_scandir(dir)
  if not handle then
    return files
  end
  
  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then break end
    
    if type == "file" and (not pattern or name:match(pattern)) then
      table.insert(files, name)
    end
  end
  
  return files
end

function M.notify(message, level)
  if not message or message == "" then
    return
  end
  
  level = level or vim.log.levels.INFO
  vim.notify(message, level, { title = "notes-nvim" })
end

return M