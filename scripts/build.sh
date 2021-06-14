BASEDIR=$(dirname "$0")

echo "Installing .NET Core 2.1 SDK..."
wget -q https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh
chmod +x ./dotnet-install.sh > /dev/null 2>&1 # Install .NET quitely
./dotnet-install.sh -Channel 2.1

echo "Installing Wyam..."
wget -q https://github.com/Wyamio/Wyam/releases/download/v2.2.9/Wyam-v2.2.9.zip
unzip -q Wyam-v2.2.9.zip -d wyam

echo "Builiding website..."
dotnet ./wyam/Wyam.dll --output $BASEDIR/../docs
