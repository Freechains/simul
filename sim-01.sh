#!/bin/sh

DIR=/data/freechains/simul/
CHAIN=$1
OTHER=$2
BASE=8400

echo
echo ">>> Total space:"
echo
du -sh $BASE/ --exclude $2

echo
echo ">>> Number of messages:"
echo
echo "host    blks"
for i in 84*;
do
    echo -n "$i    "
    find $i -name "*.blk" | grep $CHAIN | wc -l
done | sort -rn -k2 # | uniq -c

echo
echo "TODO: use first line as BASE"
echo "TODO: ratio payload overhead"
echo
#echo "154400/196" | bc

echo
echo ">>> Max time deltas between immut vs local:"
echo
echo "    qtt dt"
find . -name "*.blk" -exec $DIR/ana-01-time.lua {} \; | grep -v blocks/0_ | sort -rn | cut -f 1 | uniq -c

echo
echo ">>> Min/Max heads heights:"
echo
echo "    qtt   height"
find . -name "chain" -exec jq .heads {} \; | grep -v "\[" | grep -v "\]" | sed 's/"//' | sed 's/_.*//' | sort -n | uniq -c

cd $BASE/chains/$CHAIN/blocks

echo
echo ">>> Blocks with same height:"
echo
echo "    qtt height"
ls | sed 's/_.*//' | uniq -c | sort -rn

echo
echo ">>> Max height deltas between block vs backs:"
echo
echo "    qtt dh"
$DIR/ana-01-height.lua *.blk | sort -rn | cut -f 1 | uniq -c
