#!/usr/bin/env bash

# @meta author Geert Jan Bex <geertjan.bex@uhasselt.be>
# @meta version 1.0.0
# @meta require-tools dd,mkfs.ext4,mkfs.ext3,mkfs.ext2,fuse2fs,fusermount,numfmt

# @describe Easily manage file-as-filesystem tool
# 
# It can be used to create, mount and unmount a file as
# a file system

# function to check whether its argument is a valid size, it writes a message
# to stderr and exits with a non-zero status if the size is invalid
is_valid_size() {
    if ! numfmt --from=iec "$1" &>/dev/null; then
        echo "Invalid size: $1" >&2
        exit 1
    fi
}

# function to check whether its argument is a valid block size, it writes a message
# to stderr and exits with a non-zero status if the block size is invalid, it also
# checks if the block size is a multiple of 512 bytes, and is less than or equal to 1M
is_valid_block_size() {
    if ! numfmt --from=iec "$1" &>/dev/null; then
        echo "Invalid block size: $1" >&2
        exit 1
    fi
    local block_size_bytes=$(numfmt --from=iec "$1")
    if (( block_size_bytes % 512 != 0 || block_size_bytes > 1048576 )); then
        echo "Block size must be a multiple of 512 bytes and less than or equal to 1M" >&2
        exit 1
    fi
}

# function to check whether the specified file system type is supported, it writes a message
# to stderr and exits with a non-zero status if the file system type is not supported
is_valid_fs_type() {
    local fs_type="$1"
    if ! command -v mkfs.$fs_type &>/dev/null; then
        echo "Unsupported file system type: $fs_type" >&2
        exit 1
    fi
}

# function to check whether the image file already exists, if so, write a message
# to stderr and exit with a non-zero status
is_image_file_exists() {
    if [[ -f "$1" ]]; then
        echo "File $1 already exists. Please remove it before running the script." >&2
        exit 2
    fi
}

# function to compute the number of blocks needed for the file system image
calculate_blocks() {
    local size_in_bytes=$(numfmt --from=iec "$1")
    local block_size_in_bytes=$(numfmt --from=iec "$2")
    echo $((size_in_bytes / block_size_in_bytes))
}

# @cmd Create a file system image
# @arg image_file!                           Name of the image file to use
# @arg size!                                 Size of the file system, units are M, G
# @option -b --block_size=4K                 Block size of the file system, units are K, M
# @option -t --fs_type[=ext4|ext3|ext2]      Type of the file system
# @flag -f --force                           Force creation of the file system image, even if it already exists
create() {
    is_valid_size "$argc_size"
    is_valid_block_size "$argc_block_size"
    is_valid_fs_type "$argc_fs_type"
    if [[ -z "$argc_force" ]]; then
        is_image_file_exists "$argc_image_file"
    fi
    local nr_blocks=$(calculate_blocks "$argc_size" "$argc_block_size")
    dd status=none if=/dev/zero of=$argc_image_file bs=$argc_block_size count=$nr_blocks
    mkfs.$argc_fs_type -q -b $(numfmt --from=iec $argc_block_size) $argc_image_file
}

# function to verify whether the mount point is valid, i.e.,
#  - it exists
#  - it is a directory
#  - it is empty
#  - it is not mounted
is_valid_mount_point() {
    if [[ ! -d "$1" ]]; then
        echo "Mount point $1 does not exist." >&2
        exit 3
    fi
    if [[ -n "$(/usr/bin/mount | grep "$1")" ]]; then
        echo "Mount point $1 is already mounted." >&2
        exit 3
    fi
    if [[ -n "$(ls -A "$1")" ]]; then
        echo "Mount point $1 is not empty." >&2
        exit 3
    fi
}

# @cmd Mount a file system image
# @arg image_file!                           Name of the image file to use
# @arg mount_point!                          Mount point for the file system image
# @flag -r --read_only                       Mount the file system image as read-only
mount() {
    argc_mount_point="${argc_mount_point%/}"
    # if image file doesn't exists, write a message to stderr and exit with a non-zero status
    if [[ ! -f "$argc_image_file" ]]; then
        echo "Image file $argc_image_file does not exist." >&2
        exit 1
    fi
    # if mount point does not exists, create it.
    if [[ ! -d "$argc_mount_point" ]]; then
        mkdir -p "$argc_mount_point"
        # if this fails, write a message to stderr and exit with a non-zero status
        if [[ $? -ne 0 ]]; then
            echo "Failed to create mount point $argc_mount_point." >&2
            exit 3
        fi
    fi
    is_valid_mount_point "$argc_mount_point"
    if [[ -n "$argc_read_only" ]]; then
        fuse2fs -o ro "$argc_image_file" "$argc_mount_point"
    else
        fuse2fs -o fakeroot "$argc_image_file" "$argc_mount_point"
    fi
}

# @cmd Unmount a file system image
# @arg mount_point!                          Mount point for the file system image
unmount() {
    argc_mount_point="${argc_mount_point%/}"
    # if mount point does not exists, write a message to stderr and exit with a non-zero status
    if [[ ! -d "$argc_mount_point" ]]; then
        echo "Mount point $argc_mount_point does not exist." >&2
        exit 1
    fi
    # if mount point is not mounted, write a message to stderr and exit with a non-zero status
    if [[ -z "$(/usr/bin/mount | grep "$argc_mount_point")" ]]; then
        echo "Mount point $argc_mount_point is not mounted." >&2
        exit 2
    fi
    fusermount -u "$argc_mount_point"
}

# ARGC-BUILD {
# This block was generated by argc (https://github.com/sigoden/argc).
# Modifying it manually is not recommended

_argc_run() {
    if [[ "${1:-}" == "___internal___" ]]; then
        _argc_die "error: unsupported ___internal___ command"
    fi
    if [[ "${OS:-}" == "Windows_NT" ]] && [[ -n "${MSYSTEM:-}" ]]; then
        set -o igncr
    fi
    argc__args=("$(basename "$0" .sh)" "$@")
    argc__positionals=()
    _argc_index=1
    _argc_len="${#argc__args[@]}"
    _argc_tools=()
    _argc_parse
    _argc_require_tools "${_argc_tools[@]}"
    if [ -n "${argc__fn:-}" ]; then
        $argc__fn "${argc__positionals[@]}"
    fi
}

_argc_usage() {
    cat <<-'EOF'
confuse 1.0.0
Geert Jan Bex <geertjan.bex@uhasselt.be>
Easily manage file-as-filesystem tool

It can be used to create, mount and unmount a file as
a file system

USAGE: confuse <COMMAND>

COMMANDS:
  create   Create a file system image
  mount    Mount a file system image
  unmount  Unmount a file system image
EOF
    exit
}

_argc_version() {
    echo confuse 1.0.0
    exit
}

_argc_parse() {
    local _argc_key _argc_action
    local _argc_subcmds="create, mount, unmount"
    while [[ $_argc_index -lt $_argc_len ]]; do
        _argc_item="${argc__args[_argc_index]}"
        _argc_key="${_argc_item%%=*}"
        case "$_argc_key" in
        --help | -help | -h)
            _argc_usage
            ;;
        --version | -version | -V)
            _argc_version
            ;;
        --)
            _argc_dash="${#argc__positionals[@]}"
            argc__positionals+=("${argc__args[@]:$((_argc_index + 1))}")
            _argc_index=$_argc_len
            break
            ;;
        create)
            _argc_index=$((_argc_index + 1))
            _argc_action=_argc_parse_create
            break
            ;;
        mount)
            _argc_index=$((_argc_index + 1))
            _argc_action=_argc_parse_mount
            break
            ;;
        unmount)
            _argc_index=$((_argc_index + 1))
            _argc_action=_argc_parse_unmount
            break
            ;;
        help)
            local help_arg="${argc__args[$((_argc_index + 1))]:-}"
            case "$help_arg" in
            create)
                _argc_usage_create
                ;;
            mount)
                _argc_usage_mount
                ;;
            unmount)
                _argc_usage_unmount
                ;;
            "")
                _argc_usage
                ;;
            *)
                _argc_die "error: invalid value \`$help_arg\` for \`<command>\`"$'\n'"  [possible values: $_argc_subcmds]"
                ;;
            esac
            ;;
        *)
            _argc_die "error: \`confuse\` requires a subcommand but one was not provided"$'\n'"  [subcommands: $_argc_subcmds]"
            ;;
        esac
    done
    _argc_tools=(dd mkfs.ext4 mkfs.ext3 mkfs.ext2 fuse2fs fusermount numfmt)
    if [[ -n "${_argc_action:-}" ]]; then
        $_argc_action
    else
        _argc_usage
    fi
}

_argc_usage_create() {
    cat <<-'EOF'
Create a file system image

USAGE: confuse create [OPTIONS] <IMAGE-FILE> <SIZE>

ARGS:
  <IMAGE-FILE>  Name of the image file to use
  <SIZE>        Size of the file system, units are M, G

OPTIONS:
  -b, --block_size <BLOCK-SIZE>  Block size of the file system, units are K, M [default: 4K]
  -t, --fs_type <FS-TYPE>        Type of the file system [possible values: ext4, ext3, ext2] [default: ext4]
  -f, --force                    Force creation of the file system image, even if it already exists
  -h, --help                     Print help
EOF
    exit
}

_argc_parse_create() {
    local _argc_key _argc_action
    local _argc_subcmds=""
    while [[ $_argc_index -lt $_argc_len ]]; do
        _argc_item="${argc__args[_argc_index]}"
        _argc_key="${_argc_item%%=*}"
        case "$_argc_key" in
        --help | -help | -h)
            _argc_usage_create
            ;;
        --)
            _argc_dash="${#argc__positionals[@]}"
            argc__positionals+=("${argc__args[@]:$((_argc_index + 1))}")
            _argc_index=$_argc_len
            break
            ;;
        --block_size | -b)
            _argc_take_args "--block_size <BLOCK-SIZE>" 1 1 "-" ""
            _argc_index=$((_argc_index + _argc_take_args_len + 1))
            if [[ -z "${argc_block_size:-}" ]]; then
                argc_block_size="${_argc_take_args_values[0]:-}"
            else
                _argc_die "error: the argument \`--block_size\` cannot be used multiple times"
            fi
            ;;
        --fs_type | -t)
            _argc_take_args "--fs_type <FS-TYPE>" 1 1 "-" ""
            _argc_index=$((_argc_index + _argc_take_args_len + 1))
            _argc_validate_choices '`<FS-TYPE>`' "$(printf "%s\n" ext4 ext3 ext2)" "${_argc_take_args_values[@]}"
            if [[ -z "${argc_fs_type:-}" ]]; then
                argc_fs_type="${_argc_take_args_values[0]:-}"
            else
                _argc_die "error: the argument \`--fs_type\` cannot be used multiple times"
            fi
            ;;
        --force | -f)
            if [[ "$_argc_item" == *=* ]]; then
                _argc_die "error: flag \`--force\` don't accept any value"
            fi
            _argc_index=$((_argc_index + 1))
            if [[ -n "${argc_force:-}" ]]; then
                _argc_die "error: the argument \`--force\` cannot be used multiple times"
            else
                argc_force=1
            fi
            ;;
        *)
            if _argc_maybe_flag_option "-" "$_argc_item"; then
                _argc_die "error: unexpected argument \`$_argc_key\` found"
            fi
            argc__positionals+=("$_argc_item")
            _argc_index=$((_argc_index + 1))
            ;;
        esac
    done
    _argc_tools=(dd mkfs.ext4 mkfs.ext3 mkfs.ext2 fuse2fs fusermount numfmt)
    if [[ -n "${_argc_action:-}" ]]; then
        $_argc_action
    else
        argc__fn=create
        if [[ "${argc__positionals[0]:-}" == "help" ]] && [[ "${#argc__positionals[@]}" -eq 1 ]]; then
            _argc_usage_create
        fi
        _argc_match_positionals 0 0
        local values_index values_size
        IFS=: read -r values_index values_size <<<"${_argc_match_positionals_values[0]:-}"
        if [[ -n "$values_index" ]]; then
            argc_image_file="${argc__positionals[values_index]}"
        else
            _argc_die "error: the required environments \`<IMAGE-FILE>\` were not provided"
        fi
        IFS=: read -r values_index values_size <<<"${_argc_match_positionals_values[1]:-}"
        if [[ -n "$values_index" ]]; then
            argc_size="${argc__positionals[values_index]}"
        else
            _argc_die "error: the required environments \`<SIZE>\` were not provided"
        fi
        if [[ -z "${argc_block_size:-}" ]]; then
            argc_block_size=4K
        fi
        if [[ -z "${argc_fs_type:-}" ]]; then
            argc_fs_type=ext4
        fi
    fi
}

_argc_usage_mount() {
    cat <<-'EOF'
Mount a file system image

USAGE: confuse mount [OPTIONS] <IMAGE-FILE> <MOUNT-POINT>

ARGS:
  <IMAGE-FILE>   Name of the image file to use
  <MOUNT-POINT>  Mount point for the file system image

OPTIONS:
  -r, --read_only  Mount the file system image as read-only
  -h, --help       Print help
EOF
    exit
}

_argc_parse_mount() {
    local _argc_key _argc_action
    local _argc_subcmds=""
    while [[ $_argc_index -lt $_argc_len ]]; do
        _argc_item="${argc__args[_argc_index]}"
        _argc_key="${_argc_item%%=*}"
        case "$_argc_key" in
        --help | -help | -h)
            _argc_usage_mount
            ;;
        --)
            _argc_dash="${#argc__positionals[@]}"
            argc__positionals+=("${argc__args[@]:$((_argc_index + 1))}")
            _argc_index=$_argc_len
            break
            ;;
        --read_only | -r)
            if [[ "$_argc_item" == *=* ]]; then
                _argc_die "error: flag \`--read_only\` don't accept any value"
            fi
            _argc_index=$((_argc_index + 1))
            if [[ -n "${argc_read_only:-}" ]]; then
                _argc_die "error: the argument \`--read_only\` cannot be used multiple times"
            else
                argc_read_only=1
            fi
            ;;
        *)
            if _argc_maybe_flag_option "-" "$_argc_item"; then
                _argc_die "error: unexpected argument \`$_argc_key\` found"
            fi
            argc__positionals+=("$_argc_item")
            _argc_index=$((_argc_index + 1))
            ;;
        esac
    done
    _argc_tools=(dd mkfs.ext4 mkfs.ext3 mkfs.ext2 fuse2fs fusermount numfmt)
    if [[ -n "${_argc_action:-}" ]]; then
        $_argc_action
    else
        argc__fn=mount
        if [[ "${argc__positionals[0]:-}" == "help" ]] && [[ "${#argc__positionals[@]}" -eq 1 ]]; then
            _argc_usage_mount
        fi
        _argc_match_positionals 0 0
        local values_index values_size
        IFS=: read -r values_index values_size <<<"${_argc_match_positionals_values[0]:-}"
        if [[ -n "$values_index" ]]; then
            argc_image_file="${argc__positionals[values_index]}"
        else
            _argc_die "error: the required environments \`<IMAGE-FILE>\` were not provided"
        fi
        IFS=: read -r values_index values_size <<<"${_argc_match_positionals_values[1]:-}"
        if [[ -n "$values_index" ]]; then
            argc_mount_point="${argc__positionals[values_index]}"
        else
            _argc_die "error: the required environments \`<MOUNT-POINT>\` were not provided"
        fi
    fi
}

_argc_usage_unmount() {
    cat <<-'EOF'
Unmount a file system image

USAGE: confuse unmount <MOUNT-POINT>

ARGS:
  <MOUNT-POINT>  Mount point for the file system image
EOF
    exit
}

_argc_parse_unmount() {
    local _argc_key _argc_action
    local _argc_subcmds=""
    while [[ $_argc_index -lt $_argc_len ]]; do
        _argc_item="${argc__args[_argc_index]}"
        _argc_key="${_argc_item%%=*}"
        case "$_argc_key" in
        --help | -help | -h)
            _argc_usage_unmount
            ;;
        --)
            _argc_dash="${#argc__positionals[@]}"
            argc__positionals+=("${argc__args[@]:$((_argc_index + 1))}")
            _argc_index=$_argc_len
            break
            ;;
        *)
            argc__positionals+=("$_argc_item")
            _argc_index=$((_argc_index + 1))
            ;;
        esac
    done
    _argc_tools=(dd mkfs.ext4 mkfs.ext3 mkfs.ext2 fuse2fs fusermount numfmt)
    if [[ -n "${_argc_action:-}" ]]; then
        $_argc_action
    else
        argc__fn=unmount
        if [[ "${argc__positionals[0]:-}" == "help" ]] && [[ "${#argc__positionals[@]}" -eq 1 ]]; then
            _argc_usage_unmount
        fi
        _argc_match_positionals 0
        local values_index values_size
        IFS=: read -r values_index values_size <<<"${_argc_match_positionals_values[0]:-}"
        if [[ -n "$values_index" ]]; then
            argc_mount_point="${argc__positionals[values_index]}"
        else
            _argc_die "error: the required environments \`<MOUNT-POINT>\` were not provided"
        fi
    fi
}

_argc_take_args() {
    _argc_take_args_values=()
    _argc_take_args_len=0
    local param="$1" min="$2" max="$3" signs="$4" delimiter="$5"
    if [[ "$min" -eq 0 ]] && [[ "$max" -eq 0 ]]; then
        return
    fi
    local _argc_take_index=$((_argc_index + 1)) _argc_take_value
    if [[ "$_argc_item" == *=* ]]; then
        _argc_take_args_values=("${_argc_item##*=}")
    else
        while [[ $_argc_take_index -lt $_argc_len ]]; do
            _argc_take_value="${argc__args[_argc_take_index]}"
            if _argc_maybe_flag_option "$signs" "$_argc_take_value"; then
                if [[ "${#_argc_take_value}" -gt 1 ]]; then
                    break
                fi
            fi
            _argc_take_args_values+=("$_argc_take_value")
            _argc_take_args_len=$((_argc_take_args_len + 1))
            if [[ "$_argc_take_args_len" -ge "$max" ]]; then
                break
            fi
            _argc_take_index=$((_argc_take_index + 1))
        done
    fi
    if [[ "${#_argc_take_args_values[@]}" -lt "$min" ]]; then
        _argc_die "error: incorrect number of values for \`$param\`"
    fi
    if [[ -n "$delimiter" ]] && [[ "${#_argc_take_args_values[@]}" -gt 0 ]]; then
        local item values arr=()
        for item in "${_argc_take_args_values[@]}"; do
            IFS="$delimiter" read -r -a values <<<"$item"
            arr+=("${values[@]}")
        done
        _argc_take_args_values=("${arr[@]}")
    fi
}

_argc_match_positionals() {
    _argc_match_positionals_values=()
    _argc_match_positionals_len=0
    local params=("$@")
    local args_len="${#argc__positionals[@]}"
    if [[ $args_len -eq 0 ]]; then
        return
    fi
    local params_len=$# arg_index=0 param_index=0
    while [[ $param_index -lt $params_len && $arg_index -lt $args_len ]]; do
        local takes=0
        if [[ "${params[param_index]}" -eq 1 ]]; then
            if [[ $param_index -eq 0 ]] &&
                [[ ${_argc_dash:-} -gt 0 ]] &&
                [[ $params_len -eq 2 ]] &&
                [[ "${params[$((param_index + 1))]}" -eq 1 ]] \
                ; then
                takes=${_argc_dash:-}
            else
                local arg_diff=$((args_len - arg_index)) param_diff=$((params_len - param_index))
                if [[ $arg_diff -gt $param_diff ]]; then
                    takes=$((arg_diff - param_diff + 1))
                else
                    takes=1
                fi
            fi
        else
            takes=1
        fi
        _argc_match_positionals_values+=("$arg_index:$takes")
        arg_index=$((arg_index + takes))
        param_index=$((param_index + 1))
    done
    if [[ $arg_index -lt $args_len ]]; then
        _argc_match_positionals_values+=("$arg_index:$((args_len - arg_index))")
    fi
    _argc_match_positionals_len=${#_argc_match_positionals_values[@]}
    if [[ $params_len -gt 0 ]] && [[ $_argc_match_positionals_len -gt $params_len ]]; then
        local index="${_argc_match_positionals_values[params_len]%%:*}"
        _argc_die "error: unexpected argument \`${argc__positionals[index]}\` found"
    fi
}

_argc_validate_choices() {
    local render_name="$1" raw_choices="$2" choices item choice concated_choices=""
    while IFS= read -r line; do
        choices+=("$line")
    done <<<"$raw_choices"
    for choice in "${choices[@]}"; do
        if [[ -z "$concated_choices" ]]; then
            concated_choices="$choice"
        else
            concated_choices="$concated_choices, $choice"
        fi
    done
    for item in "${@:3}"; do
        local pass=0 choice
        for choice in "${choices[@]}"; do
            if [[ "$item" == "$choice" ]]; then
                pass=1
            fi
        done
        if [[ $pass -ne 1 ]]; then
            _argc_die "error: invalid value \`$item\` for $render_name"$'\n'"  [possible values: $concated_choices]"
        fi
    done
}

_argc_maybe_flag_option() {
    local signs="$1" arg="$2"
    if [[ -z "$signs" ]]; then
        return 1
    fi
    local cond=false
    if [[ "$signs" == *"+"* ]]; then
        if [[ "$arg" =~ ^\+[^+].* ]]; then
            cond=true
        fi
    elif [[ "$arg" == -* ]]; then
        if (( ${#arg} < 3 )) || [[ ! "$arg" =~ ^---.* ]]; then
            cond=true
        fi
    fi
    if [[ "$cond" == "false" ]]; then
        return 1
    fi
    local value="${arg%%=*}"
    if [[ "$value" =~ [[:space:]] ]]; then
        return 1
    fi
    return 0
}

_argc_require_tools() {
    local tool missing_tools=()
    for tool in "$@"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    if [[ "${#missing_tools[@]}" -gt 0 ]]; then
        echo "error: missing tools: ${missing_tools[*]}" >&2
        exit 1
    fi
}

_argc_die() {
    if [[ $# -eq 0 ]]; then
        cat
    else
        echo "$*" >&2
    fi
    exit 1
}

_argc_run "$@"

# ARGC-BUILD }
