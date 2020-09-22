consule-service
===============

Bash script for register/deregister service in Consul

### Requirements
- Bash
- cURL

## Installation
```bash
export BIN_PATH="/opt/bin"
mkdir --parents "$BIN_PATH"
curl --silent --show-error --location --output "$BIN_PATH/consul-service" "https://raw.githubusercontent.com/magna-z/consul-service/master/consul-service.sh"
chmod +x "$BIN_PATH/consul-service"
```

## Usage
### Register service in Consul:
```
CONSUL_URL=<consul-url> [CONSUL_TOKEN=<consul-token>] [CURL_MAX_TIME=5] consul-service register -e <environment> -n <name> -p <port> -t <tags>
```

### Deregister service in Consul:
```
CONSUL_URL=<consul-url> [CONSUL_TOKEN=<consul-token>] [CURL_MAX_TIME=5] consul-service deregister -e <environment> -n <name>
```
