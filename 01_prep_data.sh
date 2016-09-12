#! /bin/bash

for i in $(seq 1 100)
do
  i_with_prefix_zero="key"$(echo $i |awk '{printf("%04d\n",$0)}')
  redis-cli -c hmset "04:"$i_with_prefix_zero h1 1 h2 2 h0001 1 h0002 2 > /dev/null
done
