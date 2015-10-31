#!/bin/bash
redis-server --daemonize yes

if [ $? -ne 0 ] ; then
  exit 1
fi

redis-cli config set save "" > /dev/null

if [ $? -ne 0 ] ; then
  exit 1
fi

redis-benchmark -r 1000000 -n 2000000 -t get,set,lpush,lpop -q --csv > output

if [ $? -ne 0 ] ; then
  exit 1
fi

echo "{"
echo `sed -n 's/"\(SET\)",\(.*\)/{ "redis-\L\1": { "result": \2 } },/p' output`
echo `sed -n 's/"\(GET\)",\(.*\)/{ "redis-\L\1": { "result": \2 } },/p' output`
echo `sed -n 's/"\(LPUSH\)",\(.*\)/{ "redis-\L\1": { "result": \2 } },/p' output`
echo `sed -n 's/"\(LPOP\)",\(.*\)/{ "redis-\L\1": { "result": \2 } }/p' output`
echo "}"
