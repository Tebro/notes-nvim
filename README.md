# notes-nvim

A simple note-taking and journaling plugin for Neovim with Telescope integration. 

## Features

- **Note Management**: Create and organize markdown notes
- **Daily Journal**: Maintain a journal with one file per date
- **Quick Notes**: Create timestamped quick notes
- **Telescope Integration**: Search and find notes with Telescope
- **Template Support**: Customizable templates for different note types

## Installation

### Lazy.nvim

```lua
{
  "Tebro/notes-nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("notes-nvim").setup({
      notes_dir = vim.fn.expand("~/notes"),
      journal_dir = vim.fn.expand("~/notes/journal"),
      quick_notes_dir = vim.fn.expand("~/notes/quick"),
      default_extension = ".md",
      auto_save = true,
      templates = {
        journal = "# {date}\n\n## Today's Notes\n\n",
        quick_note = "# {title}\n\nCreated: {timestamp}\n\n",
      },
    })
  end,
}
```

## Configuration

Default configuration:

```lua
{
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
```

## Commands

### Basic Notes
- `:NotesNew [name]` - Create a new note
- `:NotesFind` - Find and open existing notes (uses Telescope if available)
- `:NotesSearch` - Search notes content (requires Telescope)

### Journal
- `:NotesJournal` - Open today's journal entry
- `:NotesJournalDate [YYYY-MM-DD]` - Open journal entry for specific date

### Quick Notes
- `:NotesQuick [title]` - Create a quick note with timestamp

### Setup
- `:NotesSetup` - Initialize plugin setup

## Usage

```vim
" Create a new note
:NotesNew project-ideas

" Open today's journal
:NotesJournal

" Open journal for specific date
:NotesJournalDate 2024-01-15

" Create a quick note
:NotesQuick meeting-notes

" Find notes with Telescope
:NotesFind

" Search note contents
:NotesSearch
```

## Dependencies

- **Optional**: [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for enhanced search functionality

## Features in Detail

### Directory Organization
- Automatic subdirectory creation: `:NotesNew work/project-ideas` creates `~/notes/work/project-ideas.md`
- Separate directories for journals and quick notes
- File name sanitization for cross-platform compatibility

### Templates
- Journal entries include date headers and structure
- Quick notes include timestamps and titles
- Fully customizable templates via configuration

### Error Handling
- Graceful fallbacks when Telescope is unavailable
- Input validation for dates and file names
- Informative error messages and notifications
