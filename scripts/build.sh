BASEDIR=$(dirname "$0")

wget https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

sudo apt-get update; \
sudo apt-get install -y apt-transport-https && \
sudo apt-get update && \
sudo apt-get install -y dotnet-sdk-2.1

dotnet tool install -g Wyam.Tool
~/.dotnet/tools/wyam --output $BASEDIR/../docs

rm packages-microsoft-prod.deb
