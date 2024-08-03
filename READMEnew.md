# Дипломная работа

[Весь код в директории](./project/)

[terraform](./project/terraform)

[terraform-k8s](./project/terraform/k8s)

[k8s](./project/k8s)

[docker](./project/docker)


# Решение1: Docker, Jenkins, Github, k8s_yandex_cloud
В данном решение используются:
- `CICD`: Jenkins in k8s from yandex cloud
- `Kubernetes:` k8s yandex cloud
- `IAC:` Terraform
- `Git` Github

##  k8s_yandex_cloud
В данном решении используется service account для terraform. Для этого создал учетную запись и сгенерировал токен в json файл используя команду 

```
yc iam key create  --service-account-id <account_id> --folder-id <folder_id> --output key.json

```


Далее задаю конфигурацию профиля

```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

Создаю кластер kubernetes и  узлы используя [terraform](./project/terraform/k8s/)
```
terraform init
terraform apply --auto-approve
```
После создания кластера на сервере с предустановленным yandex CLI , чтобы получить конфиг файл кластера k8s по пути ``~/.kube/config`` необходимо выполнить команду:
```
yc managed-kubernetes cluster get-credentials --id catca7qm6373qprq6ik4 --external
```

Чтобы не вводить эту команду каждый раз вручную , в коде terraform добавил блок с флагом --force для перезаписи кониг файла.(можно вывести конфиг командой ``kubectl config view``)

```
resource "null_resource" "kubectl" {
    provisioner "local-exec" {
        command = "yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.regional_cluster.id} --external --force"
    }
}
```

### Настраиваем кластер k8s для работы jenkins

Ссылка руководства установки  [Jenkins в кластер kubernetes](https://www.jenkins.io/doc/book/installing/kubernetes/)
- создаем новую область для работы jenkins
  ```
  kubectl create namespace devops-tools

  ```
 - создаем сервисный аккаунт [service.yaml](./project/k8s/jenkins/serviceaccount.yaml)
 - создаем диск [volume.yaml](./project/k8s/jenkins/volume.yaml)

так как диск я создаю на хосте, необходимо указать ноду . Для этого в файле [volume.yaml](./project/k8s/jenkins/volume.yaml) меняем значения ``values: - Имя_НОДЫ`` на имя любой ноды. Для просмотра нод можно использовать команду ``kubectl get node``

```
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ИМЯ_НОДЫ
```
 
- создаем [deployment.yaml](./project/k8s/jenkins/deployment.yaml)
- создаем [service.yaml](./project/k8s/jenkins/service.yaml)
- создаем [ingress.yaml](./project/k8s/jenkins/ingress.yaml)

- теперь можно выполнить деплой указав папку ка файлам

```
kubectl apply -f ./project/k8s/jenkins/
```

- Далее устанавливаю ingress-nginx для доступа в jenkins 

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && helm repo update && helm install ingress-nginx ingress-nginx/ingress-nginx 
```

Для вывода токена jenkins использовать следующую команду

```
kubectl logs jenkins-56b6774bb6-5nfv8 -n devops-tools
```

### Настройка мониторинга в кластере kubernetes

Создадим новую область для веб приложения и мониторинга

```
kubectl create namespace monitoring
kubectl get namespace
```

Для создания мониторинга возьмем helm чарт

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install stable prometheus-community/kube-prometheus-stack --namespace=monitoring
kubectl apply -f ingress.yml -n monitoring
kubectl --namespace monitoring get pods -l "release=stable"
kubectl edit svc stable-grafana -n monitoring
```
Последняя команда ``kubectl edit svc stable-grafana -n monitoring`` небходима для того, чтобы поменять тип балансировщика на ``LoadBalancer``



а так же логин и пароль для графана

```
UserName: admin Password: prom-operator
```
![image](https://github.com/djohnii/devops-project/assets/91311426/93c743c6-ad1c-4b72-8915-4436564e19ee)
![image](https://github.com/djohnii/devops-project/assets/91311426/6ab63bfd-7114-42f5-84f6-8d0ef0dc0878)

## Github
- Создал [GitHub](https://github.com/djohnii/devops-project) репозиторий 
- Настроил webhooks в [github](https://github.com/djohnii/devops-project/settings/hooks)
  ![alt text](image.png)






## Jenkins (Альтернативный способ)

- Отдельно развернул виртуальную машину с белым ip используя (terraform)[./project/terraform/jenkins_host].Установил jenkins используя данную инсрукцию https://www.jenkins.io/doc/book/installing/linux/.Настроил webhooks в github или еще проще используя (docker)[https://www.jenkins.io/doc/book/installing/docker/]
- установил несколько плагинов: [kubernetes](https://plugins.jenkins.io/kubernetes-cli/),[docker](https://plugins.jenkins.io/docker-worcflow),[github](https://plugins.jenkins.io/github-api/) [Blue Ocean](https://plugins.jenkins.io/blueocean/)
- настроил kubernetes cloud 
  ![alt text](image-1.png)
- написал [jenkinsfile](./project/Jenkinsfile)


Далее для теста выполняю следующее
- редактирую любой файл в репозитории [GitHub](https://github.com/djohnii/devops-project)
- выполняю команду  ``git add --all && git commit -m "test kube" && git push``
- jenkins автоматически запускает pipeline
  ![alt text](image-2.png)
- выполняю команду  ``git tag mytesttag && git push origin main --tags`` 
- проверяем сборку в [dockerhub](https://hub.docker.com/repository/docker/alwx1753/devops-project/general)
  ![alt text](image-3.png)

![alt text](image-4.png)

#Логи для исправления
Лог Jenkins при комите без тега

```
Started by GitHub push by djohnii
Obtained project/Jenkinsfile from git git@github.com:djohnii/devops-project.git
[Pipeline] Start of Pipeline
[Pipeline] node
Running on centos_docker in /home/jenkins/workspace/devops_build
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Declarative: Checkout SCM)
[Pipeline] checkout
The recommended git tool is: git
using credential 7b1133af-2736-42c6-885f-dcd6a61ab961
Fetching changes from the remote Git repository
 > git rev-parse --resolve-git-dir /home/jenkins/workspace/devops_build/.git # timeout=10
 > git config remote.origin.url git@github.com:djohnii/devops-project.git # timeout=10
Fetching upstream changes from git@github.com:djohnii/devops-project.git
 > git --version # timeout=10
 > git --version # 'git version 2.44.1'
using GIT_SSH to set credentials 
 > git fetch --tags --force --progress -- git@github.com:djohnii/devops-project.git +refs/heads/*:refs/remotes/origin/* # timeout=10
Checking out Revision f1e7f278c31219800176357bc865cb4e184d3b30 (refs/remotes/origin/main)
Commit message: "Update Jenkinsfile_tag"
 > git rev-parse refs/remotes/origin/main^{commit} # timeout=10
 > git config core.sparsecheckout # timeout=10
 > git checkout -f f1e7f278c31219800176357bc865cb4e184d3b30 # timeout=10
 > git rev-list --no-walk f9052d0fde61ec24be3024afaafb7ed9df6e1c0b # timeout=10
[Pipeline] }
[Pipeline] // stage
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
++ git rev-parse @
+ git describe f1e7f278c31219800176357bc865cb4e184d3b30 --tags --abbrev=0
[Pipeline] withEnv
[Pipeline] {
[Pipeline] stage
[Pipeline] { (build docker image)
[Pipeline] script
[Pipeline] {
[Pipeline] dir
Running in /home/jenkins/workspace/devops_build/project/docker
[Pipeline] {
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker build -t alwx1753/devops-project:latest .
#0 building with "default" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 249B done
#1 DONE 0.0s

#2 [internal] load .dockerignore
#2 transferring context: 2B done
#2 DONE 0.0s

#3 [internal] load metadata for docker.io/library/nginx:1.27
#3 DONE 0.9s

#4 [1/3] FROM docker.io/library/nginx:1.27@sha256:6af79ae5de407283dcea8b00d5c37ace95441fd58a8b1d2aa1ed93f5511bb18c
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 61B done
#5 DONE 0.0s

#6 [2/3] COPY index.html /usr/share/nginx/html/
#6 CACHED

#7 [3/3] COPY nginx.conf /etc/nginx/nginx.conf
#7 CACHED

#8 exporting to image
#8 exporting layers done
#8 writing image sha256:7bd75a4bc1fa96a4183c6bbf4657c28cb52e51006fb2749fa36a1c6065290ccd done
#8 naming to docker.io/alwx1753/devops-project:latest done
#8 DONE 0.0s
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (deploy image)
[Pipeline] script
[Pipeline] {
[Pipeline] sh
+ docker images --format '{{.Repository}}:{{.Tag}}' --no-trunc
+ head -n 1
[Pipeline] sh
+ sed -i 's|image:.*|image: alwx1753/devops-project:latest|' project/k8s/myapp/myapp.yml
[Pipeline] withEnv
[Pipeline] {
[Pipeline] withDockerRegistry
$ docker login -u alwx1753 -p ******** https://index.docker.io/v1/
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /home/jenkins/workspace/devops_build@tmp/95f1199f-f76e-467e-a84f-25674cee0b0b/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
[Pipeline] {
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker tag alwx1753/devops-project:latest index.docker.io/alwx1753/devops-project:latest
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker push index.docker.io/alwx1753/devops-project:latest
The push refers to repository [docker.io/alwx1753/devops-project]
d54904491421: Preparing
979aa1490b93: Preparing
60e72fbb314e: Preparing
599e8de62018: Preparing
09581b9299a2: Preparing
a39383416a22: Preparing
a6355e7844d5: Preparing
fcfa12460e7d: Preparing
e0781bc8667f: Preparing
a39383416a22: Waiting
fcfa12460e7d: Waiting
a6355e7844d5: Waiting
e0781bc8667f: Waiting
979aa1490b93: Layer already exists
d54904491421: Layer already exists
60e72fbb314e: Layer already exists
09581b9299a2: Layer already exists
599e8de62018: Layer already exists
a6355e7844d5: Layer already exists
a39383416a22: Layer already exists
fcfa12460e7d: Layer already exists
e0781bc8667f: Layer already exists
latest: digest: sha256:39be527625b1f9b14a39ca6029ac6693989498c034b511b447ddeb8212509713 size: 2192
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // withDockerRegistry
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (deploy to k8s)
[Pipeline] script
[Pipeline] {
[Pipeline] dir
Running in /home/jenkins/workspace/devops_build/project/k8s/myapp
[Pipeline] {
[Pipeline] sh
+ cat ./myapp.yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: myapp
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - image: alwx1753/devops-project:latest
          imagePullPolicy: IfNotPresent
          name: myapp
      terminationGracePeriodSeconds: 30

---
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  ports:
    - name: web
      port: 32001
      targetPort: 80
      # nodePort: 30080
  selector:
    app: myapp
  # type: NodePort
  type: LoadBalancer

[Pipeline] sh
+ kubectl apply -f ./
deployment.apps/myapp unchanged
service/myapp unchanged
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
```

Лог Jenkins при создания нового тега

```

Started by user prey
Obtained project/Jenkinsfile_tag from git git@github.com:djohnii/devops-project.git
[Pipeline] Start of Pipeline
[Pipeline] node
Running on centos_docker in /home/jenkins/workspace/devops_build
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Declarative: Checkout SCM)
[Pipeline] checkout
The recommended git tool is: git
using credential 7b1133af-2736-42c6-885f-dcd6a61ab961
Fetching changes from the remote Git repository
 > git rev-parse --resolve-git-dir /home/jenkins/workspace/devops_build/.git # timeout=10
 > git config remote.origin.url git@github.com:djohnii/devops-project.git # timeout=10
Fetching upstream changes from git@github.com:djohnii/devops-project.git
 > git --version # timeout=10
 > git --version # 'git version 2.44.1'
using GIT_SSH to set credentials 
 > git fetch --tags --force --progress -- git@github.com:djohnii/devops-project.git +refs/heads/*:refs/remotes/origin/* # timeout=10
Checking out Revision bad14df8ff9a5a0f36ae6e4afd3891c5b28073df (refs/remotes/origin/main)
Commit message: "Update Jenkinsfile_tag"
 > git rev-parse refs/remotes/origin/main^{commit} # timeout=10
 > git config core.sparsecheckout # timeout=10
 > git checkout -f bad14df8ff9a5a0f36ae6e4afd3891c5b28073df # timeout=10
 > git rev-list --no-walk 32de6b8844ddbfee42182a0f9346ab018bcfa8f4 # timeout=10
[Pipeline] }
[Pipeline] // stage
[Pipeline] withEnv
[Pipeline] {
[Pipeline] withEnv
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Checkout tag)
[Pipeline] script
[Pipeline] {
[Pipeline] sh
+ git tag --sort=-creatordate
+ head -n 1
[Pipeline] echo
gitTag output: v2.2.04
[Pipeline] dir
Running in /home/jenkins/workspace/devops_build/project/docker
[Pipeline] {
[Pipeline] sh
+ pwd
/home/jenkins/workspace/devops_build/project/docker
[Pipeline] sh
+ ls -la
итого 20
drwxr-xr-x 2 root root 4096 авг  3 15:59 .
drwxr-xr-x 7 root root 4096 авг  3 16:50 ..
-rw-r--r-- 1 root root  210 авг  3 15:59 Dockerfile
-rw-r--r-- 1 root root  114 авг  3 15:59 index.html
-rw-r--r-- 1 root root  323 авг  3 15:59 nginx.conf
[Pipeline] sh
+ docker build -t alwx1753/devops-project:v2.2.04 .
#0 building with "default" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 249B done
#1 DONE 0.0s

#2 [internal] load .dockerignore
#2 transferring context: 2B done
#2 DONE 0.0s

#3 [internal] load metadata for docker.io/library/nginx:1.27
#3 DONE 0.4s

#4 [1/3] FROM docker.io/library/nginx:1.27@sha256:6af79ae5de407283dcea8b00d5c37ace95441fd58a8b1d2aa1ed93f5511bb18c
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 61B done
#5 DONE 0.0s

#6 [2/3] COPY index.html /usr/share/nginx/html/
#6 CACHED

#7 [3/3] COPY nginx.conf /etc/nginx/nginx.conf
#7 CACHED

#8 exporting to image
#8 exporting layers done
#8 writing image sha256:7bd75a4bc1fa96a4183c6bbf4657c28cb52e51006fb2749fa36a1c6065290ccd 0.0s done
#8 naming to docker.io/alwx1753/devops-project:v2.2.04 done
#8 DONE 0.0s
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Push docker image)
[Pipeline] script
[Pipeline] {
[Pipeline] withEnv
[Pipeline] {
[Pipeline] withDockerRegistry
$ docker login -u alwx1753 -p ******** https://index.docker.io/v1/
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /home/jenkins/workspace/devops_build@tmp/e0342cb3-7d75-46ce-b61e-a518efb06ee2/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
[Pipeline] {
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker tag alwx1753/devops-project:v2.2.04 index.docker.io/alwx1753/devops-project:v2.2.04
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker push index.docker.io/alwx1753/devops-project:v2.2.04
The push refers to repository [docker.io/alwx1753/devops-project]
d54904491421: Preparing
979aa1490b93: Preparing
60e72fbb314e: Preparing
599e8de62018: Preparing
09581b9299a2: Preparing
a39383416a22: Preparing
a6355e7844d5: Preparing
fcfa12460e7d: Preparing
e0781bc8667f: Preparing
a6355e7844d5: Waiting
fcfa12460e7d: Waiting
e0781bc8667f: Waiting
a39383416a22: Waiting
09581b9299a2: Layer already exists
d54904491421: Layer already exists
60e72fbb314e: Layer already exists
599e8de62018: Layer already exists
979aa1490b93: Layer already exists
a39383416a22: Layer already exists
e0781bc8667f: Layer already exists
a6355e7844d5: Layer already exists
fcfa12460e7d: Layer already exists
v2.2.04: digest: sha256:39be527625b1f9b14a39ca6029ac6693989498c034b511b447ddeb8212509713 size: 2192
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // withDockerRegistry
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (deploy to k8s)
[Pipeline] script
[Pipeline] {
[Pipeline] dir
Running in /home/jenkins/workspace/devops_build/project/k8s/myapp
[Pipeline] {
[Pipeline] sh
+ sed -i 's|image:.*|image: alwx1753/devops-project:v2.2.04|' myapp.yml
[Pipeline] sh
+ cat ./myapp.yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: myapp
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - image: alwx1753/devops-project:v2.2.04
          imagePullPolicy: IfNotPresent
          name: myapp
      terminationGracePeriodSeconds: 30

---
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  ports:
    - name: web
      port: 32001
      targetPort: 80
      # nodePort: 30080
  selector:
    app: myapp
  # type: NodePort
  type: LoadBalancer

[Pipeline] sh
+ kubectl apply -f ./
deployment.apps/myapp configured
service/myapp unchanged
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
```




# Решение2: Docker, Gitlub , Gitlab CI, ansible kuberspay (не актуально)
##  Docker
репозиторий: https://hub.docker.com/repository/docker/alwx1753/devops-project/general

Dockerfile:
```
#Берем последнюю версию nginx
FROM nginx:latest

#Копируем  файл конфиг который находится рядом с dockerfile и помечаем в папку с nginx
COPY index.html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
#Открываем порт 80 для работы nginx
EXPOSE 80

#Запускаем команду nginx в фоновом режиме
CMD ["nginx", "-g", "daemon off;"] 
# CMD ["nginx", "-g", "daemon off;", "-c", "/etc/nginx/nginx.conf"]
```
Выполняем команды:
```
docker build -t alwx1753/devops-project .
docker tag alwx1753/devops-project:latest alwx1753/devops-project:1.0
docker login
docker push alwx1753/devops-project:1.0
```

Чтобы удалить все запущенные контейнеры а затем образы:
```
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)
```

Решение проблемы с dockerhub
/etc/docker/daemon.json:
```
          {
            "registry-mirrors": [
              "https://mirror.gcr.io",
              "https://daocloud.io",
              "https://c.163.com/",
              "https://huecker.io/",
              "https://registry.docker-cn.com"
            ]
          } 
```
## Kuberspay
У меня уже есть свои 3 виртуальные машины. Поэтому я добавляю данные в devops-project/project/ansible/kubespay/kubespray/inventory/k8s-dev-cluster/inventory.ini
```
[all]
node1 ansible_host=192.168.27.242  ansible_user=root ansible_ssh_port=22 ansible_ssh_private_key_file=/root/.ssh/id_rsanew
node2 ansible_host=192.168.27.149  ansible_user=root ansible_ssh_port=22 ansible_ssh_private_key_file=/root/.ssh/id_rsanew
node3 ansible_host=192.168.27.154  ansible_user=root ansible_ssh_port=22 ansible_ssh_private_key_file=/root/.ssh/id_rsanew
[kube_control_plane]
node1
[etcd]
node1
[kube_node]
node2
node3
[calico_rr]
[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
```
и запускаю плейбук находясь в директории ``devops-project/project/ansible/kubespay/kubespray/``
```
ansible-playbook -i inventory/k8s-dev-cluster/inventory.ini -u root cluster.yml -b -v
```
## Gitlab
Создал новый репозиторий https://gitlab.com/devops9835924/devops-project

```
cd existing_repo
git remote add origin https://gitlab.com/devops9835924/devops-project.git
git branch -M main
git push -uf origin main

```

## Monitoring and web app
Создадим новую область для веб приложения и мониторинга
```
kubectl create namespace monitoring
kubectl get namespace
```

Для создания мониторинга возьмем helm чарт
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install stable prometheus-community/kube-prometheus-stack --namespace=monitoring
kubectl apply -f ingress.yml -n monitoring
 kubectl --namespace monitoring get pods -l "release=stable"
```

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
helm repo update && \
helm install ingress-nginx ingress-nginx/ingress-nginx

или

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/baremetal/deploy.yaml
```

Так как у меня кластер k8s является локаьлныи и не имеет loadbalancer мне необходимо исползовать ingress-nginx и nodeport . Для доступа с другой машины необходимо прописать в файле hosts:

```

192.168.27.242 app.test.com
192.168.27.242 grafana.domen.ru
```

а так же логин и пароль для графана

```
UserName: admin Password: prom-operator
```
![image](https://github.com/djohnii/devops-project/assets/91311426/93c743c6-ad1c-4b72-8915-4436564e19ee)
![image](https://github.com/djohnii/devops-project/assets/91311426/6ab63bfd-7114-42f5-84f6-8d0ef0dc0878)

## CI/CD

GITLAB CI

```
stages:
  - build
  - deploy

build:
  stage: build
  variables: 
    DOCKER_HOST: tcp://docker:2376
    DOCKER_DRIVER: overlay2
  script:
    - docker build -t $CI_REGISTRY_IMAGE ./docker
    - docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    - docker push $CI_REGISTRY_IMAGE

deploy:
  stage: deploy
  script:
    - echo $CI_REGISTRY_IMAGE
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
    - kubectl apply -f ./k8s/myapp.yml
  only:
    - branches
    - tags

```

