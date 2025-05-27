" ============================================================================
" File: plugin/colorscheme-preview.vim
" Description: Interactive colorscheme preview and persistence plugin loader
" Author: Maxim4711 <mdemenko@gmail.com>
" Version: 1.0
" License: MIT
" ============================================================================

" Prevent loading twice
if exists('g:loaded_colorscheme_preview') || v:version < 700
    finish
endif
let g:loaded_colorscheme_preview = 1

" Save cpoptions and set to vim defaults
let s:save_cpo = &cpoptions
set cpoptions&vim

" ============================================================================
" Configuration Variables
" ============================================================================

" Whether to show built-in colorschemes (default: show all)
if !exists('g:colorscheme_preview_show_builtin')
    let g:colorscheme_preview_show_builtin = 1
endif

" List of colorschemes to exclude (takes precedence over inclusion)
if !exists('g:colorscheme_preview_exclude')
    let g:colorscheme_preview_exclude = []
endif

" List of colorschemes to include (if empty, includes all except excluded)
if !exists('g:colorscheme_preview_include')
    let g:colorscheme_preview_include = []
endif

" Key mapping for the preview function (set to empty to disable)
if !exists('g:colorscheme_preview_key')
    let g:colorscheme_preview_key = '<F9>'
endif

" Directory for saving state (auto-detected if empty)
if !exists('g:colorscheme_preview_state_dir')
    let g:colorscheme_preview_state_dir = ''
endif

" ============================================================================
" Commands
" ============================================================================

command! ColorschemePreview call colorscheme_preview#Preview()
command! ColorschemePreviewSaveCurrent call colorscheme_preview#SaveCurrent()
command! ColorschemePreviewClearSaved call colorscheme_preview#ClearSaved()
command! ColorschemePreviewConfig call colorscheme_preview#ShowConfig()

" ============================================================================
" Key Mapping
" ============================================================================

if !empty(g:colorscheme_preview_key)
    execute 'nnoremap ' . g:colorscheme_preview_key . ' :ColorschemePreview<CR>'
endif

" ============================================================================
" Auto-restore on startup
" ============================================================================

augroup ColorschemePreviewRestore
    autocmd!
    autocmd VimEnter * call colorscheme_preview#LoadSaved()
augroup END

" ============================================================================
" Restore cpoptions
" ============================================================================

let &cpoptions = s:save_cpo
unlet s:save_cpo
