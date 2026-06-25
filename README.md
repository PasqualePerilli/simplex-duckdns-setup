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
2. Bash

You also need to have registered on [Duck DNS](https://www.duckdns.org)

# How do I ensure my server, after a reboot, automatically starts all the containers?
TBA

# How do I set up my server to have this deployed?

Just run this very simple bash command:

```bash
curl -s -k https://raw.githubusercontent.com/PasqualePerilli/simplex-duckdns-setup/refs/heads/master/installation-script.bash | bash

```

# After installation, what do I need to do on the client side?

## Configure SimpleX Chat application

### Set SimpleX Chat message server

In order to set the SimpleX chat message server, you will first need to find the correct address to use.

You need to put a string in the following place:

`Settings -> Network and servers -> Your servers -> Add server -> Enter server manually -> Your server address`

The string needs to be in the following format:

`smp://FINGERPRINT1@SUBDOMAIN.duckdns.org:5223`

You will need to replace the two all-caps placeholders with actual values.

SUBDOMAIN is exactly what you registered on duckdns.org for free.

FINGERPRINT1 varies on each server/container. You can figure out what your fingerprint is by checking the docker logs:

```bash
docker logs simplex-smp
```
You will see something like this:

```log
Server address: smp://5abZcdefXftUgUUhiNkl9RFCl27mTUEnCeIGLKh0RP8=@itsallminesimplex.duckdns.org:5223,443
```

As you can see, the logs tell you what the fingerprint is, as well as the full server address (without the port at the end, which YOU NEED to add to the SimpleX chat application).


### Set SimpleX File transfer and media server

In order to set the SimpleX chat message server, you will first need to find the correct address to use.

You need to put a string in the following place:

`Settings -> Network and servers -> Your servers -> Add server -> Enter server manually -> Your server address`

The string needs to be in the following format:

`xftp://FINGERPRINT2@SUBDOMAIN.duckdns.org:8443`

You will need to replace the two all-caps placeholders with actual values.

SUBDOMAIN is exactly what you registered on duckdns.org for free.

FINGERPRINT2 varies on each server/container. You can figure out what your fingerprint is by checking the docker logs:

```bash
docker logs simplex-xftp
```
You will see something like this:

```log
[1;33mStorelog[0m [0;32mbackup successful:[0m [1;34m/var/opt/simplex-xftp/backups/queues/file-server-store.log.2026-06-22T12:51:56[0m
SimpleX XFTP server v6.5.2.0 / 
Fingerprint: abcOR2sCY0iIK7defXKaghiJWinj0BDiJabcG8jQKk=
Server address: xftp://abcOR2sCY0iIK7defXKaghiJWinj0BDiJabcG8jQKk=@redacted.duckdns.org
Warning: server source code is not specified.
Add 'source_code' property to [INFORMATION] section of INI file.
Store log: /var/opt/simplex-xftp/file-server-store.log
expiring files after 2 days
not expiring inactive clients
Uploading new files allowed.
Listening on port 443...

```

As you can see, the logs tell you what the fingerprint is, as well as the full server address (without the port at the end, which YOU NEED to add to the SimpleX chat application).

### Set SimpleX chat app to use your VoIP container
TBA


