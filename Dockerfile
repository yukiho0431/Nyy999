# -------------------------------------------
# 基于 yunjiu99 的方法二：使用预构建镜像 (版本及时更新版)
# -------------------------------------------
FROM ghcr.io/yu2051/jiuguan002:latest

# 切换到 root 用户来安装工具
USER root

# 1. 安装 git 和其他必要工具
RUN apk add --no-cache gettext git

# 2. 【核心修复】解决 Zeabur 挂载硬盘后的 Git 权限报错
# 这行命令告诉 Git：信任所有目录，不要报 dubious ownership 错误
RUN git config --system --add safe.directory '*'

# 3. 创建数据目录
RUN mkdir -p /home/node/app/data

# 4. 复制配置文件和启动脚本
# (注意：如果你是从 Nyy Fork 的，可能没有这俩文件，请务必新建)
COPY config.template.yaml /home/node/app/config.template.yaml
COPY entrypoint.sh /home/node/app/entrypoint.sh

# --- 安装云端备份插件 (Cloud Saves) ---
ARG PLUGINS_DIR=/home/node/app/plugins
RUN mkdir -p ${PLUGINS_DIR}
WORKDIR ${PLUGINS_DIR}
RUN git clone https://github.com/yukiho0431/cloud-saves
WORKDIR ${PLUGINS_DIR}/cloud-saves
RUN npm install
# ------------------------------------

# 5. 回到工作目录
WORKDIR /home/node/app

# 6. 修复启动脚本的换行符问题 (防止 Windows 上传导致的报错)
RUN sed -i 's/\r$//' entrypoint.sh && chmod +x entrypoint.sh

# 7. 修复文件权限
RUN chown -R node:node /home/node/app

# 8. 切换回普通用户启动
USER node
ENTRYPOINT ["./entrypoint.sh"]
