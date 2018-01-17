# MIP Federation deployment scripts and documentation

This repository contains all documentation regarding the MIP Federation, and scripts automating its deployment.

## Overview

The MIP Federation allows to connect multiple MIP Local instances securely over the web, so that privacy-preserving analysis and queries from the Federation manager. The queries will be performed in a distributed manner over the data stored at the Federation nodes using the Exareme software.

Complete documentation of the Federation can be found in [MIP Federation specifications](https://github.com/HBPMedical/mip-federation/blob/master/Documentation/MIP_Federation_specifications.md).

The steps to deploy the Federation are the following: 

- Setup the manager node(s).
- Add the worker nodes.
- Add name labels to the nodes to allow proper assignation of the different services.
- Start "services", which are described in docker-compose.yml files: Exareme, Consul and Portainer.

In the following we are going to use only one master node. More can be added for improved availability.

## Deployement

### Requirements

MIP Local should be installed on the nodes that will join the MIP Federation. To join a node without MIP Local, see section [Adding a node without MIP Local](#adding-a-node-without-mip-local).

The Federation manager server must have a fixed IP address; other nodes must have a public IP, ideally also fixed. The firewall must allow connections on several ports: see details in [Firewall configuration](https://github.com/HBPMedical/mip-federation/blob/master/Documentation/Firewall_configuration.md).

### Deploy the Federation

1. Create the manager node(s).

   ```sh
   $ sudo ./setupFederationInfrastructure.sh
   ```
   The output will include the command to add a node to the swarm.

2. On each worker node (a.k.a node of the federation), run the swarm join command.

   ```sh
   $ sudo docker swarm join --token <Swarm Token> <Master Node URL>
   ```
   
   The command to execute on the worker node, including the `Swarm Token` and the `Master Node URL`, is provided when performing point 1. It can be obtained again at any time from the manager, with the following command:

   ```sh
   $ sudo docker swarm join-token worker
   To add a worker to this swarm, run the following command:

   docker swarm join --token SWMTKN-1-11jmbp9n3rbwyw23m2q51h4jo4o1nus4oqxf3rk7s7lwf7b537-9xakyj8dxmvb0p3ffhpv5y6g3 10.2.1.1:2377
   ```

3. Add informative name labels for each worker node, on the swarm master.

   ```sh
   $ sudo docker node update --label-add name=<Alias> <node hostname>
   ```

   * `<node hostname>` can be found with `docker node ls`
   * `<Alias>` will be used when bringing up the services and should be a short descriptive name.

4. Deploy the Federation service

   ```sh
   $ sudo ./start.sh <Alias>
   ```

   * `<Alias>` will be used when bringing up the services and should be a short descriptive name.
   * if you set `SHOW_SETTINGS=true` a printout of all the settings which will be used will be printed before doing anything.

## Settings

All the settings have default values, but you can change them by either exporting in your shell the setting with its value, or creating `settings.local.sh` in the same folder as `settings.sh`:

```sh
: ${VARIABLE:="Your value"}
```

**Note**: To find the exhaustive list of parameters available please take a look at `settings.default.sh`.

**Note**: If the setting is specific to a node of the federation, you can do this in `settings.local.<Alias>.sh` where `<Alias>` is the short descriptive name given to a node.

Settings are taken in the following order of precedence:

  1. Shell Environment, or on the command line
  2. Node-specific settings `settings.local.<Alias>.sh`
  3. Federation-specific `settings.local.sh`
  4. Default settings `settings.default.sh`


## Adding a node without MIP Local

The following are required on all nodes. This is installed by default as part of the MIP, but can be installed manually when MIP Local is not present.

1. Install docker

   ```sh
   $ sudo apt-get update
   $ sudo apt-get install \
	    apt-transport-https \
	    ca-certificates \
	    curl \
	    software-properties-common
	$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   ```

2. Check the finger print: `9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88`

   ```sh
	$ sudo apt-key fingerprint 0EBFCD88
	pub   4096R/0EBFCD88 2017-02-22
      Key fingerprint = 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
	uid                  Docker Release (CE deb) <docker@docker.com>
	sub   4096R/F273FCD8 2017-02-22
   ```

3. Add the Docker official repository

  ```sh
  $ sudo add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	   $(lsb_release -cs) \
	   stable"
  ```

4. Update the index and install docker:

  ```sh
  $ sudo apt-get update
  $ sudo apt-get install docker-ce
  ```
  
5. TODO: Run PostgresRAW and PostgresRAW-UI, create necessary tables / files, expose on correct ports.