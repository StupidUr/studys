# 每日笔记

## 20200917

* Linux免密登录
  * `ssh-keygen -t rsa -P "" -f "/root/.ssh/id_rsa"`
  * `ssh-copy-id -i /root/.ssh/id_rsa.pub root@192.168.1.146`

* 安装K3S

1. 初始化环境

 ```

 # 初始化机器  curl http://dcmx.tjeol.com/os7init.sh | sh -s 主机名
 # 安装Docker  curl http://dcmx.tjeol.com/docker_install.sh | sh

 ```

2. 安装K3S-Server

 ```
# export & unset  设置变量和取消设置变量

curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -

 ```


3. 安装K3S-Agent

 ```

export K3S_TOKEN=XXXXXX

export K3S_URL=https://172.26.146.55:6443

export INSTALL_K3S_EXEC="--docker --kube-apiserver-arg service-node-port-range=1-65000 --no-deploy traefik --write-kubeconfig ~/.kube/config --write-kubeconfig-mode 666"

curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -

 ```

4. 安装Rancher-UI

 ```
docker run -d -v /data/docker/rancher-server/var/lib/rancher/:/var/lib/rancher/ --restart=unless-stopped --name rancher-server -p 443:443 rancher/rancher:stable
 ```

5. 导入集群K3S
  * 导入并忽略后在主分节点上执行导入


* 高可用K3S
  1. 数据库使用mysql，负载均衡nginx（4层）。

 ```

# 安装数据库
docker run --name mysql5.7 --net host --restart=always -e MYSQL_ROOT_PASSWORD=root -d mysql:5.7--lower_case_table_names=1  #创建数据库

# 安装Master

  export INSTALL_K3S_EXEC="--datastore-endpoint=mysql://root:root@tcp(172.17.0.150:3306)/k3s --docker --kube-apiserver-arg service-node-port-range=1-65000 --no-deploy traefik --write-kubeconfig  ~/.kube/config --write-kubeconfig-mode 666"

  同上Server会相同Token 以及一台添加到Rancher就行
# 安装nginx（4层）

stream {
  upstream k3sList {
    server 172.17.0.151:6443;
    server 172.17.0.152:6443;
  }
  server {
    listen 6443;
    proxy_pass k3sList;
  }
}


# 安装Rancher-UI


 ```
