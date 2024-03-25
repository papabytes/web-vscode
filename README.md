# Web VSCode
A practical approach to have your development environment avaialable on any device, via chrome browser.

## Motivation
Every time we get a new machine to work with we have the need to have it properly set up for the development needs. This process, although automatable, is a tedius and error prone process.

Moreso, what if I'm a programming addict and find myself in a remote place with nothing but my tablet and its keyboard case attached but damn... It runs IOS/Android and therefore it is almost impossible for me to work on what I typically do on my workstation?

I only came accoress the OpenVsCode Server project recently and it simply fulfilled this need, and I just had to think on how to properly configure it for my needs and how to host it.

## Configuring
The base Dockerfile already contains sections that configure GoLang, .NET, NodeJS (and Angular) and, as long as you know how to install your favorite SDKs, it should be fairly easy to tag along and customise it to your needs.

## Data Persistence
From the docker compose you can see that the only directory being mapped is
>  volumes:  
        - ./workspace:/home/workspace:cached

The left hand side of the volume mount should represent the directory on the host where you will want to host the VSCode extensions configurations and the projects you want it to access.

## Running
To ease the startup process you can use **docker compose** to start the application, by running one of the following commands, depending on the docker compose version you have installed:

* Docker Compose V2:
> docker compose up -d --build

* Docker Compose V1
> docker-compose up -d --build

By default the docker compose is selecting the **unsecure** target from the Dockerfile which will run the application without token protection.

You can change this value to **secure** and the UI will be protected by a token that you will be able to inspect from the docker console output:
> Web UI available at http://localhost:3000/?tkn=2bf5b2ed-e592-42d1-aa88-6f9f6d5ab132


## Hosting and Quality of Life concerns
Having a web base browser IDE where you work on your private and Highly confidential projects and ideas raises multiple security concerns.

### Wherever you host this solution it is open and vulnerable to attacks
There are multiple ways to tackle this issue and I will leave some on the table so that you can choose the one you feel the most confortable with.

#### Secure Mode

* Secure Mode Only  
> If you use the secure target approach, as long as the token is not compromised (which will only be possible if you have a valid SSL connection between your machine and the hosting service), you should be ok. You could go an extra mile and configure the Server's firewall to only accept incoming traffic to the UI's port from a well defined range of IPs that you and only you own.
* Secure Mode + VPN
> If you install a VPN server solution on the target server or within its network you could configure the VPN client on your devices and simply access the URL when you are connected to the VPN. This limits the attack possibilities as the URL is not public and you also require VPN credentials to have connectivity towards it.

### Unsecure mode
Never, and I mean NEVER use the unsecure mode over the internet, unless you acknowledge the risks involved. Your code base may be tampered with, stolen, etc.

If you must do the Unsecure mode approach at least attempt to:
* Unsecure Mode + VPN
    Same as Secure Mode + VPN without the secret rotation on application restart

## Related links
* [OpenVSCode Server Github](https://github.com/gitpod-io/openvscode-server)
* [OpenVPN Install @angristan](https://github.com/angristan/openvpn-install)