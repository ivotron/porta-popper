#!/bin/bash
echo "["

cd /IRSmk_v1.0/
./irsmk > output
result=`sed -n 's/Wall time = \(.*\) seconds./\1/p' output`
echo "{\"name\": \"irsmk\", \"class\": \"cpu\", \"result\": $result},"

cd /CrystalMk_v1.0/
./crystalmk > output
result=`sed -n 's/Total Wall time = \(.*\) seconds./\1/p' output`
echo "{\"name\": \"crystalmk\", \"class\": \"cpu\", \"result\": $result},"

cd /AMGmk_v1.0/
./amgmk > output
result=`sed '41q;d' output | sed -n 's/Total Wall time = \(.*\) seconds.*/\1/p'`
echo "{\"name\": \"amgmk\", \"class\": \"cpu\", \"result\": $result}"

echo "]"
