docker run --rm --name envoy-proxy --network host \
  -v $(pwd)/frontend/envoy.yaml:/etc/envoy/envoy.yaml \
  -v $(pwd)/cert-envoy:/etc/envoy/certs \
  -d envoyproxy/envoy:v1.26-latest

# docker run --rm --name envoy-proxy --network host \
#   -v $(pwd)/cert-envoy:/etc/envoy/certs \
#   -d envoyproxy/envoy:v1.26-latest

