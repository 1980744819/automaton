# 使用 Node.js 20 基础镜像
FROM 192.168.1.7:30002/base/node:25-alpine

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 pnpm-lock.yaml 文件
COPY package.json pnpm-lock.yaml ./

# 安装 pnpm
RUN npm install -g pnpm

# 安装依赖
RUN pnpm install

# 复制项目文件
COPY . .

# 构建项目
RUN pnpm build

# 暴露端口
EXPOSE 3000

# 设置环境变量
ENV NODE_ENV=production
# 设置代理
ENV http_proxy=http://192.168.1.7:7890 \
    https_proxy=http://192.168.1.7:7890 \
    no_proxy=localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8

# 运行命令
CMD ["node", "dist/index.js", "--run"]
