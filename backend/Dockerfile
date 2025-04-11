FROM nginx:mainline-alpine

# 安装必要的依赖
RUN apk add --no-cache openssl

# 创建证书目录
RUN mkdir -p /etc/nginx/certs

# 复制配置文: mount volumes instead
# COPY nginx.conf /etc/nginx/nginx.conf

# 创建文件目录
RUN mkdir -p /usr/share/nginx/html/files

# 暴露HTTP2端口
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
