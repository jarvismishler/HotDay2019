#/bin/bash

# Install OpenJDK
apt-get update

echo "Checking to see if openjdk-8-jre-headless is installed and install if not."
sleep 1s
echo "."
sleep 1s
echo "."
sleep 1s
echo "."

if [ $(dpkg-query -W -f='${Status}' openjdk-8-jre-headless 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  sleep 1s
  echo "."
  echo "Installing openjdk-8-jre-headless"
  apt-get install openjdk-8-jre-headless -y;
fi

sleep 1s
echo "."
sleep 1s
echo "."
sleep 1s
echo "."

# Install Docker if not Installed
echo "Checking to see if docker.io is installed and install if not."
sleep 1s
echo "."
sleep 1s
echo "."
sleep 1s
echo "."

if [ $(dpkg-query -W -f='${Status}' docker.io 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  sleep 1s
  echo "."
  echo "Installing docker.io"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  apt-cache policy docker-ce
  sudo apt-get install -y docker-ce
  docker swarm init
fi

sleep 1s
echo "."
sleep 1s
echo "."
sleep 1s
echo "."

# Install Jenkins as Docker
echo "admin" | docker secret create jenkins-user -
echo "admin" | docker secret create jenkins-pass -
docker stack deploy -c jenkins.yml jenkins

# Deploy elasticsearch-kibana as Docker Image
#docker pull nshou/elasticsearch-kibana
#docker run -d -p 9091:9200 -p 9094:5601 nshou/elasticsearch-kibana
# run Basic Auth Elasticsearch(user: 'elastic', pw 'secret') daemon
# in auto-remove mode, start takes 20+ seconds
docker pull docker.elastic.co/elasticsearch/elasticsearch:6.5.4
docker pull docker.elastic.co/kibana/kibana:6.5.4

docker run -d --rm -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e "transport.host=127.0.0.1" -e ELASTIC_PASSWORD=secret --name elastic docker.elastic.co/elasticsearch/elasticsearch:6.5.4 && sleep 20

# run Kibana daemon in auto-remove mode
# start takes 20+ seconds
docker run -d --rm --link elastic:elastic-url -e "ELASTICSEARCH_URL=http://elastic-url:9200" -e ELASTICSEARCH_PASSWORD="secret"  -p 5601:5601 --name kibana docker.elastic.co/kibana/kibana:6.5.4 && sleep 20

# check connection to Elasticsearch (JSON is returned)
#curl "http://localhost:9200/_count" -u 'elastic:secret'

# check connection to Kibana (HTML is returned)
#curl http://localhost:5601 --location
