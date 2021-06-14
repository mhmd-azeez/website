BASEDIR=$(dirname "$0")

wget https://download.visualstudio.microsoft.com/download/pr/66483281-5453-4504-9686-f72d1fd357f7/0de98386ca1709bde2b5f2f7df4c80da/aspnetcore-runtime-2.1.28-linux-x64.tar.gz dotnet

dotnet tool install -g Wyam.Tool
~/.dotnet/tools/wyam --output $BASEDIR/../docs

rm packages-microsoft-prod.deb
