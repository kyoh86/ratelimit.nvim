# What are these?

Functions that allow you to call a function not more than once in a given timeframe.

This is a library forked from https://github.com/runiq/neovim-throttle-debounce
with some changes for usefulness.


## Install

e.g. Packer:

```lua
use({"kyoh86/ratelimit.nvim"})
```

## Usage

```lua
--- Debounces a function on the leading edge; interval=300ms
require('ratelimit.debounce').leading(function(...)
    ...
end, 300)

--- Throttles a function on the trailing edge; interval=50ms
require('ratelimit.throttle').trailing(function(...)
    ...
end, 50)

```

## Throttling on the leading edge

This can be illustrated with timing diagrams. In the following diagrams, `f` designates call to the throttled function, `t` is the period where the timer is running, and `x` shows you the *actual* execution point of the throttled function.

```
f 1  2  3  4  5  6
t -------- --------
x 1--      4--
```

In this case, the function `f` was called 6 times. `f`'s timer `t` was started on the first invocation of f, and stopped shortly after the third invocation, taking 8 'ticks'.
During this run of the timer, the function `f` was e`x`ecuted only once –– at the beginning (*leading edge*) --, taking 3 ticks to execute.
This is then repeated for function invocations 4 through 6.

You can use the `test_defer()` function from this module to show you an example that corresponds to the timing diagrams.
Its invocation and output will look something like this:

```vim
:lua require'defer'.test_defer('tl')
" tl: 1
" 1
" 2
" 3
" tl: 4
" 4
" 5
" 6
```

## Throttling on the trailing edge

Using the arguments of the *first* function call while the timer was running (the default).

```
f 1  2  3    4  5  6
t --------   --------
x         1--        4--
```

```vim
:lua require'defer'.test_defer('tt')`
" 1
" 2
" 3
" tt: 1
" 4
" 5
" 6
" tt: 4
```

Using the arguments of the *last* call while the timer was running:

```
f 1  2  3    4  5  6
t --------   --------
x         3--        6--
```

```vim
:lua require'defer'.test_defer('tt', true)`
" 1
" 2
" 3
" tt: 3
" 4
" 5
" 6
" tt: 6
```

## Debouncing on the leading edge

On each function call, the timer is reset (indicated by an `r`):

```
f 1  2  3  4  5  6
t ---r--r--r--r--r-------
x 1--
```
```vim
:lua require'defer'.test_defer('dl')
" dl: 1
" 1
" 2
" 3
" 4
" 5
" 6
```

## Debouncing on the trailing edge


Using the arguments of the *last* function call while the timer was running (the default).

```
f 1  2  3  4  5  6
t ---r--r--r--r--r-------
x                        6--
```

```vim
:lua require'defer'.test_defer('dt')
" 1
" 2
" 3
" 4
" 5
" 6
" (pause, press <cr>)
" dt: 6
```

Using the arguments of the *first* function call while the timer was running.

```
f 1  2  3  4  5  6
t ---r--r--r--r--r-------
x                        1--
```

```vim
:lua require'defer'.test_defer('dt', true)
" 1
" 2
" 3
" 4
" 5
" 6
" (pause, press <cr>)
" dt: 1
```
