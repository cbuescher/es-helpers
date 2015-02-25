from datetime import datetime
from elasticsearch import Elasticsearch
import random
import time

def strTimeProp(start, end, format, prop):
    """Get a time at a proportion of a range of two formatted times.

    start and end should be strings specifying times formated in the
    given format (strftime-style), giving an interval [start, end].
    prop specifies how a proportion of the interval to be taken after
    start.  The returned time will be in the specified format.
    """

    stime = time.mktime(time.strptime(start, format))
    etime = time.mktime(time.strptime(end, format))

    ptime = stime + prop * (etime - stime)

    return time.strftime('%Y-%m-%dT%H:%M:%S', time.localtime(ptime))


def randomDate(start, end, prop):
    return strTimeProp(start, end, '%m/%d/%Y %I:%M %p', prop)

es = Elasticsearch()
es.indices.create(index='test-dates', ignore=400)


for i in range(0,10000):
    r_date = randomDate("01/01/2015 12:00 PM", "02/15/2015 12:00 PM", random.random())
    print(r_date)
    res = es.index(index="test-date", doc_type="date_doc", body={"field": "dadaismus", "timestamp": r_date})
    print(res)
