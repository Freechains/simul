#!/bin/sh

# tst-01: N=21, TOTAL=1*h,    15s, 50/5b, 250ms
# tst-02: N=21, TOTAL=10*min, 15s, 50/5b, 250ms
    # TOTAL	2030
# tst-03: N=21, TOTAL=10*min, 15s, 50/5b, 250ms
    # TOTAL	2069
# tst-04: N=21, TOTAL=10*min, 15s, 50/5b, 20ms

for i in *;
do
    echo === $i ===
    find $i | wc
done
    # 216 216 20265
    # 142 142 13099
    # 144 144 13301     (not sync!)

du -sh 8401/
    # 888K
    # 584K
    # 592K

find 8401 -name "*.blk" | xargs jq -r .pay | wc
    # 210 836 13507
    # 136 375  2143
    # 138 398  2373

echo "1350700/888" | bc
    # 15.21%
    #  3.66%
    #  4.00%

# total of blocks with same height
cd 8401/chains/chat/blocks
ls | sed 's/_.*//' | uniq -c | sort -rn
    # 10,6,5
    #  9,7,7
    #  9,7,6

# max height delta between height and backs
/data/freechains/simul/ana-01-height.lua *.blk | sort -n
    # 69,38,25,21
    # 17,16,14,13
    # 14,14,14,14

# 10 highest delta diffs immut.time/local
cd <tst-xx>/
find . -name "*.blk" -exec /data/freechains/simul/ana-01-time.lua {} \; | grep -v blocks/0_ | sort -n | tail -n 50
    # 13x10, 11x10, 10x10
    # 13x10, 11x10, 8x10
    #  8x30
