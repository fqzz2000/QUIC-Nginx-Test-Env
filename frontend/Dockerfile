FROM envoyproxy/envoy:v1.26-latest

# 创建配置目录
RUN mkdir -p /etc/envoy/certs

EXPOSE 10000 20000 30000

CMD ["/usr/local/bin/envoy", "-c", "/etc/envoy/envoy.yaml"]