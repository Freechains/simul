#!/bin/sh

DIR=/data/freechains/simul/

echo
echo ">>> Check if all the same..."
echo
for i in *;
do
    find $i | wc
done

echo
echo ">>> Total space:"
echo
du -sh 8401/

echo
echo ">>> Number of messages:"
echo
find 8401 -name "*.blk" | xargs jq -r .pay | wc

#echo "154400/196" | bc

echo
echo ">>> Blocks with same height:"
echo
cd 8401/chains/chat/blocks
ls | sed 's/_.*//' | uniq -c | sort -rn | head -n 5

echo
echo ">>> Max height deltas between block vs backs:"
echo
$DIR/ana-01-height.lua *.blk | sort -rn | cut -f 1 | uniq -c | head -n 5

echo
echo ">>> Max time deltas between immut vs local:"
echo
cd -
find . -name "*.blk" -exec $DIR/ana-01-time.lua {} \; | grep -v blocks/0_ | sort -rn | cut -f 1 | uniq -c | head -n 5
