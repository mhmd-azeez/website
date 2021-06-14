BASEDIR=$(dirname "$0")

wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh -Channel 2.1

dotnet tool install -g Wyam.Tool
wyam --output $BASEDIR/../docs
