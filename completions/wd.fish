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
