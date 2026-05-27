set -g wd_version 1.0.0
set -g wd_rc $HOME/.warprc

function wd -a cmd -d "warp directory"
    # check for rc, or create it
    if test ! -f $wd_rc
        touch $wd_rc
    end

    switch "$cmd"
        case version -v --version
            _wd_version
        case help -h --help ''
            _wd_help
        case add
            _wd_add $argv[2..-1]
        case rm
            _wd_rm $argv[2..-1]
        case clean
            _wd_clean
        case rename
            _wd_rename $argv[2] $argv[3]
        case show
            _wd_show $argv[2]
        case list
            _wd_list
        case ls
            _wd_ls $argv[2]
        case path
            _wd_path $argv[2]
        case \*
            _wd_warp $cmd $argv[2]
    end
end

# sub functions

function _wd_version
    echo "wd-fish $wd_version"
end

function _wd_help
    echo "Usage: wd [command] [point]

Commands:
    <point>           Warps to the directory specified by the warp point
    <point> <subdir>  Warps to a subdirectory of the warp point

    add <point>       Adds the current working directory to your warp points
    add -f <point>    Adds or overwrites an existing warp point
    rm <point>        Removes the given warp point
    rename <old> <new>  Renames a warp point
    show <point>      Show the path and whether it exists
    clean             Remove warp points with missing directories
    list              Print all stored warp points
    ls  <point>       Show files from given warp point (ls)
    path <point>      Show the path to given warp point (pwd)

    -v | [--]version  Print version
    -h | [--]help     Show this extremely helpful text"
end

function _wd_add
    set -l force 0
    set -l point

    for a in $argv
        switch "$a"
            case -f --force
                set force 1
            case '*'
                set point $a
        end
    end

    if test ! "$point"
        set point (basename $PWD)
    end

    # check for illegal chars
    if string match '*:*' $point >/dev/null
        echo "error: name contains illegal characters" 1>&2
        return 1
    end

    # check if exists
    while read -la line
        set split (string split -m1 ':' $line)

        if test "$split[1]" = "$point"
            if test $force -eq 1
                _wd_rm $point
                echo "$point:$PWD" >>$wd_rc
                return 0
            end
            echo "error: point '$point' already exists" 1>&2
            return 1
        end
    end <$wd_rc

    # add warp point
    echo "$point:$PWD" >>$wd_rc
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
        set point (string split -m1 ':' $line)[1]

        # write those not found to tmp
        if contains $point $argv
            set -a found $point
        else
            echo $line >>$tmp
        end
    end <$wd_rc

    # if found, update rc
    if test (count $found) -gt 0
        cat $tmp >$wd_rc
    end

    rm -f $tmp

    # warn about those not found
    for point in $argv
        if not contains $point $found
            echo "error: point '$point' not found" 1>&2
            set ret 1
        end
    end

    return $ret
end

function _wd_clean
    set tmp (mktemp /tmp/warprc.XXXXXX)
    set removed

    while read -la line
        set split (string split -m1 ':' $line)
        set path (string replace -r '^~' $HOME $split[2])

        if test -d "$path"
            echo $line >>$tmp
        else
            set -a removed $split[1]
        end
    end <$wd_rc

    if test (count $removed) -gt 0
        cat $tmp >$wd_rc
        for point in $removed
            echo "removed: $point"
        end
    else
        echo "no stale warp points found"
    end

    rm -f $tmp
end

function _wd_rename -a old new
    if test ! "$old" -o ! "$new"
        echo "error: usage: wd rename <old> <new>" 1>&2
        return 1
    end

    if string match '*:*' $new >/dev/null
        echo "error: name contains illegal characters" 1>&2
        return 1
    end

    set tmp (mktemp /tmp/warprc.XXXXXX)
    set found 0

    while read -la line
        set split (string split -m1 ':' $line)

        if test "$split[1]" = "$new"
            rm -f $tmp
            echo "error: point '$new' already exists" 1>&2
            return 1
        end

        if test "$split[1]" = "$old"
            echo "$new:$split[2]" >>$tmp
            set found 1
        else
            echo $line >>$tmp
        end
    end <$wd_rc

    if test $found -eq 0
        rm -f $tmp
        echo "error: point '$old' not found" 1>&2
        return 1
    end

    cat $tmp >$wd_rc
    rm -f $tmp
end

function _wd_show -a point
    if test ! "$point"
        echo "error: no point given" 1>&2
        return 1
    end

    while read -la line
        set split (string split -m1 : $line)

        if test "$split[1]" = "$point"
            set path (string replace -r '^~' $HOME $split[2])

            if test -d "$path"
                echo "$path (valid)"
            else
                echo "$path (missing)" 1>&2
                return 1
            end
            return 0
        end
    end <$wd_rc

    echo "error: point '$point' not found" 1>&2
    return 1
end

function _wd_warp -a point subdir
    if test "$point" = ".."
        popd
        return
    end

    # check args
    if test ! "$point"
        echo "error: no point given" 1>&2
        return 1
    end

    # find point and warp
    while read -la line
        set split (string split -m1 : $line)

        # find point
        if test "$split[1]" = "$point"
            set path (string replace -r '^~' $HOME $split[2])

            # check for subdir
            if test $subdir
                if test ! -d "$path/$subdir"
                    echo "error: subdir '$subdir' not found" 1>&2
                    return 1
                end

                set path "$path/$subdir"
            end

            # warp
            pushd "$path" >/dev/null
            return 0
        end
    end <$wd_rc

    # not found
    echo "error: warp point '$point' not found" 1>&2
    return 1
end

function _wd_list
    while read -la line
        set split (string split -m1 : $line)
        set path (string replace "$HOME" "~" $split[2])

        printf "$split[1]\t -> \t $path\n"
    end <$wd_rc
end

function _wd_ls -a point
    # check args
    if test ! "$point"
        echo "error: no point given" 1>&2
        return 1
    end

    while read -la line
        set split (string split -m1 : $line)

        # found
        if test "$split[1]" = "$point"
            ls (string replace -r '^~' $HOME "$split[2]")
            return 0
        end
    end <$wd_rc

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
        set split (string split -m1 : $line)

        # found
        if test "$split[1]" = "$point"
            echo (string replace -r '^~' $HOME $split[2])
            return 0
        end
    end <$wd_rc

    # not found
    echo "error: point '$point' not found" 1>&2
    return 1
end
