BASEDIR=$(dirname "$0")

wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh -Channel 2.1

wget https://github.com/Wyamio/Wyam/releases/download/v2.2.9/Wyam-v2.2.9.zip
unzip Wyam-v2.2.9.zip -d wyam

dotnet ./wyam/Wyam.dll --output $BASEDIR/../docs
