#!/usr/bin/env bash
app_name='mall-admin'
docker stop ${app_name}
echo '----停止容器----'
docker rm ${app_name}
echo '----销毁容器----'
docker rmi `docker images | grep none | awk '{print $3}'`
echo '----rm none images----'
docker run -p 8080:8080 --name ${app_name} \
--link mysql:db \
--link nacos-registry:nacos-registry \
-e TZ="Asia/Shanghai" \
-v /etc/localtime:/etc/localtime \
-v /mydata/app/${app_name}/logs:/var/logs \
-d mall/${app_name}:1.0-SNAPSHOT
echo '----启动容器----'