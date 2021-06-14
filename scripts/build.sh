BASEDIR=$(dirname "$0")

wget https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb

apt-get update; \
apt-get install -y apt-transport-https && \
apt-get update && \
apt-get install -y dotnet-sdk-2.1

dotnet tool install -g Wyam.Tool
~/.dotnet/tools/wyam --output $BASEDIR/../docs

rm packages-microsoft-prod.deb