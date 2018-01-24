: ${SHOW_SETTINGS:=false}

# Swarm Manager settings
: ${MASTER_IP:=$(wget http://ipinfo.io/ip -qO -)}

# Swarm Management Services
: ${PORTAINER_PORT:="9000"}

# Federation Services
: ${CONSUL_IMAGE:="progrium/consul"}
: ${CONSUL_VERSION:="latest"}
: ${EXAREME_IMAGE:="hbpmip/exareme_dataset"}
: ${EXAREME_VERSION:="postgresraw"}
: ${EXAREME_ROLE:=""} # The default value is set to the federation node role (worker or manager)
: ${EXAREME_KEYSTORE_PORT:="8500"}
: ${EXAREME_KEYSTORE:="exareme-keystore:${EXAREME_KEYSTORE_PORT}"}
: ${EXAREME_MODE:="global"}
: ${EXAREME_WORKERS_WAIT:="1"} # Wait for N workers
: ${EXAREME_LDSM_ENDPOINT:="query"}
: ${EXAREME_LDSM_RESULTS:="all"}
: ${EXAREME_LDSM_DATAKEY:="output"} # query used with output, query-start with data

# Exareme LDSM Settings
: ${LDSM_USERNAME:="federation"}
: ${LDSM_PASSWORD:="federation"}
: ${LDSM_HOST:=""} # The default value is set to the federation node
: ${LDSM_PORT:="31432"}
: ${LDSM_DB:="ldsm"}

: ${FEDERATION_NODE:=""} # Invalid default value, this a required argument of start.sh
