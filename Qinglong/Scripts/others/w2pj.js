const w2ck = "htVD_2132_saltkey=Ow311wBi; htVD_2132_visitedfid=74; htVD_2132_st_p=0|1625327290|9d191c13fab0a7e4032a0bee35f95afa; htVD_2132_viewid=tid_1023840; htVD_2132_seccodecS=1151932.bfc7387d2993e3fcf8;  htVD_2132_con_request_uri=https://www.52pojie.cn/connect.php?mod=login&op=callback&referer=https%3A%2F%2Fwww.52pojie.cn%2F; htVD_2132_client_created=1625327458; htVD_2132_client_token=D43BD5BF96AC4C1FF9EC4CC50BF9C33B; htVD_2132_auth=4cd5ohwP/KEXazAHM4rpwQX/aj85EZ11SQLF/ub0cUqG//acat/GlmBDmRbpi5R63R6L3o/DxTQRzbooXG7ZpUJ97vw; htVD_2132_connect_login=1; htVD_2132_connect_is_bind=1; htVD_2132_connect_uin=D43BD5BF96AC4C1FF9EC4CC50BF9C33B; htVD_2132_stats_qc_login=3; htVD_2132_sid=0; htVD_2132_nofavfid=1; htVD_2132_ulastactivity=1625328967|0; htVD_2132_noticeTitle=1; htVD_2132_lastact=1625329290	home.php	task"
const axios = require("axios")
function w2sign() {
    return new Promise(async (resolve) => {
            try {
                let url = `https://www.52pojie.cn/home.php?mod=task&do=apply&id=2`
                let res = await axios.get(url, {
                        headers: {
                            "cookie": w2ck               
                    },
                    responseType: 'arraybuffer'
             }   )
            const data = require("iconv-lite").decode(res.data, 'gb2312')
            if (data.match(/您需要先登录才能继续本操作/)) {
              w2result ="⚠️⚠️签到失败,cookie失效⚠️⚠️"                
            } else if (data.match(/已申请过此任务/)) {
                w2result="今日已签☑️"
            } else if (data.match(/恭喜/)) {
              w2result="签到成功✅"
             
            } else {             
              w2result="签到失败,原因未知❗️"               
            }
         console.log(w2result)
        } catch (err) {
            console.log(err);
            w2result="签到请求失败️"  
        }
        resolve("【吾爱破解每日签到】："+w2result);
    });
}

//task()
module.exports = w2sign