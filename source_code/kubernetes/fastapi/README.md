# Deploy application

Create application code
Create Dockerfile
Login to DockerHub

```bash
docker login
```

Build and push image to DockerHub

```bash
docker build -t docker_hub_user/fastapi:latest .

docker push docker_hub_user/fastapi:latest

# Test is using
docker run -p 8000:8000 docker_hub_user/fastapi:latest
```

Deploy application to Kubernetes

```bash
cd k8s

k create ns devops
helm install -name fastapi --namespace devops .

k config set-context --current --namespace=default

k get pods 
k describe pods -n devops fastapi-64bd567597-2jpm4
k logs pods -n devops fastapi-64bd567597-2jpm4
k logs -n devops fastapi-64bd567597-2jpm4

kubectl port-forward svc/fastapi 8080:80

# connect to the browser: localhost:8080
```
