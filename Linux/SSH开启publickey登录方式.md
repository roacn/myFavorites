# SSH开启public key登录方式



### 1、生成公钥和私钥

```bash
ssh-keygen -t rsa
```

生成的私钥保存在 `/root/.ssh/id_rsa` , 公钥在 `/root/.ssh/id_rsa.pub`

```bash
root@Debian:/opt# ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:JO0RwQWnATReerVkk5Apik3+lY3Ykkl9ORSWxy0tck8 root@Debian
The key's randomart image is:
+---[RSA 3072]----+
|     .++===..=OO |
|       o+*o.==%oE|
|      .=+o +.X.* |
|      .+=.+.= o .|
|        S. o .   |
|          .      |
|                 |
|                 |
|                 |
+----[SHA256]-----+
```



### 2、上传公钥到远程服务器

远程服务器编辑`/etc/ssh/sshd_config`文件

```bash
RSAAuthentication yes
PubkeyAuthentication yes
```

本地客户端输入

```bash
ssh-copy-id <user>@<host>
```

将公钥上传到远程服务器的`/root/.ssh/authorized_keys`



此时，用ssh <user>@<host>就可以不用输入密码直接登录远程服务器了。

```shell
root@Debian:/opt/backup# ssh root@192.168.1.3
Linux pve 5.15.30-1-pve #1 SMP PVE 5.15.30-1 (Tue, 29 Mar 2022 10:36:02 +0200) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sun Apr 10 22:17:19 2022 from 192.168.1.8
```

