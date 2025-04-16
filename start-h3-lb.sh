docker run --name envoy-proxy --network host \
  -v $(pwd)/frontend/envoy.yaml:/etc/envoy/envoy.yaml \
  -v $(pwd)/certs:/etc/envoy/certs \
  -d envoy-proxy-image