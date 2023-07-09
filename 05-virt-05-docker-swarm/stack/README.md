docker network create -d overlay monitoring --subnet 192.168.1.125/24 --ingress

docker stack deploy -c docker-stack.yml monitoring
