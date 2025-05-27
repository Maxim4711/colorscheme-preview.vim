" ============================================================================
" File: autoload/colorscheme_preview.vim
" Description: Main functionality for colorscheme preview plugin
" Author: Your Name <your.email@example.com>
" Version: 1.0
" License: MIT
" ============================================================================

" Save cpoptions and set to vim defaults
let s:save_cpo = &cpoptions
set cpoptions&vim

" ============================================================================
" Built-in Colorschemes List
" ============================================================================

let s:builtin_schemes = [
    \ 'default', 'blue', 'darkblue', 'delek', 'desert', 'elflord',
    \ 'evening', 'industry', 'koehler', 'morning', 'murphy', 'pablo',
    \ 'peachpuff', 'ron', 'shine', 'slate', 'torte', 'zellner',
    \ 'lunaperche', 'retrobox', 'sorbet', 'wildcharm', 'vim',
    \ 'habamax', 'quiet', 'zaibatsu'
\ ]

" ============================================================================
" Utility Functions
" ============================================================================

" Get configuration directory
function! s:GetConfigDir()
    if !empty(g:colorscheme_preview_state_dir)
        return g:colorscheme_preview_state_dir
    endif
    return has('nvim') ? stdpath('config') : expand('~/.vim')
endfunction

" Get state file path
function! s:GetStateFile()
    return s:GetConfigDir() . '/colorscheme_state'
endfunction

" Check if colorscheme should be included
function! s:ShouldIncludeScheme(scheme)
    " Check exclusion list first
    if index(g:colorscheme_preview_exclude, a:scheme) >= 0
        return 0
    endif
    
    " Check if it's a built-in scheme and should be excluded
    if !g:colorscheme_preview_show_builtin && index(s:builtin_schemes, a:scheme) >= 0
        return 0
    endif
    
    " Check inclusion list (if specified)
    if !empty(g:colorscheme_preview_include)
        return index(g:colorscheme_preview_include, a:scheme) >= 0
    endif
    
    return 1
endfunction

" Get all available colorschemes with filtering
function! s:GetFilteredColorschemes()
    let l:schemes = []
    
    " Search in all runtimepath directories
    for l:path in split(&runtimepath, ',')
        let l:color_files = split(glob(l:path . '/colors/*.vim'), '\n')
        for l:file in l:color_files
            let l:scheme_name = fnamemodify(l:file, ':t:r')
            if index(l:schemes, l:scheme_name) == -1 && s:ShouldIncludeScheme(l:scheme_name)
                call add(l:schemes, l:scheme_name)
            endif
        endfor
    endfor
    
    return sort(l:schemes)
endfunction

" Save colorscheme to state file
function! s:SaveColorscheme(scheme)
    let l:config_dir = s:GetConfigDir()
    let l:state_file = s:GetStateFile()
    
    " Create directory if it doesn't exist
    if !isdirectory(l:config_dir)
        call mkdir(l:config_dir, 'p')
    endif
    
    " Write colorscheme to file
    try
        call writefile([a:scheme], l:state_file)
    catch
        echohl ErrorMsg
        echo "Failed to save colorscheme state: " . v:exception
        echohl None
    endtry
endfunction

" ============================================================================
" Simple Preview Function (works with all Vim versions)
" ============================================================================

function! s:SimpleColorschemePreview()
    let l:original = get(g:, 'colors_name', 'default')
    let l:schemes = s:GetFilteredColorschemes()
    
    if empty(l:schemes)
        echohl WarningMsg
        echo "No colorschemes found matching your filter criteria!"
        echohl None
        return
    endif
    
    " Find current scheme index
    let l:index = 0
    for i in range(len(l:schemes))
        if l:schemes[i] ==# l:original
            let l:index = i
            break
        endif
    endfor
    
    " Create new window
    new
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal nonumber
    setlocal norelativenumber
    setlocal nowrap
    setlocal cursorline
    
    file [Colorscheme\ Preview]
    
    " Update display function
    function! s:UpdateDisplay(schemes, index) closure
        %delete _
        call setline(1, 'Colorscheme Preview - j/k/↓/↑: navigate, Enter: select, q: quit, r: restore')
        call setline(2, 'Filtered: ' . len(a:schemes) . ' schemes, Current: ' . (a:index + 1))
        call setline(3, 'Original: ' . l:original)
        call setline(4, '')
        
        for i in range(len(a:schemes))
            let l:line = (i == a:index ? '► ' : '  ') . a:schemes[i]
            call setline(5 + i, l:line)
        endfor
        
        call cursor(5 + a:index, 1)
        
        try
            execute 'colorscheme ' . a:schemes[a:index]
        catch
            " Ignore errors
        endtry
    endfunction
    
    call s:UpdateDisplay(l:schemes, l:index)
    
    " Navigation mappings
    nnoremap <buffer> <silent> j :call <SID>MoveDown()<CR>
    nnoremap <buffer> <silent> k :call <SID>MoveUp()<CR>
    nnoremap <buffer> <silent> <Down> :call <SID>MoveDown()<CR>
    nnoremap <buffer> <silent> <Up> :call <SID>MoveUp()<CR>
    nnoremap <buffer> <silent> <CR> :call <SID>SelectScheme()<CR>
    nnoremap <buffer> <silent> q :call <SID>QuitPreview()<CR>
    nnoremap <buffer> <silent> r :call <SID>RestoreOriginal()<CR>
    nnoremap <buffer> <silent> <Esc> :call <SID>QuitPreview()<CR>
    
    " Navigation functions
    function! s:MoveDown() closure
        let l:index = (l:index + 1) % len(l:schemes)
        call s:UpdateDisplay(l:schemes, l:index)
    endfunction
    
    function! s:MoveUp() closure
        let l:index = (l:index - 1 + len(l:schemes)) % len(l:schemes)
        call s:UpdateDisplay(l:schemes, l:index)
    endfunction
    
    function! s:SelectScheme() closure
        let l:selected = l:schemes[l:index]
        call s:SaveColorscheme(l:selected)
        quit
        echo 'Selected and saved colorscheme: ' . l:selected
    endfunction
    
    function! s:RestoreOriginal() closure
        execute 'colorscheme ' . l:original
        call s:UpdateDisplay(l:schemes, l:index)
        echo 'Restored original colorscheme: ' . l:original
    endfunction
    
    function! s:QuitPreview() closure
        execute 'colorscheme ' . l:original
        quit
        echo 'Cancelled - restored original: ' . l:original
    endfunction
endfunction

" ============================================================================
" Popup Preview Function (Vim 8.2+)
" ============================================================================

if has('popupwin')
    function! s:PopupColorschemePreview()
        let l:original = get(g:, 'colors_name', 'default')
        let l:schemes = s:GetFilteredColorschemes()
        
        if empty(l:schemes)
            echohl WarningMsg
            echo "No colorschemes found matching your filter criteria!"
            echohl None
            return
        endif
        
        " Find current scheme index
        let l:current_idx = 0
        for i in range(len(l:schemes))
            if l:schemes[i] ==# l:original
                let l:current_idx = i
                break
            endif
        endfor
        
        " State variables
        let s:popup_current_idx = l:current_idx
        let s:popup_schemes = l:schemes
        let s:popup_original = l:original
        
        " Create popup
        let l:popup_id = popup_create(l:schemes, #{
            \ title: ' Colorscheme Preview (' . len(l:schemes) . ' filtered) ',
            \ pos: 'center',
            \ minwidth: 40,
            \ maxheight: 20,
            \ scrollbar: 1,
            \ cursorline: 1,
            \ filter: 's:PopupFilter',
            \ callback: 's:PopupCallback'
            \ })
        
        " Set initial position
        call win_execute(l:popup_id, 'normal! ' . (l:current_idx + 1) . 'G')
        execute "colorscheme " . l:schemes[l:current_idx]
    endfunction
    
    function! s:PopupFilter(popup_id, key)
        let l:schemes = s:popup_schemes
        let l:original = s:popup_original
        let l:current_idx = s:popup_current_idx
        
        if a:key == "\<CR>"
            call popup_close(a:popup_id, l:schemes[l:current_idx])
            return 1
        elseif a:key == "\<Esc>" || a:key == 'q'
            execute "colorscheme " . l:original
            call popup_close(a:popup_id, -1)
            return 1
        elseif a:key == 'j' || a:key == "\<Down>"
            let l:new_idx = (l:current_idx + 1) % len(l:schemes)
            let s:popup_current_idx = l:new_idx
            call win_execute(a:popup_id, 'normal! ' . (l:new_idx + 1) . 'G')
            execute "colorscheme " . l:schemes[l:new_idx]
            return 1
        elseif a:key == 'k' || a:key == "\<Up>"
            let l:new_idx = (l:current_idx - 1 + len(l:schemes)) % len(l:schemes)
            let s:popup_current_idx = l:new_idx
            call win_execute(a:popup_id, 'normal! ' . (l:new_idx + 1) . 'G')
            execute "colorscheme " . l:schemes[l:new_idx]
            return 1
        elseif a:key == 'r'
            execute "colorscheme " . l:original
            return 1
        endif
        
        return 0
    endfunction
    
    function! s:PopupCallback(popup_id, result)
        if a:result == -1
            execute "colorscheme " . s:popup_original
            echo "Cancelled - restored original: " . s:popup_original
        else
            call s:SaveColorscheme(a:result)
            echo "Selected and saved colorscheme: " . a:result
        endif
        redraw!
    endfunction
endif

" ============================================================================
" Public API Functions
" ============================================================================

" Main preview function (chooses best available method)
function! colorscheme_preview#Preview()
    if has('popupwin')
        call s:PopupColorschemePreview()
    else
        call s:SimpleColorschemePreview()
    endif
endfunction

" Save current colorscheme
function! colorscheme_preview#SaveCurrent()
    let l:current = get(g:, 'colors_name', 'default')
    call s:SaveColorscheme(l:current)
    echo "Saved current colorscheme: " . l:current
endfunction

" Clear saved colorscheme
function! colorscheme_preview#ClearSaved()
    let l:state_file = s:GetStateFile()
    if filereadable(l:state_file)
        call delete(l:state_file)
        echo "Cleared saved colorscheme state"
    else
        echo "No saved colorscheme state found"
    endif
endfunction

" Load saved colorscheme
function! colorscheme_preview#LoadSaved()
    let l:state_file = s:GetStateFile()
    
    if filereadable(l:state_file)
        let l:saved_scheme = readfile(l:state_file)
        if len(l:saved_scheme) > 0 && !empty(l:saved_scheme[0])
            try
                execute 'colorscheme ' . l:saved_scheme[0]
                echo "Restored colorscheme: " . l:saved_scheme[0]
            catch
                echohl WarningMsg
                echo "Failed to load saved colorscheme: " . l:saved_scheme[0]
                echohl None
            endtry
        endif
    endif
endfunction

" Show configuration
function! colorscheme_preview#ShowConfig()
    echo "Colorscheme Preview Configuration:"
    echo "  Show built-in: " . g:colorscheme_preview_show_builtin
    echo "  Exclude list: " . string(g:colorscheme_preview_exclude)
    echo "  Include list: " . string(g:colorscheme_preview_include)
    echo "  State file: " . s:GetStateFile()
    echo "  Available schemes: " . len(s:GetFilteredColorschemes())
endfunction

" ============================================================================
" Restore cpoptions
" ============================================================================

let &cpoptions = s:save_cpo
unlet s:save_cpo
