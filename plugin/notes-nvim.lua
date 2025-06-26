if vim.g.loaded_notes_nvim then
  return
end
vim.g.loaded_notes_nvim = 1

local function safe_call(func, ...)
  local ok, err = pcall(func, ...)
  if not ok then
    vim.notify("notes-nvim error: " .. tostring(err), vim.log.levels.ERROR)
  end
end

local notes = require('notes-nvim')

local commands = {
  {
    name = 'NotesNew',
    func = function(opts) notes.new_note(opts.args) end,
    opts = { nargs = '?', desc = 'Create a new note' }
  },
  {
    name = 'NotesFind',
    func = function() notes.find_notes() end,
    opts = { desc = 'Find and open notes' }
  },
  {
    name = 'NotesSearch',
    func = function() notes.search_notes() end,
    opts = { desc = 'Search notes content' }
  },
  {
    name = 'NotesJournal',
    func = function() notes.journal_today() end,
    opts = { desc = 'Open today\'s journal entry' }
  },
  {
    name = 'NotesJournalDate',
    func = function(opts) notes.journal_date(opts.args) end,
    opts = { nargs = '?', desc = 'Open journal entry for specific date' }
  },
  {
    name = 'NotesQuick',
    func = function(opts) notes.quick_note(opts.args) end,
    opts = { nargs = '?', desc = 'Create a quick note' }
  },
  {
    name = 'NotesSetup',
    func = function() notes.setup() end,
    opts = { desc = 'Setup notes-nvim plugin' }
  }
}

for _, command in ipairs(commands) do
  vim.api.nvim_create_user_command(command.name, function(opts)
    safe_call(command.func, opts)
  end, command.opts)
end