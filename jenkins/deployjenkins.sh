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
