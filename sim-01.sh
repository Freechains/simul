#!/bin/sh

# tst-01: N=21, TOTAL=1*h,    15s, 50/5b, 250ms
# tst-02: N=21, TOTAL=10*min, 15s, 50/5b, 250ms

for i in *;
do
    echo === $i ===
    find $i | wc
done
    # 216 216 20265

du -sh 8401/
    # 888K

find 8401 -name "*.blk" | xargs jq -r .pay | wc
    # 210 836 13507

echo "1350700/888" | bc
    # 15.21%

cd 8401/
ls | sed 's/_.*//' | uniq -c | sort -rn
    # 10 96
    #  6 97
    #  5 48

cd chains/chat/blocks/
/data/freechains/simul/ana-01.lua *.blk | sort -rn
    # 69	97_C9ECD9216242DE31B3FFF213EB46982035870EC0C27AC6FDBBDA71F4F43A6E2C.blk
    # 38	86_FB3217D3EBAAA75FF5342567012BCE4993FC574543CF09AB83E6E4901B6B78F8.blk
    # 25	94_75EB656946826543BC01F1F1AE33C7F9AACC4220D0B1161624746830CAD5F900.blk
    # 21	69_A292DE462D1747EE1A9CE504496A68094BF37EC73DEEF5949604A6D26748E845.blk

# 10 highest delta diffs immut.time/local
find . -name "*.blk" -exec /data/freechains/simul/ana-01-time.lua {} \; | sort -n | tail -n 50
