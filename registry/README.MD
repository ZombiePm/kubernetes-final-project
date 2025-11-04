## Установка
apt install apache2-utils -y
kubectl create secret generic registry-auth-secret \
--from-literal=htpasswd=$(htpasswd -nbB registry pajYcQP9ZexAz) \
-n registry
helm upgrade --install docker-registry twuni/docker-registry \
-n registry --create-namespace \
--set secrets.htpasswdSecret=registry-auth-secret

## Подключение
docker login docker-registry.registry.svc.cluster.local:5000 -u registry -p pajYcQP9ZexAz

## Удаление
kubectl delete secret registry-auth-secret -n registry
helm uninstall docker-registry -n registry

