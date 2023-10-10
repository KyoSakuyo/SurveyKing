FROM maven:3.6.0-jdk-8-slim as build

ENV WEB_PATH /home/surveyking

COPY ./server $WEB_PATH
WORKDIR $WEB_PATH

# 这步是构建镜像的时候编译代码
# 如果在构建时编译时间过长，也可以将此命令注释，在本机进行构建

RUN mvn clean package -DskipTests -Ppro

FROM alpine

RUN apk add --update --no-cache openjdk8 \
    && rm -f /var/cache/apk/*

ENV WEB_PATH /home/surveyking
WORKDIR $WEB_PATH
COPY . $WEB_PATH

# 此命令是将上一个静像编译好的目标文件复制到我们的工作目录
# 如果你编译是在本机进行，此命令也一同注释即可
COPY --from=build /home/surveyking/api/target/ $WEB_PATH/server/api/target

# 这里要注意的是，运行的 surveyking-v0.3.0-beta.7.jar 包，要根据当前编译后的版本号来修改启动命令

RUN echo '#!/bin/sh' >> start.sh \
    && echo "java -jar ./server/api/target/surveyking-v0.3.0-beta.7.jar" >> start.sh

CMD ["sh", "start.sh"]
