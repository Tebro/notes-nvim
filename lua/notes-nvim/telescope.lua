local M = {}

local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    error("Missing dependency: " .. module .. ". Please install telescope.nvim")
  end
  return result
end

local telescope = safe_require('telescope')
local finders = safe_require('telescope.finders')
local pickers = safe_require('telescope.pickers')
local conf = safe_require('telescope.config').values
local actions = safe_require('telescope.actions')
local action_state = safe_require('telescope.actions.state')
local utils = require('notes-nvim.utils')

local function create_file_picker(directory, title)
  local notes_config = require('notes-nvim').config
  
  if not utils.ensure_dir(directory) then
    utils.notify("Directory not accessible: " .. directory, vim.log.levels.ERROR)
    return
  end
  
  local find_command = {
    'find',
    directory,
    '-type', 'f',
    '-name', '*' .. notes_config.default_extension,
    '-not', '-path', '*/.*'
  }
  
  pickers.new({}, {
    prompt_title = title,
    finder = finders.new_oneshot_job(find_command, {
      entry_maker = function(entry)
        local relative_path = entry:gsub(notes_config.notes_dir .. '/', '')
        local display_name = title == 'Find Notes' and relative_path or vim.fn.fnamemodify(entry, ':t:r')
        return {
          value = entry,
          display = display_name,
          ordinal = display_name,
          path = entry,
        }
      end,
    }),
    sorter = conf.file_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd('edit ' .. vim.fn.fnameescape(selection.path))
        end
      end)
      return true
    end,
  }):find()
end

function M.find_notes()
  local notes_config = require('notes-nvim').config
  create_file_picker(notes_config.notes_dir, 'Find Notes')
end

function M.search_notes()
  local notes_config = require('notes-nvim').config
  
  if not utils.ensure_dir(notes_config.notes_dir) then
    utils.notify("Notes directory not accessible: " .. notes_config.notes_dir, vim.log.levels.ERROR)
    return
  end
  
  local builtin = safe_require('telescope.builtin')
  
  builtin.live_grep({
    prompt_title = 'Search Notes',
    search_dirs = { notes_config.notes_dir },
    glob_pattern = '*' .. notes_config.default_extension,
    additional_args = function()
      return { '--hidden', '--no-ignore' }
    end,
  })
end

function M.find_journal_entries()
  local notes_config = require('notes-nvim').config
  create_file_picker(notes_config.journal_dir, 'Journal Entries')
end

function M.find_quick_notes()
  local notes_config = require('notes-nvim').config
  create_file_picker(notes_config.quick_notes_dir, 'Quick Notes')
end

return M