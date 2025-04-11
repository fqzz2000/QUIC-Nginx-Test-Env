# QUIC-Nginx-Test-Env

## HTTP3 to HTTP2 Protocol Conversion Test Environment

This repository provides a testing environment to evaluate the overhead of protocol conversion in load balancer architectures, specifically HTTP3 → HTTP2 conversion which is common in modern infrastructures.

### Overview

The setup consists of:

- A backend Nginx server serving a 5GB test file over HTTP2+TLS
- A frontend load balancer that accepts HTTP3 requests and forwards them to the backend over HTTP2
- Docker configuration for easy deployment and testing across multiple nodes

This allows for performance testing of protocol conversion in a controlled environment.

### Prerequisites

- Docker installed on all nodes
- Curl with HTTP3 support (specially compiled version) - see: https://curl.se/docs/http3.html
- Generated TLS certificates (included in the repo)
- Two nodes with network connectivity between them
- Ability to configure static IP addresses and host files on both nodes

## Network Configuration

### Configure Static IPs

Before deployment, configure static IPs on both nodes. In our testbed:

- Load Balancer (node1): 192.168.10.1
- Backend Server (node2): 192.168.10.2

If you're using different IPs, adjust these values accordingly in your configuration.

### Configure Host Files

On both nodes, update the `/etc/hosts` file to include:

On the load balancer node (node1):
```
127.0.0.1 localhost
192.168.10.2 node2.example.com  # Backend server IP
```

On the backend server node (node2):
```
127.0.0.1 localhost
192.168.10.1 node1.example.com  # Load balancer IP
```

You can add these entries with:

```bash
# On the load balancer node
sudo sh -c 'echo "192.168.10.2 node2.example.com" >> /etc/hosts'

# On the backend server node
sudo sh -c 'echo "192.168.10.1 node1.example.com" >> /etc/hosts'
```

## Directory Structure

```
├── backend
│   ├── Dockerfile
│   └── nginx.conf
├── certs
│   ├── nginx.crt
│   └── nginx.key
├── data
│   └── test_file_5gb.bin
├── frontend
│   ├── Dockerfile
│   └── nginx-http3.conf
├── README.md
├── start-backend.sh
└── start-h3-lb.sh
```

## Certificate Configuration

The certificates in this repository are configured for `node1.example.com` and `node2.example.com`. The certificate includes both domain names as Subject Alternative Names (SAN), allowing both nodes to use the same certificate.

## Generate Test File

Before starting the experiment, you need to generate a 5GB test file:

```bash
# Create the data directory if it doesn't exist
mkdir -p data

# Generate a 5GB test file
dd if=/dev/urandom of=data/test_file_5gb.bin bs=1M count=5120

# Verify the file size
ls -lh data/test_file_5gb.bin
```

This will create a 5GB random data file that will be served by the backend server. Make sure this file is generated on the backend node.

## Deployment

### On Backend Node (node2)

Build the backend image (optional, image available at dockerhub fqzz2000/nginx-backend):

```bash
docker build -t nginx-backend -f backend/Dockerfile ./backend
```

Start the backend server:

```bash
docker run --name nginx-backend \
  --network host \
  -v $(pwd)/backend/nginx.conf:/etc/nginx/nginx.conf \
  -v $(pwd)/certs:/etc/nginx/certs \
  -v $(pwd)/data:/usr/share/nginx/html/files \
  -d nginx-backend
```

### On Load Balancer Node (node1)

Build the frontend image (optional, image available at duckerhub fqzz2000/nginx-frontend):

```bash
docker build -t nginx-frontend-http3 -f frontend/Dockerfile ./frontend
```

Start the HTTP3 load balancer:

```bash
docker run --name nginx-frontend-http3 \
  --network host \
  -v $(pwd)/frontend/nginx-http3.conf:/etc/nginx/nginx.conf \
  -v $(pwd)/certs:/etc/nginx/certs \
  -d nginx-frontend-http3
```

## Important Port Considerations

- The backend server listens on port 443 with HTTP2+TLS
- The frontend load balancer listens on port 8443 with HTTP3 support
- Both services use host network mode, so these ports must be available on the respective nodes

If these ports are already in use, you'll need to modify the configuration files to use different ports.

## Testing

To test the HTTP3 protocol conversion, use a curl version compiled with HTTP3 support:

```bash
# Test HTTP3 from client to load balancer 
curl -k --http3 https://node1.example.com:8443/test_file_5gb.bin -o /dev/null

# Test direct HTTP2 connection to backend
curl -k https://node2.example.com:443/test_file_5gb.bin -o /dev/null
```

### Compiling curl with HTTP3 Support

For HTTP3 testing, you need curl with HTTP3 support. Follow the instructions at https://curl.se/docs/http3.html to compile a version with HTTP3 capabilities.

## Performance Testing

```bash
curl -k --http3 -w "Time: %{time_total}s\n" https://node1.example.com:8443/test_file_5gb.bin -o /dev/null
```

## Clean Up

```bash
# On load balancer node
docker stop nginx-frontend-http3
docker rm nginx-frontend-http3

# On backend node
docker stop nginx-backend
docker rm nginx-backend
```

## Troubleshooting

- Check nginx logs: `docker logs nginx-frontend-http3` or `docker logs nginx-backend`
- Verify networking between nodes: `ping node2.example.com` from node1
- Ensure ports are not blocked by firewalls: `sudo ufw status` (if using UFW)
- Verify HTTP3 support: `curl --version` should show HTTP3 capabilities
