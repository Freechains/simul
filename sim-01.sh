#!/bin/sh

# tst-01: N=21, TOTAL=1*h,    15s, 50/5b, 250ms     (I7)
# tst-02: N=21, TOTAL=10*min, 15s, 50/5b, 250ms     (I7)
    # TOTAL	2030
# tst-03: N=21, TOTAL=10*min, 15s, 50/5b, 250ms     (I7)
    # TOTAL	2069
# tst-04: N=21, TOTAL=10*min, 15s, 50/5b,  20ms     (I7)
    # TOTAL	1922
# tst-05: N=21, TOTAL=10*min, 15s, 50/5b,  20ms     (I5)
    # TOTAL	 926
# tst-06: N=21, TOTAL=10*min, 15s, 50/5b,   0ms
# tst-07: N=21, TOTAL=10*min, 15s, 50/5b,  20ms     (I5)

for i in *;
do
    echo === $i ===
    find $i | wc
done
    # 216 216 20265
    # 142 142 13099
    # 144 144 13301     (not sync!)
    # 138 138 12730     (not sync!)
    # 154 154 14261

du -sh 8401/
    # 888K
    # 584K
    # 592K
    # 568K
    # 632K

find 8401 -name "*.blk" | xargs jq -r .pay | wc
    # 210 836 13507
    # 136 375  2143
    # 138 398  2373
    # 132 320  1716
    # 148 366  2153

echo "215300/632" | bc
    # 15.21%
    #  3.66%
    #  4.00%
    #  3.02%
    #  3.40%

# total of blocks with same height
cd 8401/chains/chat/blocks
ls | sed 's/_.*//' | uniq -c | sort -rn
    # 10,6,5
    #  9,7,7
    #  9,7,6
    #  7,6,6
    #  7,5,5

# max height delta between height and backs
/data/freechains/simul/ana-01-height.lua *.blk | sort -n
    # 69,38,25,21
    # 17,16,14,13
    # 14,14,14,14
    # 11, 9, 9, 8
    # 27,13,13,13

# 10 highest delta diffs immut.time/local
cd <tst-xx>/
find . -name "*.blk" -exec /data/freechains/simul/ana-01-time.lua {} \; | grep -v blocks/0_ | sort -n | tail -n 50
    # 13x15, 11x15, 10x10
    # 13x15, 11x15,  8x10
    #  8x40
    # 33x15, 18x15, 13x10
    # 17x30, 16x10
