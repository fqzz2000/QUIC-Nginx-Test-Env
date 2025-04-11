FROM nginx:mainline-alpine

# 安装必要的依赖和QUIC支持
RUN apk add --no-cache openssl pcre-dev zlib-dev


# 暴露HTTP3端口 
EXPOSE 80 443/udp

CMD ["nginx", "-g", "daemon off;"]
