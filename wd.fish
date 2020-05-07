set -g wd_rc $HOME/.warprc

function wd -a cmd arg -d "warp directory"
    # check for rc, or create it
    if test ! -f $wd_rc
        touch $wd_rc
    end

    # yolo
    switch "$cmd"
        case version -v --version
            _wd_version
        case help -h --help ''
            _wd_help
        case add
            _wd_add $arg
        case rm
            _wd_rm $argv[2..-1]
        case list
            _wd_list
        case ls
            _wd_ls $arg
        case path
            _wd_path $arg
        case \*
            _wd_warp $cmd $arg
    end
end

# completion helpers

function _wd_complete_empty
    set cmd (commandline -opc)
    return (test (count $cmd) -eq 1)
end

function _wd_should_complete_point
    set cmd (commandline -opc)
    set relevant rm ls path

    # no args
    if test (count $cmd) -eq 1
        return 0
    end

    # relevant subcommand
    if contains $cmd[2] $relevant
        # not already completed
        if test (count $cmd) -eq 2
            return 0
        end
    end

    return 1
end

function _wd_complete_point
    set points

    while read -la line
        set split (string split ':' $line)

        # add with description, separated by tab
        set points "$points\n$split[1]\t -> $split[2..-1]"
    end < $wd_rc

    echo $points | string unescape
end

function _wd_complete_subdir
    set point (commandline -opc)[2]
    set subpath (commandline -ct)

    while read -la line
        set split (string split ':' $line)

        if [ "$point" = "$split[1]" ]
            set path $split[2..-1]
            __fish_complete_directories "$path/$subpath" | string replace "$path/" ""
            return 0
        end
    end < $wd_rc
end

# completions

# remove all file completions
complete -f -c wd

# complete points
complete -f -c wd -k -n "_wd_should_complete_point" -a "(_wd_complete_point)"
# complete sub commands
complete -f -c wd -k -n "_wd_complete_empty" -a help -d "show help"
complete -f -c wd -k -n "_wd_complete_empty" -a version -d "show version"
complete -f -c wd -k -n "_wd_complete_empty" -a ls -d "ls warp point directory"
complete -f -c wd -k -n "_wd_complete_empty" -a path -d "show path of warp point"
complete -f -c wd -k -n "_wd_complete_empty" -a list -d "list warp points"
complete -f -c wd -k -n "_wd_complete_empty" -a rm -d "remove warp point"
complete -f -c wd -k -n "_wd_complete_empty" -a add -d "add warp point"
# complete subdirs of given point
complete -f -c wd -a "(_wd_complete_subdir)"

# sub functions

function _wd_version
    echo "pre versioning..."
end

function _wd_help
    echo "Usage: wd [command] [point]

Commands:
    <point>           Warps to the directory specified by the warp point

    add <point>       Adds the current working directory to your warp points
    rm <point>        Removes the given warp point
    list              Print all stored warp points
    ls  <point>       Show files from given warp point (ls)
    path <point>      Show the path to given warp point (pwd)

    -v | [--]version  Print version
    -h | [--]help     Show this extremely helpful text"
end

function _wd_add -a point
    # check args
    if test ! "$point"
        echo "error: no point given" 1>&2
        return 1
    end

    # check for illegal chars
    if string match '*:*' $point > /dev/null
        echo "error: name contains illeagal characters" 1>&2
        return 1
    end

    # check if exists
    while read -la line
        set split (string split ':' $line)

        if test "$split[1]" = "$point"
            echo "error: point '$point' already exists" 1>&2
            return 1
        end
    end < $wd_rc

    # add warp point
    echo "$point:$PWD" >> $wd_rc
end

function _wd_rm
    set ret 0

    # check args
    if test (count $argv) -lt 1
        echo "error: no point given" 1>&2
        return 1
    end

    # tmp file to store new rc
    set tmp (mktemp /tmp/warprc.XXXXXX)

    # store those found
    set found

    # loop through points
    while read -la line
        set point (string split ':' $line)[1]

        # write those not found to tmp
        if contains $point $argv
            echo "fount $point!"
            set -a found $point
        else
            echo $line >> $tmp
        end
    end < $wd_rc

    # if found, update rc
    if test (count $found) -gt 0
        cat $tmp > $wd_rc
    end

    # warn about those not found
    for point in $argv
        if not contains $point $found
            echo "error: point '$point' not found" 1>&2
            set ret 1
        end
    end

    # remove tmp and return
    rm -f $tmp
    return $ret
end

function _wd_warp -a point subdir
    # check args
    if test ! "$point"
        echo "error: no point given" 1>&2
        return 1
    end

    # find point and warp
    while read -la line
        set split (string split : $line)

        # find point
        if test "$split[1]" = "$point"
            set path $split[2..-1]

            # check for subdir
            if test $subdir
                if test ! -d "$path/$subdir"
                    echo "error: subdir '$subdir' not found" 1>&2
                    return 1
                end

                set path "$path/$subdir"
            end

            # warp
            cd "$path"
            return 0
        end
    end < $wd_rc

    # not found
    echo "error: warp point '$point' not found" 1>&2
    return 1
end

function _wd_list
    while read -la line
        set split (string split : $line)
        set path (string replace "$HOME" "~" $split[2..-1])

        printf "$split[1]\t -> \t $path\n"
    end < $wd_rc
end

function _wd_ls -a point
    # check args
    if test ! "$point"
        echo "error: no point given" 1>&2
        return 1
    end

    while read -la line
        set split (string split : $line)

        # found
        if test "$split[1]" = "$point"
            ls "$split[2..-1]"
            return 0
        end
    end < $wd_rc

    # not found
    echo "error: point '$point' not found" 1>&2
    return 1
end

function _wd_path -a point
    # check args
    if test ! "$point"
        echo "error: no point given" 1>&2
        return 1
    end

    while read -la line
        set split (string split : $line)

        # found
        if test "$split[1]" = "$point"
            echo "$split[2..-1]"
            return 0
        end
    end < $wd_rc

    # not found
    echo "error: point '$point' not found" 1>&2
    return 1
end
