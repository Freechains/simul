#!/bin/sh

DIR=/data/freechains/simul/

# tst-10 // I5 // sim-01
# TOTAL	281
# PARAMS	21	300	15	50	5	20

# tst-11 // I5 // sim-01
# TOTAL	581
# PARAMS	21	600	15	50	5	20

# tst-12 // I5 // sim-01
# TOTAL	668
# PARAMS	21	600	15	50	5	250

# tst-13 // I5 // sim-01
# TOTAL	708
# PARAMS	21	600	15	50	5	250

echo
echo ">>> Check if all the same..."
echo
for i in *;
do
    echo === $i ===
    find $i | wc
done
    # 27      27    2097
    # 26      26    2000
    # 49      49    4208
    # 44      44    3725
    # 46      46    3921

echo
echo ">>> Total space:"
echo
du -sh 8401/
    # 108K
    # 104K
    # 196K
    # 176K
    # 184K

echo
echo ">>> Number of messages:"
echo
find 8401 -name "*.blk" | xargs jq -r .pay | wc
    # 21      65     986
    # 20      40     397
    # 43     114    1544
    # 38     100    1596
    # 40      87    1169

#echo "154400/196" | bc
    #  9.12%
    #  3.81%
    #  9.06%
    #  9.06%
    #  6.35%

echo
echo ">>> Blocks with same height:"
echo
cd 8401/chains/chat/blocks
ls | sed 's/_.*//' | uniq -c | sort -rn | head -n 5
    #  2,1,1
    #  2,1,1
    #  3,3,2
    #  4,3,2
    #  3,3,2

echo
echo ">>> Max height deltas between block vs backs:"
echo
$DIR/ana-01-height.lua *.blk | sort -rn | cut -f 1 | uniq -c | head -n 5
    # 1,1,1,1
    # 1,1,1,1
    # 3,2,1,1
    # 10,5,5,4
    # 4,2,2,2

echo
echo ">>> Max time deltas between immut vs local:"
echo
cd -
find . -name "*.blk" -exec $DIR/ana-01-time.lua {} \; | grep -v blocks/0_ | sort -rn | cut -f 1 | uniq -c | head -n 5
    # 20x 13, 20x 1
    # 20x 3, 20x 1
    # 40x 1
    # 15x 8, 15x 3, 10x 2
    # 15x 4, 15x 3, 10x 2
