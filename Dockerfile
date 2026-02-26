# 使用 Node.js 20 基础镜像
FROM 192.168.1.7:30002/base/node:25-alpine

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV NODE_ENV=production
# 设置代理
ENV http_proxy=http://192.168.1.7:7890 \
    https_proxy=http://192.168.1.7:7890 \
    # 设置 node-gyp 下载源，加速 Node.js 头文件下载
    NODE_DIST_URL=https://npmmirror.com/mirrors/node \
    NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/ \
    no_proxy=localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8

# 设置国内镜像代理
# 1. 设置 Alpine 包管理镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# 2. 安装构建依赖（用于 node-gyp 编译原生模块）
RUN apk add --no-cache \
    python3 \
    py3-pip \
    make \
    gcc \
    g++ \
    libc-dev \
    sqlite-dev

# 3. 设置 npm 镜像源
RUN npm config set registry https://registry.npmmirror.com

# 复制 package.json 和 pnpm-lock.yaml 文件
COPY package.json pnpm-lock.yaml ./

# 安装 pnpm
RUN npm install -g pnpm

# 设置 pnpm 镜像源
RUN pnpm config set registry https://registry.npmmirror.com

# 安装依赖
RUN pnpm install

# 复制项目文件
COPY . .

# 构建项目
RUN pnpm build

# 暴露端口
EXPOSE 3000

# 运行命令
CMD ["node", "dist/index.js", "--run"]
