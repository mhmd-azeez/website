BASEDIR=$(dirname "$0")

wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh install.sh
chmod +x install.sh
install.sh

dotnet tool install -g Wyam.Tool
~/.dotnet/tools/wyam --output $BASEDIR/../docs
