### code.sh

特别鸣谢：风之凌殇 大佬。

其用 Nodejs 变量转换方法，解决了 Shell 环境变量参数长度过短的问题，从源头上解决了 Argument list too long 的问题。

该项目地址：
https://gist.github.com/fzls/14f8d1d3ebb2fef64750ad91d268e4f6

必读一：
名称：格式化更新互助码
命令：task /ql/config/code.sh
定时规则：10 * * * *

必读二：
互助码和互助规则文件路径调整至/ql/log/.ShareCode；备份路径调整至/ql/log/.bak_ShareCode/。
这两个文件夹会自动创建。可以通过面板-任务日志查看。

必读三：
task_before.sh不再负责互助码和互助规则的导入，只负责读取 /ql/log/.ShareCode 的文件并格式化成全局互助变量提交给活动脚本。

必读四：
code.sh 和 task_before.sh 还是仍旧存放在 /ql/config/ 路径不变。



Build 20211122-003
1、新增车头B模式(随机部分账号顺序固定)。注：之前的车头模式改名为车头A模式(随机账号顺序随机)。



Build 20211122-002
1、支持自动将 /ql/config/路径下的魔改版 
jdCookie.js 强制覆盖到 /ql/scripts/ 路径和子目录下所有的 jdCookie.js 。



Build 20211122-001
1、上线车头模式，支持自定义前N个账号被优先助力，N个以后账号随机助力；
2、添加 风之凌殇 大佬 魔改版 jdCookie.js 自动复制到 /ql/deps/路径的脚本。需提前将 魔改版 jdCookie.js 拷贝到 /ql/config/ 路径。



### task_before.sh

Build 20211122-001
1、集成 风之凌殇 大佬 利用 Nodejs 解决 Argument list too long 的相关代码。须配合魔改版 jdCookie.js 使用；



### config_sample.sh

Build 20211009-001
暂未更新内容



### jdCookie.sh

风之凌殇 魔改版 jdCookie.js 。提前将 魔改版 jdCookie.js 拷贝到 /ql/config/ 路径，新版 code.sh 可自动将其拷贝至 /ql/deps/ 路径并且强制覆盖到 /ql/scripts/ 路径和子目录下所有的 jdCookie.js
