# QUIC-Nginx-Test-Env
# HTTP3 to HTTP2 Protocol Conversion Test Environment

This repository provides a testing environment to evaluate the overhead of protocol conversion in load balancer architectures, specifically HTTP3 → HTTP2 conversion which is common in modern infrastructures.

## Overview

The setup consists of:
- A backend Nginx server serving a 5GB test file over HTTP2+TLS
- A frontend load balancer that accepts HTTP3 requests and forwards them to the backend over HTTP2
- Docker configuration for easy deployment and testing

This allows for performance testing of protocol conversion in a controlled environment.

## Prerequisites

- Docker installed on your system
- Curl with HTTP3 support (specially compiled version)
- Generated TLS certificates (included in the repo)

## Directory Structure

```
├── backend
│   ├── Dockerfile
│   └── nginx.conf
├── cert-envoy
│   ├── servercert.pem
│   └── serverkey.pem
├── certs
│   ├── nginx.crt
│   └── nginx.key
├── curl3.sh
├── data
│   └── test_file_5gb.bin
├── docker-compose.yml
├── envoy.yaml
├── frontend
│   ├── Dockerfile
│   ├── envoy-h3-client.yaml
│   └── envoy.yaml
├── README.md
├── start-backend.sh
└── start-h3-lb.sh
```

## Getting Started

### Build Docker Images (optional)

Before starting the services, you need to build the Docker images:

```bash
# Build backend image
docker build -t nginx-backend -f backend/Dockerfile ./backend

# Build frontend image
docker build -t nginx-frontend-test -f frontend/Dockerfile ./frontend
```

### Using Scripts

You can start the services using the provided scripts:

1. Start the backend server first:
```bash
./start-backend.sh
```

2. After the backend is running, start the HTTP3 load balancer:
```bash
./start-h3-lb.sh
```


## Testing (Not work yet)

To test the HTTP3 protocol conversion, use a curl version compiled with HTTP3 support:

```bash
curl -k --http3 https://localhost:10000/test_file_5gb.bin
```

You can test download performance or monitor traffic to evaluate the protocol conversion overhead.

## Notes

- The backend server listens on port 443 with HTTP2+TLS
- The frontend load balancer listens on port 10000 with HTTP3 support
- Both services use the same TLS certificates for simplicity
- Host networking mode is used to simplify the setup
- Proper setting of DNS is needed for cross node benchmark

## Stopping Services

If using the scripts:
```bash
docker stop nginx-backend nginx-frontend-http3
docker rm nginx-backend nginx-frontend-http3
```

If using Docker Compose:
```bash
docker-compose down
```
