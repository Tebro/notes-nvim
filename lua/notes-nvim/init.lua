local M = {}
local utils = require('notes-nvim.utils')

M.config = {
  notes_dir = vim.fn.expand("~/notes"),
  journal_dir = vim.fn.expand("~/notes/journal"),
  quick_notes_dir = vim.fn.expand("~/notes/quick"),
  default_extension = ".md",
  auto_save = true,
  templates = {
    journal = "# {date}\n\n## Today's Notes\n\n",
    quick_note = "# {title}\n\nCreated: {timestamp}\n\n",
  },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  -- Ensure directories exist
  utils.ensure_dir(M.config.notes_dir)
  utils.ensure_dir(M.config.journal_dir)
  utils.ensure_dir(M.config.quick_notes_dir)
end

local function create_note_file(full_path)
  vim.cmd("edit " .. vim.fn.fnameescape(full_path))
end

local function apply_template(template_content)
  if vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
    local lines = vim.split(template_content, '\n')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    if M.config.auto_save then
      vim.cmd('write')
    end
  end
end

function M.new_note(name)
  local filename = name or vim.fn.input("Note name: ")
  if filename == "" then
    return
  end
  
  local full_path
  local dir_part, file_part = filename:match("^(.+)/([^/]+)$")
  
  if dir_part then
    local subdir_path = M.config.notes_dir .. "/" .. dir_part
    utils.ensure_dir(subdir_path)
    local sanitized_name = utils.sanitize_filename(file_part)
    full_path = subdir_path .. "/" .. sanitized_name .. M.config.default_extension
  else
    local sanitized_name = utils.sanitize_filename(filename)
    full_path = M.config.notes_dir .. "/" .. sanitized_name .. M.config.default_extension
  end
  
  create_note_file(full_path)
end

function M.journal_today()
  local date = utils.get_date()
  local filename = date .. M.config.default_extension
  local full_path = M.config.journal_dir .. "/" .. filename
  
  create_note_file(full_path)
  
  local template = M.config.templates.journal:gsub("{date}", date)
  apply_template(template)
end

function M.journal_date(date_input)
  local date = date_input or vim.fn.input("Date (YYYY-MM-DD): ")
  if date == "" then
    return
  end
  
  -- Validate date format
  if not date:match("^%d%d%d%d%-%d%d%-%d%d$") then
    utils.notify("Invalid date format. Use YYYY-MM-DD", vim.log.levels.ERROR)
    return
  end
  
  local filename = date .. M.config.default_extension
  local full_path = M.config.journal_dir .. "/" .. filename
  
  create_note_file(full_path)
  
  local template = M.config.templates.journal:gsub("{date}", date)
  apply_template(template)
end

function M.quick_note(title)
  local note_title = title or vim.fn.input("Quick note title: ")
  if note_title == "" then
    note_title = "note-" .. utils.get_timestamp()
  end
  
  local sanitized_title = utils.sanitize_filename(note_title)
  local filename = sanitized_title .. M.config.default_extension
  local full_path = M.config.quick_notes_dir .. "/" .. filename
  
  create_note_file(full_path)
  
  local template = M.config.templates.quick_note
    :gsub("{title}", note_title)
    :gsub("{timestamp}", os.date("%Y-%m-%d %H:%M:%S"))
  apply_template(template)
end

function M.find_notes()
  local has_telescope = pcall(require, 'telescope')
  if has_telescope then
    require('notes-nvim.telescope').find_notes()
  else
    local notes_pattern = M.config.notes_dir .. "/**/*" .. M.config.default_extension
    vim.cmd("find " .. vim.fn.fnameescape(notes_pattern))
  end
end

function M.search_notes()
  local has_telescope = pcall(require, 'telescope')
  if has_telescope then
    require('notes-nvim.telescope').search_notes()
  else
    utils.notify("Telescope not available. Install telescope.nvim for search functionality.", vim.log.levels.WARN)
  end
end

return M