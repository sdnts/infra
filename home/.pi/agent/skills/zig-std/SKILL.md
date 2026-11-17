---
name: zig-std
description: Reference documentation for the Zig standard library. Use when working with the Zig programming language.
allowed-tools: read
---

Source code for the Zig standard library exists in `/Users/sdnts/.zig/lib/std`. This is henceforth referred to as
@std-root.

The documentation you read is the authoritative source of truth. Struct paths and language features evolve quite a bit
with Zig, so always resolve disputes by trusting only the documentation on disk, even if it conflicts with what you know.

Make sure you read all comments on symbols, they contain details about when and how to use the symbol. While reading a
file that `@imports` another file, follow the import chain to gather more context if you need it.

# Locating source code for symbols

Types, functions, structs and other declarations are called symbols, and to understand how to use them correctly, you're
going to read the standard library's source code. The location of a symbol in the standard library is the fully qualified
path you use when you use that symbol. For example, the symbol to print debug statements is `std.debug.print()` (a
function), and so the path for this symbol is `std.debug.print`. Paths are combinations of segements separated by `.`.
The segements in `std.debug.print` are [`std`, `debug`, `print`].

File heirarchy generally mirrors the standard library symbol paths.

A quick way to find the file where a symbol is defined is described below:

1. Look at the last path segment of the symbol, and try to locate a file with the `.zig` extension with that path under
   @std-root.
2. If such a file does not exist, look at the previous path segment, and try to locate a file with the `.zig` extension
   _that_ path under @std-root. Keep doing this until you find a file.
3. Now read through this file and find the symbol's definition. If you cannot find this definition, error out immediately.
   Remember that you may have to dig inside multiple other symbol definitions to get to the symbol you're looking for.

### Example (`std.debug.print`)

Here, the last path segment for the symbol is `print`, so we'll try to locate a file called `@std-root/std/debug/print.zig`.
This file does not exist, so we look at the second-last path segment (`debug`) and try to locate a file called
`@std-root/std/debug.zig`. This does exist, so we'll read through it to find the definition of `std.debug.print`.

### Example (`std.Io.Clock.Timestamp.addDuration`)

Here, the last path segment for the symbol is `addDuration`, so we'll try to locate a file called `@std-root/std/Io/File/addDuration.zig`.
This file does not exist, so we look at the second-last path segment (`Timestamp`) and try to locate a file called
`@std-root/std/Io/Clock/Timestamp.zig`. This also does not exist, so we look at the third-last path segment (`Clock`) and
try to locate a file called `@std-root/std/Io/Clock.zig`. This also does not exist, so we look at the fourth-last path
segment (`Io`) and try to locate a file called `@std-root/std/Io.zig`. This does exist, so we'll read through it to find
the definition of `std.Io.Clock.Timestamp.addDuration`.

