### 第一部分：Docker拉取青龙映像，我个人用群晖docker创建容器命令：

容器1：

```dockerfile
docker run -dit \
   -v /volume1/docker/qinglong/config:/ql/config \
   -v /volume1/docker/qinglong/log:/ql/log \
   -v /volume1/docker/qinglong/db:/ql/db \
   -v /volume1/docker/qinglong/scripts:/ql/scripts \
   -v /volume1/docker/qinglong/jbot:/ql/jbot \
   -v /volume1/docker/qinglong/repo:/ql/repo \
   -v /volume1/docker/qinglong/raw:/ql/raw \
   -v /volume1/docker/qinglong/ninja:/ql/ninja \
   -p 5700:5700 \
   -p 5701:5701 \
   -e ENABLE_HANGUP=true \
   -e ENABLE_WEB_PANEL=true \
   -e TZ=CST-8 \
   --name qinglong \
   --hostname qinglong \
   --restart always \
   whyour/qinglong:latest
```

ql update 执行后面板打不开的，执行 docker exec -it qinglong nginx -c /etc/nginx/nginx.conf 试试

容器2：

```dockerfile
docker run -dit \
   -v /volume1/docker/qinglong2/config:/ql/config \
   -v /volume1/docker/qinglong2/log:/ql/log \
   -v /volume1/docker/qinglong2/db:/ql/db \
   -v /volume1/docker/qinglong2/scripts:/ql/scripts \
   -v /volume1/docker/qinglong2/jbot:/ql/jbot \
   -v /volume1/docker/qinglong2/repo:/ql/repo \
   -v /volume1/docker/qinglong2/raw:/ql/raw \
   -v /volume1/docker/qinglong2/ninja:/ql/ninja \
   -p 5710:5700 \
   -p 5711:5701 \
   -e ENABLE_HANGUP=true \
   -e ENABLE_WEB_PANEL=true \
   -e TZ=CST-8 \
   --name qinglong2 \
   --hostname qinglong2 \
   --restart always \
   whyour/qinglong:latest
```

### 第二部分：Ninja 的安装方法(参考 Faker)：

① 进入容器

```dockerfile
docker exec -it qinglong bash
cd /ql
```

注：qinglong 为容器名称

② 如果之前安装过 ninja 的，先结束进程并清空文件夹。如果没有则从第 ③ 步开始执行：

```dockerfile
ps -ef|grep ninja|grep -v grep|awk '{print $1}'|xargs kill -9 && rm -rf /ql/ninja
```

③ 拉取 ninja 仓库并安装必要的局部依赖

```
国内机：git clone -b main https://ghproxy.com/https://github.com/MoonBegonia/ninja.git /ql/ninja  ## 拉取仓库
国外机：git clone -b main https://github.com/MoonBegonia/ninja.git /ql/ninja  ## 拉取仓库
cd /ql/ninja/backend
pnpm install  ## 安装局部依赖
cp sendNotify.js /ql/scripts/sendNotify.js ## 复制通知脚本到青龙容器
```

④ 启动 Ninja 服务

```
pm2 start
```

⑤ 将自动更新 ninja、启动 ninja 命令添加到青龙 configs 文件夹的 extra.sh 文件，实现开机自动更新和启动

```
cd /ql/ninja/backend && git checkout . && git pull && pnpm install && pm2 start && cp sendNotify.js /ql/scripts/sendNotify.js
```

### 第三部分 Ninja 环境变量

目前支持的环境变量有：

```
ALLOW_ADD: 是否允许添加账号 不允许添加时则只允许已有账号登录（默认 true）
ALLOW_NUM: 允许添加账号的最大数量（默认 40）
PORT: Ninja 运行端口（默认 5701）
NOTIFY: 是否开启通知功能（默认 true）
UA: 自定义 UA，默认为随机
```

配置方式：

```
cd /ql/ninja/backend
cp .env.example .env
vi .env  ## 编辑 ninja 的环境变量
pm2 start
```

修改完成后需要 pm2 start 重启生效 ！！！

### 第四部分 番外

青龙机器人 更新 Ninja 命令

```dockerfile
/cmd cd /ql/ninja/backend && git checkout . && git pull && pnpm install && pm2 start && cp sendNotify.js /ql/scripts/sendNotify.js &
```

