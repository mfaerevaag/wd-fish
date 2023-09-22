# wd

`wd` (*warp directory*) lets you jump to custom directories in your terminal, without using `cd`. Why? Because `cd` seems inefficient when the folder is frequently visited or has a long path.

*NOTE*: This is a port written for [fish-shell](https://fishshell.com/). If you're using `zsh`, check out the [original wd](https://github.com/mfaerevaag/wd), or the [wd-c](https://github.com/mfaerevaag/wd-c) version, which should work with all shells using wapper functions.


## Install

To install, you can either copy the files over to your fish directory manually (likely `~/.config/fish/`), or by using one of the package managers below.


### [Fisher](https://github.com/jorgebucaran/fisher)

    fisher install mfaerevaag/wd-fish

### [Oh My Fish](https://github.com/oh-my-fish/oh-my-fish)

    omf install mfaerevaag/wd-fish


## Usage

See [README](https://github.com/mfaerevaag/wd) from the original `wd` for zsh. Not all features are implemented, through, such as `wd clean` and force flags.

That being said, the completions are better (and more stable). You can warp directly to subdirectories using tab completions:

![completion-example](https://raw.githubusercontent.com/mfaerevaag/wd-fish/master/completion-example.png)


## License

The project is licensed under the [MIT license](https://github.com/mfaerevaag/wd-fish/blob/master/LICENSE).


## Finally

Simplicity has been in focus while writing this port. The data types are simple and functions operations mostly include looping through the `.warprc` config file. New features are most welcome, but please keep this in mind.

If you have issues, feedback or improvements, don't hesitate to report it or submit a pull-request. 
