#!/bin/sh
#                    Copyright (c) 2017-2017
#   Data Intensive Applications and Systems Labaratory (DIAS)
#            Ecole Polytechnique Federale de Lausanne
#
#                      All Rights Reserved.
#
# Permission to use, copy, modify and distribute this software and its
# documentation is hereby granted, provided that both the copyright notice
# and this permission notice appear in all copies of the software, derivative
# works or modified versions, and any portions thereof, and that both notices
# appear in supporting documentation.
#
# This code is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. THE AUTHORS AND ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE
# DISCLAIM ANY LIABILITY OF ANY KIND FOR ANY DAMAGES WHATSOEVER RESULTING FROM THE
# USE OF THIS SOFTWARE.

set -e

# Import settings
. ./settings.sh

# Master node/Manager
(
	# Initialize swarm
	docker swarm init --advertise-addr=${MASTER_IP}
)

# Portainer, a webUI for Docker Swarm
if true
then
(
	portainer_data=/srv/portainer
	test -d ${portainer_data} \
		|| mkdir -p ${portainer_data} \
		|| ( echo Failed to create ${portainer_data}; exit 1 )

	docker service create \
		--name portainer \
		--publish ${PORTAINER_PORT}:9000 \
		--constraint 'node.role == manager' \
		--mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
		--mount type=bind,src=${portainer_data},dst=/data \
		portainer/portainer \
		-H unix:///var/run/docker.sock
)
fi

docker network create \
	--driver=overlay \
	--opt encrypted \
	--subnet=10.20.30.0/24 \
	--ip-range=10.20.30.0/24 \
	--gateway=10.20.30.254 \
	mip-federation
