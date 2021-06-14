BASEDIR=$(dirname "$0")

echo "Installing .NET Core 2.1 SDK..."
wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -q
chmod +x ./dotnet-install.sh
./dotnet-install.sh -Channel 2.1

echo "Installing Wyam..."
wget https://github.com/Wyamio/Wyam/releases/download/v2.2.9/Wyam-v2.2.9.zip  -q
unzip Wyam-v2.2.9.zip -d wyam -q

echo "Builiding website..."
dotnet ./wyam/Wyam.dll --output $BASEDIR/../docs
