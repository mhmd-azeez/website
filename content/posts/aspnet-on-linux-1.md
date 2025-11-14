---
title: "Running ASP.NET Core on Linux Part 1"
date: 2020-04-07
slug: "aspnet-on-linux-1"
tags: ["aspnet", "linux"]
---
In the last couple of weeks, I have been busy setting up a CI/CD pipeline for one of my side projects and getting it to run on Linux. I'll try to write about what I have learned in the process.

This will be a series of blog posts because I don't want it to become too long. This is the first part. We will create a new ASP.NET Core application and manually run it on Linux and configure Nginx and systemd.

------

Before anything lets create a new ASP.NET Core Razor Pages web application by running:

```
dotnet new webapp
```

Good, now add it to a git repository and upload it to GitHub, it will be useful for us in the next part of the series.

## Setting up VSCode

VSCode is great for accessing remote Linux servers. It allows you to open multiple terminals and edit files and allows you to download and upload them too. Follow these steps to set it up:

1. Install the [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension to be able to login into the server and be able to run commands and edit files.
2. In *Remote Explorer* tab add a new SSH Target for your server and inter username and IP address and follow the instructions. After you added the server to *Remote Explorer* connect to it and in *Explorer* tab open the `/` directory.

6. Download and install the ASP.NET Core runtime on the server. You can find instructions [here](https://dotnet.microsoft.com/download/dotnet-core).

## Publishing the website

Before doing anything we have to publish the website first. We will automate this process later but for now, we will do it manually.

```
dotnet publish -c Release
```

> Note: This will publish the web app in Framework dependent (Meaning that ASP.NET Core runtime has to be installed on the server) and cross-platform (Meaning that it can work on any operating system) mode. You might need to publish it for a specific platform if you're using native libraries or one of your *Nuget* packages uses them by using the [`--runtime` switch](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-publish).

Compress the contents of `bin\Release\netcoreapp3.1\publish\`  folder (and rename it to publish.zip) and upload it to `/home/www/sample` folder by dragging it into Explorer tab of VSCode.

Run these commands to unzip and delete the zip file:

```
cd /home/www/sample
unzip publish.zip
rm publish.zip
```

Okay, now that all of the necessary files are on the server, you can now test if the app actually works:

```
dotnet AspNetOnLinux.dll --urls=http://localhost:9999
```

If everything is set up correctly and port `9999` is not being used by any other processes, kestrel must be up and running now. 

- If there were an exception like `System.IO.IOException: Failed to bind to address http://127.0.0.1:9999: address already in use.` Then change the port to something else. 
- If There was an error like `Command 'dotnet' not found` Then it means that ASP.NET Core runtime has not been installed properly. Install them and try again.

Now that we have confirmed that everything works press next we need to configure Nginx as a reverse proxy, i.e. it listens for an external port on an IP address or domain name and re-routes it to kestrel.

## Configuring Nginx

Keep kestrel running and open **a new** terminal in VSCode and run:

```
code /etc/nginx/sites-available/default
```

This will open Nginx default configurations in VSCode. 

```
server {
    listen        IP_ADDRESS;
    server_name   HOST_NAME;
    location / {
        proxy_pass         KESTREL_URL;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
```

Copy the above snippet to the configuration file and make these adjustments:

1. Instead of `IP_ADDRESS` write the external ip address to which you want Nginx to listen. Example: `8080`. If `HOST_NAME` is a domain name you might want to use port `80`.
2. Instead of `HOST_NAME` write the domain name or IP address you want Nginx to listen to. If you've rented a VM they usually give you a static public IP that you can use for this. or if you want to use a domain name, you need to configure its DNS settings so that it points to your server's public IP address.
3. Instead of `KESTREL_URL` write the URL you have kestrel listening to. Example: `http://localhost:9999`

Save the file and run this command for Nginx to reload the configuration file:

```
# Validate configuration file
nginx -t
# Reload configuration file
nginx -s reload
```

Now in a browser go to `http://HOST_NAME:IP_ADDRESS/` and it should show our web app running 😊

For more information on configuration Nginx go to [Microsoft docs](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/linux-nginx?view=aspnetcore-3.1).

## Setting up systemd

Everything seems to be working now. But if you close the ssh session our website will no longer be running and Nginx will return `ERROR 502: Bad Gateway` if you visited the website. To make sure the website will always be running and will be restarted if it crashes we can use `systemd`.

Go back to the terminal that's running kestrel and press CTRL+C to stop it. And then run these commands:

```
code /etc/systemd/system/sample.service
```

This will open up a blank file in VSCode. Write this configuration in the file:

```
[Unit]
Description=Sample ASP.NET Core application

[Service]
WorkingDirectory=/home/www/sample
ExecStart=/usr/bin/dotnet /home/www/sample/sample.dll --urls=http://localhost:9999
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnet-ec
User=root
# You can put your environment variables here:
Environment=ASPNETCORE_ENVIRONMENT=Production

[Install]
WantedBy=multi-user.target
```

Save it and then run these commands:

```
# Reload systemd configuration
systemctl daemon-reload

systemctl enable sample
systemctl start sample
```

You can verify that our application is up and running by running this command:

```
systemctl status sample
```

It should not show any errors if everything has gone according to our plan. Press CTRL+C to stop showing status.

Now our sample web application will be running reliably and will be restarted if it crashed. You can close VSCode and visit `http://HOST_NAME:IP_ADDRESS/` and it should be serving requests.

------

In the next post, we will talk about setting up a CI/CD pipeline using GitHub actions.

The code is available on  [GitHub](https://github.com/encrypt0r/AspNetOnLinux).
