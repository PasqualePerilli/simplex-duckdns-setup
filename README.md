# What is this?
This repository offers an easy way to set up SimpleX on your server. It is meant to be used as a "set it and forget it".

# How does this work?
It leverages docker to create a set of containers that automatically update and automatically restart

# What's behind the curtain?
The set of containers is composed by the following:
1. A duck DNS container, to make sure you can tie in your SimpleX instance to a DuckDNS subdomain (i.e. so that you have an always reachable SimpleX address, for free);
2. A SimpleX chat server;
3. A SimpleX file transfer server;
4. A coturn server, to allow internet (VoIP) calls between SimpleX users;
5. An ACME.sh script that automatically renews certificates for the coturn server;

# What are the pre-requisites to deploy this to my server?
You need the following programs installed on your system:
1. Docker
2. Git

You also need to have registered on [Duck DNS](https://www.duckdns.org)

# How do I ensure my server, after a reboot, automatically starts all the containers?
TBA

# How do I set up my server to have this deployed?
TBA

# After installation, what do I need to do on the client side?
TBA
