## Установка
apt install apache2-utils -y
kubectl create secret generic registry-auth-secret \
--from-literal=htpasswd=$(htpasswd -nbB registry pajYcQP9ZexAz) \
-n registry
helm upgrade --install docker-registry twuni/docker-registry \
-n registry --create-namespace \
--set secrets.htpasswdSecret=registry-auth-secret \
--set extraEnvVars[0].name=OTEL_EXPORTER_OTLP_ENDPOINT \
--set extraEnvVars[0].value=""
kubectl apply -f registry-ingress.yaml -n registry

## Подключение
docker login registry.csjob.ru -u registry -p pajYcQP9ZexAz

## Удаление
kubectl delete secret registry-auth-secret -n registry
helm uninstall docker-registry -n registry

