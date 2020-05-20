#!/bin/sh

DIR=/data/freechains/simul/
CHAIN=insta

echo
echo ">>> Check if all the same..."
echo
echo "    qtt      *.blks"
for i in 84*;
do
    find $i -name "*.blk" | wc
done | sort -n | uniq -c

echo
echo ">>> Total space:"
echo
du -sh 8400/

echo
echo ">>> Number of messages:"
echo
echo "   msgs"
find 8400 -name "*.blk" | xargs jq -r .pay | wc

#echo "154400/196" | bc

echo
echo ">>> Blocks with same height:"
echo
echo "    qtt height"
cd 8400/chains/$CHAIN/blocks
ls | sed 's/_.*//' | uniq -c | sort -rn | head -n 5

echo
echo ">>> Max height deltas between block vs backs:"
echo
echo "    qtt dh"
$DIR/ana-01-height.lua *.blk | sort -rn | cut -f 1 | uniq -c | head -n 5

echo
echo ">>> Max time deltas between immut vs local:"
echo
echo "    qtt dt"
cd -
find . -name "*.blk" -exec $DIR/ana-01-time.lua {} \; | grep -v blocks/0_ | sort -rn | cut -f 1 | uniq -c | head -n 5

echo
echo ">>> Min/Max heads heights:"
echo
echo "    qtt   height"
find . -name "chain" -exec jq .heads {} \; | grep -v "\[" | grep -v "\]" | sed 's/"//' | sed 's/_.*//' | sort -n | uniq -c
