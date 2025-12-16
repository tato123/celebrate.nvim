# celebrate.nvim

Show random celebration GIFs/videos when you finish work!

## Requirements

- Neovim 0.9+
- [chafa](https://hpjansson.org/chafa/) (`brew install chafa`)
- Terminal with Kitty graphics protocol (Ghostty, Kitty, WezTerm)

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
| `media_dir` | `~/.config/celebrate.nvim` | Directory containing your celebration media |
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

Add GIFs, MP4s, or images to your `media_dir` (default: `~/.config/celebrate.nvim`).

```bash
mkdir -p ~/.config/celebrate.nvim
# Add your favorite celebration GIFs!
```

## License

MIT
