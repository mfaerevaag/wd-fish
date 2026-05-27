# wd

`wd` (*warp directory*) lets you jump to custom directories in your terminal, without using `cd`. Why? Because `cd` seems inefficient when the folder is frequently visited or has a long path.

This is a [fish shell](https://fishshell.com/) port of the [original wd](https://github.com/mfaerevaag/wd) for zsh. It uses the same `~/.warprc` file format, so you can share warp points between shells.

## Install

### [Fisher](https://github.com/jorgebucaran/fisher)

```fish
fisher install mfaerevaag/wd-fish
```

### [Oh My Fish](https://github.com/oh-my-fish/oh-my-fish)

```fish
omf install mfaerevaag/wd-fish
```

### Manual

Copy `functions/wd.fish` and `completions/wd.fish` to your fish config directory (usually `~/.config/fish/`).

## Usage

```fish
# Save the current directory as a warp point
wd add work

# Warp to it from anywhere
wd work

# Warp to a subdirectory
wd work src/components

# Go back to where you were
wd ..

# Overwrite an existing warp point with the current directory
wd add -f work

# Rename a warp point
wd rename work office

# List all warp points
wd list

# Show a warp point's path and whether it still exists
wd show office

# List files at a warp point
wd ls office

# Print the path without warping
wd path office

# Remove a warp point
wd rm office

# Remove all warp points whose directories no longer exist
wd clean
```

All commands support tab completion, including subdirectory completion for warp points:

![completion-example](https://raw.githubusercontent.com/mfaerevaag/wd-fish/master/completion-example.png)

## Commands

| Command | Description |
|---|---|
| `wd <point>` | Warp to the directory |
| `wd <point> <subdir>` | Warp to a subdirectory of the warp point |
| `wd ..` | Return to the previous directory (uses `popd`) |
| `wd add <point>` | Save the current directory (defaults to dirname if no name given) |
| `wd add -f <point>` | Save the current directory, overwriting if the point exists |
| `wd rm <point> ...` | Remove one or more warp points |
| `wd rename <old> <new>` | Rename a warp point |
| `wd show <point>` | Print the path and whether the directory exists |
| `wd clean` | Remove warp points whose target directories no longer exist |
| `wd list` | Print all warp points |
| `wd ls <point>` | List files at the warp point's directory |
| `wd path <point>` | Print the warp point's path |
| `wd --version` | Print version |
| `wd --help` | Print help |

## Compatibility

Warp points are stored in `~/.warprc` using the same `name:path` format as the zsh version. Paths starting with `~` are expanded correctly, so warp points created in zsh work without modification.

## License

[MIT](LICENSE)
