# MIP Local deployment and documentation

This document summarises the knowledge of DIAS-EPFL regarding the deployment and upgrade process of MIP Local. It is based on the version 2.5.3 released on Nov 13, 2017.

**Disclaimer:** The authors of this document are not in charge of the MIP development and its deployment scripts. They have limited knowledge of most of the elements that are deployed. No guaranties are offered as to the correctness of this document.

See also the official documentation of the deployment scripts project on Github: <a href="https://github.com/HBPMedical/mip-microservices-infrastructure/blob/master/README.md">README</a> file, <a href="https://github.com/HBPMedical/mip-microservices-infrastructure/blob/master/docs/installation/mip-local.md">installation</a> instructions and some <a href="https://github.com/HBPMedical/mip-microservices-infrastructure/blob/master/docs">more documentation</a>.

## Contents

- [Introduction](#introduction)
- [User management](#user-management)
- [Known limitations](#known-limitations)
- [Deployment steps](#deployment-steps)
- [Deployment validation](#deployment-validation)
- [Direct access to the deployed databases](#direct-access-to-the-deployed-databases)
- [Reboot](#reboot)
- [Upgrades](#upgrades)
- [Adding clinical data](#adding-clinical-data)
- [Cleanup MIP installation](#cleanup-mip-installation)
- [Requirements](#requirements)
- [Network configuration](#network-configuration)

## Introduction

The MIP (Medical Informatics Platform) is a bundle of software developed by the HBP sub-project SP8.
Its goal is to enable research and studies on neurological medical data, locally at one hospital and in a Federated manner across hospitals, while maintaining the privacy of sensitive data. For more information, please refer to "SP8 Medical Informatics Platform – Architecture and Deployment Plan" (filename `SGA1_D8.6.1_FINAL_Resubmission`).

The MIP is composed of four main parts:

- Web Portal (interface: metadata about the available data, functionalities for privacy-preserving exploration and analysis of the data).
- Structural software (aka "Hospital Bundle": anonymisation, data harmonisation, query engine, federated query engine).
- Data Factory (extraction of features from medical imaging data).
- Algorithm Factory (library of research algorithms that can be run in the MIP).

It is populated with:

- The research datasets PPMI, ADNI and EDSD.
- Local clinical datasets, once prepared and processed.

The MIP can be deployed using the scripts available in the <a href="https://github.com/HBPMedical/mip-microservices-infrastructure">mip-microservices-infrastructure</a> project on Github.

The software is organised into "building blocks" that should facilitate the deployment of the MIP on two or three servers, in an infrastructure that improves security in order to guaranty data privacy.

Based on the <a href="https://github.com/HBPMedical/mip-microservices-infrastructure/blob/master/roles/mip-local/templates/hosts.j2"> Ansible inventory file</a>, the building blocks are the following:

- infrastructure
- hospital-database
- reference
- data-factory
- algorithm-factory
- web-analytics

This file lists the building blocks that will be installed. In theory, it can be modified before running setup.sh to install only specific block (this has not been tested). 

**TODO: Test building block deployment and improve documentation. Determine which blocks need to be deployed on the same server, and how to configure the blocks if they are deployed on different servers.**


## Requirements

- Ubuntu 16.04 system (partial support for RHEL).
- Matlab R2016b. (Required for the Data Factory. Alternatively the MIP can be installed without the Data Factory: see below the corresponding deployment option.)
- According to the official documentation, python version 2.7 and the library jmespath need to be installed beforehand. 
   - For ubuntu: 
   	
   		```
   		sudo apt install python2.7 
   		ln -s /usr/bin/python2.7 /usr/bin/python
   		sudo apt install python-jmespath
   		```


## Network configuration


### Internet access for deployment

Access to the following internet domains is required during the deployment:

**TODO: Get Lille list and reproduce it here**


### Operational firewall configuration

The firewall of the server where MIP is deployed must be set up and deny all incoming connections, except on the following ports:

- 22 for ssh access
- 80 for Web Portal access
- MIP Local requirements
- Federation requirements (see Federation documentation)
- User management requirements (see below)

**TODO: Obtain user management requirement and reproduce it here.**


### MIP Local requirements

Some ports must be open for intra-server connections (accept only requests coming from the local server itself, but on its public address):

- 31543 ("LDSM", PostgresRAW database)
- 31555 (PostgresRAW-UI)

**TODO: Obtain list and reproduce it here.**


## User management

The Web Portal of MIP Local can be deployed in two settings:

- No user management: anybody who has access to the port 80 of the MIP Local server can access the Web Portal and all the data available in the MIP. This can either be
	- Everybody that has access to the local network, if the firewall is open.
	- Only users who have access to the server itself, if the firewall prevents external access.
- User authentification required: every user must obtain credentials to access the Web Portal. In this case, user rights and authentification are managed by the main HBP servers, so network access to these servers must be allowed.

Further information:

[//]: # ( from Jacek Manthey to Lille)

[... Users] can create accounts on the HBP Portal (see https://mip.humanbrainproject.eu/intro) through invitation, which means that the access control is not stringent.
[... Only] users that can access [the local] network and have an HBP account would be able to access MIP Local. In case you would need more stringent access control, we would need to implement in your MIP-Local a whitelist of authorized HBP accounts.  
 
In order to activate the user access using the authentication through the HBP Portal, we would need a private DNS alias for your MIP local machine, something like ‘mip.your\_domain\_name’. [...]

## Known limitations

The following are known limitations of the deployment scripts, version 2.5.3.

- It is currently not possible to deploy MIP Local with a firewall enabled. MIP Local cannot run either with the firewall up, unless the correct rules are configured (see [MIP Local requirements](#mip-local-requirements)). 
   		
- The deployed MIP will include research datasets (PPMI, ADNI and EDSD), but the process to include hospital data in MIP-Local is as yet unclear. **TODO: Obtain information, test, complete dedicated section below**

Note: Clinical data processed and made available in the Local Data Store Mirror (LDSM) will not be visible from the Local Web Portal without further configuration, but they will be available to the Federation if the node is connected (variables included in the CDE only).


## Deployment steps

This section describes how to deploy MIP Local without clinical data, on a clean server. If a previous installation was attempted, please see [Cleanup MIP installation](#cleanup-mip-installation). To add hospital data see the section [Adding clinical data](#adding-clinical-data).

1. Retrieve informations requested for the deployment:

	- Matlab installation folder path,
	- server's address on the local network,
	- credentials for the gitlab repository, to download the research data sets,
	- sudo access to the target server.
    
2. Clone the `mip-microservices-infrastructure` git repo in the desired location (here a `mip-infra` folder):

	```sh
	git clone https://github.com/HBPMedical/mip-microservices-infrastructure.git mip-infra
	cd mip-infra/
	./after-git-clone.sh  # Need confirmation whether this is needed or not
	git checkout tags/2.5.3
	./after-update.sh  # Need confirmation whether this is needed or not
	```

	Also check the process as described in official doc.

3. Run the configuration script:

	```
	./common/scripts/configure-mip-local.sh
	```

	Provide the requested parameters.

	Summary of requested input:

	```
	Where will you install MIP Local?
	1) This machine
	2) A remote server
	>
	
	Does sudo on this machine requires a password?
	1) yes
	2) no
	>
	
	>Which components of MIP Local do you want to install?
	1) All				     3) Data Factory only
	2) Web analytics and databases only
	> 
	
	Do you want to store research-grade data in CSV files or in a relational database?
	1) CSV files
	2) Relational database
	> 
	```
	WARNING: Both options load the research data (ADNI, PPMI and EDSD) in a relational database. The first option will upload the data in the LDSM database using PostgresRAW, and the second in an unofficial postgres database named "research-db".
	
	```
	Please enter an id for the main dataset to process, e.g. 'demo' and a 
	readable label for it, e.g. 'Demo data'
	Id for the main dataset > 
	Label for the main dataset > 
	
	Is Matlab 2016b installed on this machine?
	1) yes
	2) no
	>
	
	Enter the root of Matlab installation, e.g. /opt/MATLAB/2016b :
	path >
	
	Do you want to send progress and alerts on data processing to a Slack channel?
	1) yes
	2) no
	
	Do you want to secure access to the local MIP Web portal?
	1) yes
	2) no
	
	To enable Google analytics, please enter the Google tracker ID or leave this blank to disable it
	Google tracker ID > 
	```
	
	
	```
	TASK [Suggested target server hostname]***********************
	ok: [localhost] => {
		"ansible_hostname": "suggested_ansible_hostname"
	}
	
	TASK [Suggested target server FQDN]***************************
	ok: [localhost] => {
		"ansible_fqdn": "suggested_ansible_fqdn"
	}
	
	TASK [Suggested target server IP address]***********************
	ok: [localhost] => {
		"msg": "suggested_IP_address"
	}
	
	Target server hostname, e.g. myserver . Use ansible_hostname value if you agree with it. 
	
	Target server FQDN, e.g. myserver.myorg.com . 
	If the full server name cannot be reached by DNS (ping myserver.myorg.com fails), 
	you can use the IP address instead:
	```
	
	If unsure that the `suggested_ansible_fqdn` given above is valid, use the `suggested_IP_address` instead. (Or check if ping works on the `suggested_ansible_fqdn` from another computer.)
	
	
	```
	Target server IP address:
	
	Base URL for the frontend, for example http://myserver.myorg.com:7000
	
	```
	
	This is the address the WebPortal will be accessed through.
	The server's address must be valid on the local network (check with nslookup).
	The port must be open.
	
	```
	Username on Gitlab to download private Docker images. 
	Leave blank if you do not have access to this information:
	
	Password on Gitlab to download private Docker images. 
	Leave blank if you do not have access to this information:
	
	```
	
	Gitlab access to download the research data docker images.
	
	```
	Use research data only? (Y/n):
	```
	
	Using only the research data ("Y") should lead directly to a working MIP Local, accessing research data in a table name `mip_cde_features`. 
	
	Adding hospital data (i.e. answering "n") requires additional steps: see section [Adding clinical data](#adding-clinical-data). 
	
	In this case, MIP Local will use the view named "mip\_local\_features" to access data. This view groups the research and the clinical data in a uniform flat schema. It is automatically created when hospital data, in the form of a csv file name "harmonized\_clinical\_data", is dropped in the /data/ldsm folder of the MIP Local server. (See [PostgresRAW-UI documentation](https://github.com/HBPMedical/PostgresRAW-UI/blob/master/README.md#3-automated-mip-view-creation) for details.)
	
	
	```
	Generate the PGP key for this user...
	[details]
	Please select what kind of key you want:
	 (1) RSA and RSA (default)
	 (2) DSA and Elgamal
	 (3) DSA (sign only)
	 (4) RSA (sign only)
	Your selection?
	
	RSA keys may be between 1024 and 4096 bits long.
	What keysize do you want? (2048) 
	
	Please specify how long the key should be valid.
	         0 = key does not expire
	      <n>  = key expires in n days
	      <n>w = key expires in n weeks
	      <n>m = key expires in n months
	      <n>y = key expires in n years
	Key is valid for? (0) 
	
	Is this correct? (y/N)
	
	You need a user ID to identify your key; the software constructs the user ID
	from the Real Name, Comment and Email Address in this form:
	    "Heinrich Heine (Der Dichter) <heinrichh@duesseldorf.de>"
	
	Real name:
	
	Email address:
	
	Comment: 
	
	You selected this USER-ID:
	    [...]
	
	Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit?
	
	
	You need a Passphrase to protect your secret key.
	
	Enter passphrase: 
	                  
	Repeat passphrase: 
	
	```
	
	This information is used by git-crypt to encrypt in the Git repository the sensitive information. This precaution is taken if the configuration is uploaded (pushed) to a different server.


4. Once the configuration script ends successfully with a message "Generation of the standard configuration for MIP Local complete!", commit the modifications before continuing.
	
	```
	git add .
	git commit -m "Configuration for MIP Local"
	```

5. Run the setup script, twice if required.

	```
	./setup.sh
	```
	
	The script should end with the following message:
	
	```
	PLAY RECAP *************************************************************************************
	localhost                  : ok=??   changed=??   unreachable=0    failed=0   
	```


## Deployment validation

If the deployment was successful, the Web Portal should be accessible on the `target server IP address` defined at the configuration step.

The Web Portal documentation [HBP\_SP8\_UserGuide\_latest.pdf](https://hbpmedical.github.io/documentation/HBP_SP8_UserGuide_latest.pdf) can help check that the deployed MIP Local is running as expected. The Web Portal should provide similar results but not exactly the results shown in the doc.

[This report](https://drive.google.com/file/d/136RcsLOSECm4ZoLJSORpeM3RLaUdCTVe/view) of a successful deployment can also help check that MIP Local is behaving correctly.

The PostgresRAW-UI can be validated following this <a href="https://drive.google.com/open?id=0B5oCNGEe0yovNWU5eW5LYTAtbWs">test protocol</a>. PostgresRAW-UI should be accessible locally at `http://localhost:31555`.



## Direct access to the deployed databases

The ports and credentials to access the databases used in the MIP can be found in these files:

```
cat install_dir/envs/mip-local/etc/ansible/host_vars/localhost
cat install_dir/vars/hospital-database/endpoints.yml
cat install_dir/vars/reference/endpoints.yml
```

Adapt this command to connect to the databases:

```
psql -U ldsm -p 31432 -h hostname
```


## Reboot

The MIP is not automatically restarted if the server is shut down or rebooted. 

The last instructions provided to restart it are:

[//]: # (Slack, MIP-Local & IAAN workspace, general channel, 06.12.2017)

```
./common/scripts/fix-mesos-cluster.sh --reset
./setup.sh
```

Before an updated version of the installer can be provided, it might be necessary to:
> stop all services, uninstall mesos, marathon and docker-ce, then run the installer again.


## Upgrades


> When you perform an upgrade, in most cases you will not need to run again the pre-configuration script mip-local-configuration.sh.
>  
> In the few cases where that is necessary, for example if you want to install a new component such as the Data Factory or there has been a big update that affects configuration, then you need to be careful about the changes that this script brings to the configuration. For example, passwords are always re-generated. But the passwords for the existing databases should not be modified. To counter that, you can use Git features and do a review on all changes, line by line, and commit only the changes that are actually needed. 


**TODO: Clarify procedure. How to guess which changes are needed? Revert at least the changes to `install_dir/envs/mip-local/etc/ansible/host_vars/` or to file `localhost` in particular?**


## Adding clinical data

**TODO: This section needs to be checked, and properly documented. Only general information is available.**

Draft guidelines to add clinical data:

[//]: # (from meeting on January 9th, 2018; untested)

>	- Create a clone of gitlab project https://github.com/HBPMedical/mip-cde-meta-db-setup.
> 	- Modify clm.patch.json so that it can modify the default variables.json file to add the relevant new variables.
> 	- Adapt first line of Docker file to select / define the version / rename the Docker image, from hbpmip/mip-cde-meta-db-setup to something else (?)
> 	- Create the docker image and push it to gitlab (?)
> 	- Once the MIP-Local configuration for the deployment exist, modify (line 20 of) the file
> 	   envs/mip-local/etc/ansible/group_vars/reference to reference the right docker image
> 	- Run setup.sh so that the new docker image is run and copies the data in the meta-db database
> 	- Restart all services of the following building blocks from Marathon (if necessary, scale them down to 0, then up again to 1)
> 		- web portal
> 		- woken
> 		- data factory



## Cleanup MIP installation

Before attempting a second installation, in case a couple of updates have been delivered to your Linux distribution package manager, you will need to follow the next steps to ensure a proper deployment.

Please be advised this is drastic steps which will remove entirely several softwares, their configuration, as well as any and all data they might store.

### Ubuntu 16.04 LTS

 1. Purge installed infrastructure:

   ```sh
	$ sudo apt purge -y --allow-change-held-packages docker-ce marathon zookeeper mesos
	```
	
 2. Remove all remaining configuration as it will prevent proper installation:
 
   ```sh
	$ sudo rm -rf /etc/marathon /etc/mip
	$ sudo reboot
	$ sudo rm -rf /etc/sysconfig/mesos-agent /etc/sysconfig/mesos-master /var/lib/mesos /var/lib/docker
	$ sudo rm -rf /etc/systemd/system/marathon.service.d
	$ sudo find /var /etc /usr -name \*marathon\* -delete
	$ sudo find /etc /usr /var -name \*mesos\* -delete
	$ sudo rm -rf /srv/docker/ldsmdb /srv/docker/research-db
	```

   ------
   **WARNING:**
   Backup your data before executing the command above. This will remove anything placed inside databases, as well as stored insides docker images.

   ------
	
3. Reload the system initialisation scripts, and reboot:

   ```sh
	$ sudo systemctl daemon-reload
	$ sudo reboot
   ```
 
4. Manually pre-install the packages. As this requires to specify precise version numbers, this list will be out of date really soon:

   ```sh
   $ sudo apt install -y --allow-downgrades --allow-change-held-packages docker-ce=17.09.0~ce-0~ubuntu
   ```
   
## Troubleshooting

[//]: # (from Slack)

> Zookeeper in an unstable state, cannot be restarted
>  
> -> ```/common/scripts/fix-mesos-cluster.sh --reset, then ./setup.sh ```


See documentation folder on Github for a few specific fixes.