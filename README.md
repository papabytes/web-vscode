# Web VSCode
A practical approach to have your development environment avaialable on any device, via chrome browser.


## Motivation
Every time we get a new machine to work with we have the need to have it properly set up for the development needs. This process, although automatable, is a tedius and error prone process.

Moreso, what if I'm a programming addict and find myself in a remote place with nothing but my tablet and its keyboard case attached but damn... It runs IOS/Android and therefore it is almost impossible for me to work on what I typically do on my workstation?

I only came accoress the OpenVsCode Server project recently and it simply fulfilled this need, and I just had to think on how to properly configure it for my needs and how to host it.

## Configuring
The base Dockerfile already contains sections that configure GoLang, .NET, NodeJS (and Angular) and, as long as you know how to install your favorite SDKs, it should be fairly easy to tag along and customise it to your needs.

## Hosting and Quality of Life concerns
Having a web base browser IDE where you work on your private and Highly confidential projects and ideas raises multiple security concerns.

### Wherever you host this solution it is always open to the internet and attackers
There are multiple ways to tackle this issue and I will leave some on the table so that you can choose the one you feel the most confortable with.



## Related links
* [OpenVSCode Server Github](https://github.com/gitpod-io/openvscode-server)