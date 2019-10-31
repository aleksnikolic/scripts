#!/bin/bash

function suptime() {
    local addr=${1:?Specify the remote IPv4 address}
    local port=${2:?Specify the remote port number}

    # convert the provided address to hex format
    local hex_addr=$(python -c "import socket, struct; print(hex(struct.unpack('<L', socket.inet_aton('$addr'))[0])[2:10].upper().zfill(8))")
    local hex_port=$(python -c "print(hex($port)[2:].upper().zfill(4))")

    # get the inode of the socket
    local inodes=$(awk '$4 == "01" && $3 == "'$hex_addr:$hex_port'" {print $10}' /proc/net/tcp)
    [ -z "$inodes" ] && { echo 'Cannot lookup the socket(s)' 2>&1; return 1; }

    # get file descriptors
    for inode in $inodes; do
        # get inode's file descriptor details
        local fdinfo=( $(find /proc/[0-9]*/fd -lname "socket:\[$inode\]" -printf "%p %T@") )
        [ -z "$fdinfo" ] && { echo 'Cannot find file descriptor' 2>&1; return 1; }

        # extract pid
        local fdpath=${fdinfo[0]}
        local pid=${fdpath#/proc/}
        pid=${pid%%/*}

        # extract timestamp
        local timestamp=${fdinfo[1]}

        # compute the time difference
        LANG=C printf 'PID: %s; Age: %s (%.2fs ago)\n' "$pid" "$(date -d @$timestamp)" $(bc <<<"$(date +%s.%N) - $timestamp")
    done
}

suptime $1 $2
