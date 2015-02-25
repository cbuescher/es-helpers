#!/bin/bash

for i in {1..10}
do
   DAY_OFFSET=`jot -r 1 0 30`
   HOUR_OFFSET=`jot -r 1 0 24`
   MONTH_OFFSET=`jot -r 1 0 12`

   DATE=`date -v-${DAY_OFFSET}d -v-${HOUR_OFFSET}H -v-${MONTH_OFFSET}m +%Y-%m-%dT%H:%M:%S`
   echo $DATE
   curl -s -XPOST localhost:9200/dates/docs/ -d '{"date": "'$DATE'"}'
done
