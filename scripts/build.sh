BASEDIR=$(dirname "$0")

echo "Installing .NET Core 8.0 SDK..."
wget -q https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh -Channel 8.0 > /dev/null 2>&1 # Install .NET quitely

echo "Installing Wyam..."
wget -q https://github.com/Wyamio/Wyam/releases/download/v2.2.9/Wyam-v2.2.9.zip
unzip -q Wyam-v2.2.9.zip -d wyam

mkdir -p $BASEDIR/../docs

echo "Builiding website..."
dotnet ./wyam/Wyam.dll --output $BASEDIR/../docs

echo "Done :)"

ls -la $BASEDIR/../docs
