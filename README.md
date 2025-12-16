# celebrate.nvim

Show random celebration GIFs and videos in Neovim when you finish work!

Comes with 100 pre-configured celebration URLs. Fork it to customize with your own favorites.

## Requirements

- Neovim 0.9+
- [chafa](https://hpjansson.org/chafa/) (`brew install chafa`)
- curl (for downloading media)

## Installation

**Fork this repo first!** Then install your fork:

Using lazy.nvim:

```lua
{
  "YOUR_USERNAME/celebrate.nvim",
  opts = {},
}
```

## Usage

- `:Celebrate` - Show a random celebration
- `:CelebratePrecache` - Pre-download all media (optional, faster first-time loads)
- `<Space>yay` - Default keymap (if leader is space)
- Press `<Esc>` or `q` to close early

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `duration_ms` | `4000` | How long to show the celebration (ms) |
| `width_ratio` | `0.5` | Popup width as ratio of screen |
| `height_ratio` | `0.5` | Popup height as ratio of screen |
| `audio` | `true` | Play audio (macOS only via afplay) |
| `keymap` | `<leader>yay` | Keymap to trigger celebration |

## How It Works

Celebrations are defined in `celebrations.lua` as a list of URLs. When you trigger a celebration:

1. A random URL is selected
2. If not cached, it downloads to `~/.cache/celebrate.nvim/`
3. The media plays in a floating terminal window using chafa

## Customizing Your Celebrations

Since you forked this repo, edit `celebrations.lua` to add your own:

```lua
return {
  -- Remote URLs (will be cached locally)
  "https://media.giphy.com/media/26tOZ42Mg6pbTUPHW/giphy.gif",
  "https://example.com/my-celebration.mp4",

  -- Local files (use file:// or absolute paths)
  "file:///Users/me/celebrations/custom.gif",
  "/absolute/path/to/video.mp4",
  "~/celebrations/another.gif",
}
```

Then commit and push to your fork:

```bash
git add celebrations.lua
git commit -m "Add my celebrations"
git push
```

## Why Fork?

- **Lightweight**: No media bundled in the plugin, just URLs
- **Personal**: Add your own GIFs, memes, team celebrations
- **Portable**: URLs travel with your dotfiles
- **Fast**: Media is cached locally after first use

## Audio

MP4 and video files with audio tracks will play sound on macOS (using `afplay`).
GIFs are silent.

## Cache

Media is cached in `~/.cache/celebrate.nvim/` (or `$XDG_CACHE_HOME/celebrate.nvim/`).

To clear the cache:
```bash
rm -rf ~/.cache/celebrate.nvim
```

## License

MIT
