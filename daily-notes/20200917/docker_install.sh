#!/bin/sh
set -e
# 在线安装脚本

# k3s 不建议安装swap 系统内存小的时候没有swap会卡死
if [ ! -f "/var/swap" ];then
    echo "create swap"
    dd if=/dev/zero of=/var/swap bs=1024 count=8192000
    mkswap /var/swap
    mkswap -f /var/swap
    swapon /var/swap
    echo  "/var/swap swap swap defaults 0 0" >>  /etc/fstab
fi

# 判断是否安装 docker
if [ `command -v docker` ];then
    echo 'docker has installed'
else
    echo 'install docker'
    curl https://download.daocloud.io/docker/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
    yum -y install https://download.daocloud.io/docker/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
    curl -fsSL https://get.daocloud.io/docker | bash -s docker --mirror Aliyun
    # centos7 的内核经过 k3s 检查都有这个问题
    grubby --args="user_namespace.enable=1" --update-kernel="$(grubby --default-kernel)"
fi
# 添加加速源
sudo mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{"registry-mirrors":["https://05bcia8v.mirror.aliyuncs.com"],"insecure-registries":[]}
EOF
# 启动
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

echo 'finish'