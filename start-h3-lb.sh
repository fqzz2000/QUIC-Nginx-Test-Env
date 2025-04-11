docker run --name nginx-frontend-http3 --rm  --network host   -v $(pwd)/frontend/nginx-http3.conf:/etc/nginx/nginx.conf   -v $(pwd)/certs:/etc/nginx/certs   -d nginx-frontend-test
