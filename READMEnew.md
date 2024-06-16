# Дипломная работа

[Весь код в директории](./project/)
[terraform](./project/terraform)
[terraform-k8s](./project/terraform/k8s)
[k8s](./project/k8s)
[docker](./project/docker)
# Решение1: Docker, Gitlub , Gitlab CI, ansible kuberspay
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
# Решение2 Jenkins, Github, k8s_yandex_cloud
##  k8s_yandex_cloud
Создаю кластер kubernetes и  узлы используя [terraform](./project/terraform/k8s/)
```
terraform init
terraform apply --auto-approve
```
После создания кластера на сервере с предустановленным yandex CLI , чтобы получить конфиг файл кластера k8s по пути ``~/.kube/config`` необходимо выполнить команду:
```
yc managed-kubernetes cluster get-credentials --id catca7qm6373qprq6ik4 --external
```
### Настраиваем кластер k8s для работы jenkins
- создаем новую область для работы jenkins
  ```
  -kubectl create namespace jenkins
  ```
- создаем пользователя и токен ключ для работы jenkins 
  ```
  kubectl create sa jenkins -n jenkins
  kubectl create token jenkins -n jenkins --duration=8760h
- добавляем роль 
  ```
  kubectl create rolebinding jenkins-admin-binding --clusterrole=admin --serviceaccount=jenkins:jenkins --namespace=jenkins
  ```
Теперь можно вывести конфиг командой ``kubectl config view``
## Github
- Создал [GitHub](https://github.com/djohnii/devops-project) репозиторий 
- Настроил webhooks в [github](https://github.com/djohnii/devops-project/settings/hooks)
  ![alt text](image.png)
## Jenkins
- Развернул виртуальную машину с белым ip чтобы работали webhooks в github.
- установил несколько плагинов: [kubernetes](https://plugins.jenkins.io/kubernetes-cli/),[docker](https://plugins.jenkins.io/docker-worcflow),[github](https://plugins.jenkins.io/github-api/) [Blue Ocean](https://plugins.jenkins.io/blueocean/)
- настроил kubernetes cloud 
  ![alt text](image-1.png)
- написал [jenkinsfile](./project/Jenkinsfile)

Далее для теста выполняю следующее
- редактирую любой файл в репозитории [GitHub](https://github.com/djohnii/devops-project)
- выполняю команду  ``git add --all && git commit -m "test kube" && git push``
- jenkins автоматически запускает pipeline
  ![alt text](image-2.png)
- выполняю команду  ``git tag mytesttag $$ git push --tags``  и снова ``git push``
- проверяем сборку в [dockerhub](https://hub.docker.com/repository/docker/alwx1753/devops-project/general)
  ![alt text](image-3.png)

![alt text](image-4.png)




