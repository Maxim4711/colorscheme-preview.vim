# Colorscheme Preview

Interactive colorscheme preview and persistence for Vim/Neovim with advanced filtering capabilities.

## ✨ Features

- 🎨 **Interactive preview** with real-time colorscheme switching
- 💾 **Automatic persistence** - remembers your choice between sessions  
- 🔍 **Advanced filtering** - show/hide built-in colorschemes
- 📋 **Include/exclude lists** for fine-grained control
- 🖼️ **Smart interface** - popup (Vim 8.2+) with fallback window
- ⌨️ **Configurable** key mappings and behavior
- 🚀 **Zero dependencies** - pure Vimscript

## 📦 Installation

### Using [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'Maxim4711/colorscheme-preview.vim'
```

### Using [Vundle](https://github.com/VundleVim/Vundle.vim)
```vim
Plugin 'Maxim4711/colorscheme-preview.vim'
```

### Using [pathogen](https://github.com/tpope/vim-pathogen)
```bash
cd ~/.vim/bundle
git clone https://github.com/Maxim4711/colorscheme-preview.vim.git
```

### Manual Installation
```bash
cd ~/.vim
git clone https://github.com/Maxim4711/colorscheme-preview.vim.git
cp -r colorscheme-preview.vim/* .
```

## 🚀 Quick Start

1. **Install the plugin** using your preferred method
2. **Press `<F9>`** (default key) or run `:ColorschemePreview`
3. **Navigate** with `j`/`k` or arrow keys
4. **Press `Enter`** to select and save your colorscheme
5. **Your choice persists** across Vim sessions!

## ⚙️ Configuration

Add these to your `.vimrc` to customize behavior:

```vim
" Show only user-installed colorschemes (hide built-ins)
let g:colorscheme_preview_show_builtin = 0

" Exclude specific colorschemes you don't like
let g:colorscheme_preview_exclude = ['default', 'blue', 'desert']

" Include only your favorites (overrides exclude if set)
let g:colorscheme_preview_include = ['gruvbox', 'onedark', 'nord']

" Change the key mapping (default: <F9>)
let g:colorscheme_preview_key = '<leader>cs'

" Custom state directory (default: auto-detected)
let g:colorscheme_preview_state_dir = '~/.vim/colorscheme-state'
```

## 📚 Usage

### Commands
| Command | Description |
|---------|-------------|
| `:ColorschemePreview` | Open interactive colorscheme preview |
| `:ColorschemePreviewSaveCurrent` | Save current colorscheme as default |
| `:ColorschemePreviewClearSaved` | Clear saved colorscheme state |
| `:ColorschemePreviewConfig` | Show current configuration |

### Navigation Keys
| Key | Action |
|-----|--------|
| `j`, `↓` | Move to next colorscheme |
| `k`, `↑` | Move to previous colorscheme |
| `Enter` | Select and save colorscheme |
| `q`, `Esc` | Cancel and restore original |
| `r` | Restore original (temporary) |

## 🎯 Examples

### Hide built-in colorschemes
```vim
let g:colorscheme_preview_show_builtin = 0
```

### Create a curated list
```vim
let g:colorscheme_preview_include = [
    \ 'gruvbox', 'nord', 'onedark', 'dracula',
    \ 'solarized', 'monokai', 'atom-dark'
\ ]
```

### Exclude problematic themes
```vim
let g:colorscheme_preview_exclude = [
    \ 'desert', 'evening', 'morning', 'shine'
\ ]
```

### Custom key mapping
```vim
let g:colorscheme_preview_key = '<leader>c'
```

## 🔧 Requirements

- **Vim 7.0+** (basic functionality)
- **Vim 8.2+** (for popup interface)
- **Neovim** (fully supported)

## 📁 How it Works

The plugin automatically saves your colorscheme choice to a state file:
- **Vim**: `~/.vim/colorscheme_state`
- **Neovim**: `{config}/colorscheme_state`
- **Custom**: `g:colorscheme_preview_state_dir/colorscheme_state`

On startup, it automatically restores your saved colorscheme. No need to set `colorscheme` in your `.vimrc`!

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 📖 Help

For detailed documentation, see `:help colorscheme-preview` after installation.

---

**Made with ❤️ for the Vim community**
