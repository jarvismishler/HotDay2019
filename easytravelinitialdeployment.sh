#!/bin/bash

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

# Lets make sure EasyTravel and supporting stuff doesn't exist
if [ -d "/opt/easytravel-2.0.0-x64" ]; then
        echo "EasyTravel found... removing directory..."
        pkill -f CommandlineLauncher
        sleep 20s
        rm -fr /opt/easytravel-2.0.0-x64
fi

if [ -f "/var/spool/cron/crontabs/root" ]
then
        echo "root crontab found... removing..."
        rm /var/spool/cron/crontabs/root
        update-rc.d cron defaults
fi

if [ -f "/opt/dynatrace-easytravel-linux-x86_64.jar" ]
then
        echo "EasyTravel install file found... removing..."
        rm /opt/dynatrace-easytravel-linux-x86_64.jar
fi

# Download and install Easytravel
cd /opt
wget http://dexya6d9gs5s.cloudfront.net/latest/dynatrace-easytravel-linux-x86_64.jar
java -jar dynatrace-easytravel-linux-x86_64.jar -y

#Configure easytravel to work with Dynatrace and configure BackEnd Ports
cd /opt/easytravel-2.0.0-x64/resources
sed -i 's/apmServerDefault=Classic/apmServerDefault=APM/' easyTravelConfig.properties
sed -i 's/config.apacheWebServerBackendPort=8091/config.apacheWebServerBackendPort=8094/' easyTravelConfig.properties
sed -i 's/config.backendPort=8091/config.backendPort=8094/' easyTravelConfig.properties
sed -i 's/config.apacheWebServerEnvArgs=/config.apacheWebServerEnvArgs=DT_CUSTOM_PROP=Application=EasyTravel TIER=ApacheFrontend/' easyTravelConfig.properties
sed -i 's/config.creditCardAuthorizationEnvArgs=DT_WAIT=5,RUXIT_WAIT=5/config.creditCardAuthorizationEnvArgs=DT_WAIT=5,RUXIT_WAIT=5,DT_CUSTOM_PROP=Application=EasyTravel TIER=CCAuth/' easyTravelConfig.properties
sed -i 's/config.paymentBackendEnvArgs=DT_WAIT=5,RUXIT_WAIT=5,COR_ENABLE_PROFILING=0x1/config.paymentBackendEnvArgs=DT_WAIT=5,RUXIT_WAIT=5,COR_ENABLE_PROFILING=0x1,DT_CUSTOM_PROP=Application=EasyTravel TIER=paymentBackend/' easyTravelConfig.properties
sed -i 's/config.b2bFrontendEnvArgs=DT_WAIT=5,RUXIT_WAIT=5,COR_ENABLE_PROFILING=0x1/config.b2bFrontendEnvArgs=DT_WAIT=5,RUXIT_WAIT=5,COR_ENABLE_PROFILING=0x1,DT_CUSTOM_PROP=Application=EasyTravel TIER=b2bFrontend/' easyTravelConfig.properties
sed -i 's/config.frontendJavaopts=-Xmx160m/config.frontendJavaopts=-Xmx160m-DT_CUSTOM_PROP=Application=EasyTravel TIER=CustomerFrontend/' easyTravelConfig.properties
sed -i 's/config.backendJavaopts=-Xmx64m,-DentityExpansionLimit=500000/config.backendJavaopts=-Xmx64m,-DentityExpansionLimit=500000-DT_CUSTOM_PROP=Application=EasyTravel TIER=BusinessBackend/' easyTravelConfig.properties
sed -i 's/config.thirdpartyJavaopts=-Xmx32m/config.thirdpartyJavaopts=-Xmx32m-DT_CUSTOM_PROP=Application=EasyTravel TIER=ThirdParty/' easyTravelConfig.properties

#Add a 1 minute to the startup of EasyTravel
cd /opt/easytravel-2.0.0-x64
sed -i '6a sleep 1m' runEasyTravelNoGUI.sh

#Modigy crontab to start EasyTravel at boot
(crontab -l ; echo "@reboot nohup /opt/easytravel-2.0.0-x64/runEasyTravelNoGUI.sh") | crontab -
update-rc.d cron defaults

#Create stopEasyTravelScript
cd /opt/easytravel-2.0.0-x64
touch stopEasyTravel.sh
chmod 755 stopEasyTravel.sh
echo '#/bin/bash' >> stopEasyTravel.sh
echo 'pkill -f CommandlineLauncher' >> stopEasyTravel.sh

#Initiate a reboot
echo "Rebooting the server in 5 seconds"
echo "5"
sleep 1s
echo "4"
sleep 1s
echo "3"
sleep 1s
echo "2"
sleep 1s
echo "1"
sleep 1s
reboot
