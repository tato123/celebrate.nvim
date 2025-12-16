# celebrate.nvim

Show random celebration GIFs/videos when you finish work!

## Requirements

- Neovim 0.9+
- [chafa](https://hpjansson.org/chafa/) (`brew install chafa`)

## Installation

Using lazy.nvim:

```lua
{
  "tato123/celebrate.nvim",
  opts = {},  -- defaults work out of the box
}
```

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `global_media_dir` | `$XDG_CONFIG_HOME/celebrate.nvim` or `~/.config/celebrate.nvim` | Global celebration media directory |
| `local_media_dir` | `celebrate` | Local directory name (relative to cwd) |
| `use_local` | `true` | Check local directory in addition to global |
| `duration_ms` | `4000` | How long to show the celebration (ms) |
| `width_ratio` | `0.5` | Popup width as ratio of screen |
| `height_ratio` | `0.5` | Popup height as ratio of screen |
| `audio` | `true` | Play audio (macOS only via afplay) |
| `keymap` | `<leader>yay` | Keymap to trigger celebration |
| `extensions` | `{"gif", "mp4", "webm", "png", "jpg"}` | Supported file types |

## Usage

- `:Celebrate` - Show random celebration
- `<Space>yay` - Default keymap (if leader is space)
- Press `<Esc>` or `q` to close early

## Adding Celebrations

The plugin checks two locations for media files:

1. **Local** (project-specific): `./celebrate/` in your current directory
2. **Global**: `${XDG_CONFIG_HOME:-$HOME/.config}/celebrate.nvim`

```bash
# Global celebrations (available everywhere)
mkdir -p ~/.config/celebrate.nvim
curl -o ~/.config/celebrate.nvim/party.gif "YOUR_GIF_URL"

# Project-specific celebrations
mkdir -p ./celebrate
curl -o ./celebrate/ship-it.gif "YOUR_GIF_URL"
```

Files from both directories are combined, so you can have global defaults plus project-specific celebrations.

## License

MIT
