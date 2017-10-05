#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo 'please specify version to install'
    exit 1
fi
VERSION=$1
if [ ! -f elasticsearch-$VERSION.tar.gz ]; then
    url=https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$VERSION.tar.gz
    if curl --output /dev/null --silent --head --fail "$url"; then
	curl -O "$url"
    else
	echo "URL does not exist: $url"
    fi
fi
if [ ! -f kibana-$VERSION-darwin-x86_64.tar.gz ]; then
    url=https://artifacts.elastic.co/downloads/kibana/kibana-$VERSION-darwin-x86_64.tar.gz
    if curl --output /dev/null --silent --head --fail "$url"; then
	curl -O "$url"
    else
	echo "URL does not exist: $url"
    fi
fi
tar xfvz elasticsearch-$VERSION.tar.gz
tar xfvz kibana-$VERSION-darwin-x86_64.tar.gz

# -------- install x-pack

elasticsearch-$VERSION/bin/elasticsearch-plugin install -b x-pack
kibana-$VERSION-darwin-x86_64/bin/kibana-plugin install x-pack

# -------- disable x-pack feature by default

cat >> elasticsearch-$VERSION/config/elasticsearch.yml <<END

# ---- disable all x-pack by default

xpack.graph.enabled: false
xpack.monitoring.enabled: true
xpack.security.enabled: false
xpack.ml.enabled: false
xpack.watcher.enabled: false

# ---- set repo path

path.repo: ["/opt/es_snapshot_repo"]
END

# -------- import example data
elasticsearch-$VERSION/bin/elasticsearch -p es.pid -d

echo "Starting elasticsearch to import snapshot repos"
while ! nc -z localhost 9200; do      sleep 0.1; done
echo "Started elasticsearch, pid: `cat es.pid`"

curl -XGET 'http://localhost:9200/_cluster/health?wait_for_status=yellow&timeout=10s&pretty'

curl -XPUT "http://localhost:9200/_snapshot/es_snapshot_repo" -H 'Content-Type:application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/opt/es_snapshot_repo",
        "compress": true
  }
}'

curl -XPOST "http://localhost:9200/_snapshot/es_snapshot_repo/logstash-example/_restore"

kill -SIGTERM `cat es.pid`
