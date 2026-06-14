# geph5 Client for OpenWrt (含 LuCI 界面)

[](https://www.google.com/search?q=https://opensource.org/licenses/MIT)

本项目为 OpenWrt 路由器提供 [geph5 (迷雾通 5)](https://www.google.com/search?q=https://github.com/geph-official/geph5) 客户端的本地化运行支持，并包含一个用户友好的 LuCI Web 图形配置界面。

**本项目具备极高的安全性与透明度：** 不包含任何预编译的二进制文件。编译时将通过 OpenWrt 官方构建系统自动从 `crates.io` 拉取最新的官方源码并进行现场交叉编译。

## ✨ 核心特性

  * **原生 LuCI 集成**：提供完整的图形化配置界面，无需手动修改底层 YAML 文件。
  * **多实例并发 (Multi-Instance)**：原生支持配置和运行多个 geph5 实例（例如同时连接 TW 和 JP 节点），基于 OpenWrt `procd` 守护进程，各个实例互不干扰。
  * **CDN77 域前置抗封锁**：独家支持手动指定 CDN77 未被阻断的 IP 地址（UI 层面智能拼接 443 端口），在严苛网络环境下保证连通性。
  * **安全默认设置**：代理端口默认绑定于 `127.0.0.1`，仅限路由器内部网络调用（如搭配 PassWall / OpenClash 作为前置节点使用），防止局域网越权访问。
  * **动态配置生成与守护**：服务启动时实时将 UCI 配置转换为 geph5 所需的 YAML 格式（挂载于内存盘 `/var/etc/`），并支持修改配置后热重载（Hot-reload）及崩溃自动重启。

## 📦 安装与使用 (普通用户)

1.  前往本项目的 [Releases 页面](https://github.com/program-thinked/luci-app-geph5/releases) 下载对应你路由器架构的 `.ipk` 安装包（提供 x86\_64, aarch64, mipsel 等多架构支持）。
2.  将 `.ipk` 文件通过 SCP 上传至路由器的 `/root` 目录。
3.  SSH 登录路由器并执行安装：
    ```bash
    opkg install /root/luci-app-geph5_*.ipk
    ```
4.  登录路由器的 OpenWrt Web 后台。
5.  导航至 **服务 (Services) -\> geph5**。
6.  点击“添加”创建实例，填入你的 Secret 凭证，按需调整 CDN77 IP 和代理端口，勾选“启用”，点击 **保存并应用** 即可。

## 🛠️ 编译指南 (开发者)

本项目完美融入 OpenWrt Buildroot (SDK) 构建系统。由于底层采用 Rust 编写，你需要确保编译环境中已安装 Rust 工具链。

### 第一步：准备编译环境

在你的 Ubuntu/Debian 或 ArchLinux 宿主机上安装必要的依赖，以及 Rust 工具链：

```bash
# 安装 Rust (如果尚未安装)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 根据你的目标路由器架构，添加 Rust Target (例如编译给 x86_64 软路由)
rustup target add x86_64-unknown-linux-musl
```

### 第二步：克隆源码并编译

进入你的 OpenWrt SDK 根目录，执行以下命令：

```bash
# 将本仓库克隆到 SDK 的 package 目录下
git clone https://github.com/program-thinked/luci-app-geph5.git package/luci-app-geph5

# 启动编译 (系统会自动下载 crates.io 源码并现场构建)
make package/luci-app-geph5/compile V=s
```

编译成功后，安装包将生成在 `bin/packages/<架构>/base/` 目录下。

## 🤖 GitHub Actions 自动化构建

本项目已配置完整的 CI/CD 流水线。只需修改 `Makefile` 中的 `PKG_VERSION` 并推送到 GitHub，云端服务器将自动并行构建适用于 `x86_64`、`ARM64` (树莓派等) 架构的 `.ipk` 安装包。

## 📝 进阶排错

  * **查看运行状态**：在路由器终端输入 `ps | grep geph5` 查看后台进程状态。
  * **查看实时日志**：使用 `logread -f -e geph5` 查看程序输出的握手与连接日志。
  * **查看生成的底层配置**：动态生成的 YAML 文件存放在路由器的 `/var/etc/` 目录下（如 `/var/etc/geph5_main.yaml`）。

## 📄 许可协议

本项目基于 [MIT License](https://www.google.com/search?q=LICENSE) 协议开源。允许任何形式的商业使用、修改和分发，但需保留原作者版权声明。
