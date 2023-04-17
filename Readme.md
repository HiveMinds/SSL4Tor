# Self-signed SSL for https onion urls

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

Create your own <httpS://example31415926535.onion> websites, with your own
self-signed https certificates, **in a single command**.

![hi](onion_example.png?raw=true)

PS. The https says "not secure" because I did not copy the self-signed root ca
certificate into the device on which I took the screenshot. Feel free to
[fix it](https://github.com/HiveMinds/SSL4Tor/issues/4).

## Usage

3 sets of commands are given. One for a (qemu) sandbox, one for the
prerequisites, and the single command to create your https onion websites.

### Starting QEMU (Optional)

Using qemu is not necessary, but it is a nice sandbox to give this code a try,
keeping your own system nice and clean.

```sh
qemu-system-x86_64 --enable-kvm -m 4096 -machine smm=off -boot order=d \
  ubuntu22_1.img -smp 4 \
  -chardev qemu-vdagent,id=ch1,name=vdagent,clipboard=on \
  -device virtio-serial-pci \
  -device virtserialport,chardev=ch1,id=ch1,name=com.redhat.spice.0
```

Then press `Ctrl+Alt+G` to capture the keyboard (and mouse).

### Prerequisites

Get this repository both on your server(=device with the onion websites) and
client(=device that visits the onion websites).

```sh
sudo apt install git -y
git clone https://github.com/HiveMinds/SSL4Tor.git
cd SSL4Tor
```

### Single command

You can create 3 https onion domains, for 2 services, and an ssh access into
the device with:

```bash
./src/main.sh \
  --1-domain-1-service \
  --delete-onion-domain \
  --services 8050:gitlab:8070/9001:dash:9002/22:ssh:22 \
  --make-onion-domains \
  --ssl-password somepassword \
  --background-dash \
  --make-ssl-certs \
  --firefox-to-apt \
  --add-ssl-root-cert-to-apt-firefox \
  --setup-ssh-server \
  --get-onion-domain
```

This creates 2 dash plots (one at public port `8070`, and another at public
port `9002`) that you can actually visit:

- inside Qemu at: https:127.0.0.1:8050 and https:127.0.0.1:9001
- From anywhere in the world, using Brave or the Tor browser at:
  \<https://\<first_onion_url>.onion:8070>
  and
  \<https://\<second_onion_url>.onion:9002>

The third is your ssh tunnel.

## SSH into your onion server

To get your root CA (to set it as trusted on your phone etc.), you can ssh
into your server. For this you need the:

- Ubuntu username of your server
- ssh onion of your server.
  The onion is shown in the main/single command you ran above, in the form:

```txt
torsocks ssh ubuntu_username@31415926535abc...onion
```

### Run once

To setup ssh from your device(client) into your server (one with the onion
domains), (and get the root ca certificate from your server, run this on your
client:

```bash
./src/main.sh \
 --1-domain-1-service \
 --setup-ssh-client \
 --get-root-ca-certificate \
 --set-server-username <Ubuntu username of your server> \
 --set-server-ssh-onion <server ssh onion>.onion
```

### When you SSH

Then ssh into your server with the command you got. E.g.:

```bash
torsocks ssh ubuntu_username@31415926535abc...onion
```

## Developer Requirements

(Re)-install the required submodules with:

```sh
chmod +x install-bats-libs.sh
./install-bats-libs.sh
```

Install:

```sh
sudo gem install bats
sudo apt install bats -y
sudo gem install bashcov
sudo apt install shfmt -y
pre-commit install
pre-commit autoupdate
```

### Pre-commit

Run pre-commit with:

```sh
pre-commit run --all
```

### Tests

Run the tests with:

```sh
bats test/*
```

### Code coverage

```sh
bashcov bats test
```

## Help

Feel free to create an issue if you have any questions :)

## How to help

An quick and easy way to contribute is to:

- Reduce the output of the (main) script, make it more simple/silent.

And if you like this project, feel free to:

- Pick an issue and fix it.
- Create support for Windows and/or Mac.
- Improve the test-coverage by writing more (meaningful) tests.
