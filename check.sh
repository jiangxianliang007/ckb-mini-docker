#!/bin/bash
set -e

touch /dev/shm/best_block.status

exec 5<> /dev/tcp/127.0.0.1/8114
printf 'POST / HTTP/1.1\r\nConnection: close\r\ncontent-type: application/json\r\ncontent-length: 68\r\n\r\n{"jsonrpc":"2.0","method":"get_tip_block_number","params":[],"id":2}' >&5

result=$(cat <&5)
best_block=$(echo $result | cut -d'"' -f8 | xargs printf %d)
old_best_block=$(cat /dev/shm/best_block.status)
[[ $old_best_block == $best_block ]] && exit 1

echo $best_block > /dev/shm/best_block.status
