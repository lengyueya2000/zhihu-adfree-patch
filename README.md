# 知乎免 root 去广告一键修补 (zhihu-adfree-patch)

用 [LSPatch](https://github.com/JingMatrix/LSPatch) 把去广告 Xposed 模块
[知了 Zhiliao](https://github.com/shatyuka/Zhiliao) 集成进知乎官方 APK,
**无需 root**,生成一个自包含的去广告知乎安装包(集成模式,模块内嵌,不依赖管理器)。

- 知乎版本: `10.86.0` (MD5 `08fb7728352bf31438456f22d73a86c4`)
- 知了版本: `26.02.03` (官方 release,声明兼容知乎 10.86.0)
- LSPatch: `v1.2` (JingMatrix 维护的社区 fork,支持 Android 9+)

## 使用

本机(Windows,依赖已装好)直接双击或命令行运行:

```bat
patch.bat
```

脚本自动完成:下载依赖(带缓存)→ 校验知乎 APK 的 MD5 →
**把知了模块里的签名白名单改成本次修补的签名** → 集成知了模块 →
签名伪造等级 2 → 输出 `output\` 下的修补 APK。

### 为什么需要 patch_zhiliao.py(重要)

知了模块硬编码了**知乎官方证书的 SHA1** 指纹,签名不匹配时所有 hook 静默跳过
(表现为:知乎能打开,但广告照旧/知了入口消失)。LSPatch 修补后的 APK 必然重签名,
所以脚本会先从 `lspatch.jar` 里提取其内置签名证书,把知了 dex 里的 20 字节
白名单常量替换为新证书的 SHA1,并修正 dex 头部校验和。

## 安装到手机(真机,arm64)

1. **先卸载**手机上的原版知乎(签名不同无法覆盖安装;重装需重新登录)
2. 传 `output\` 里的 `*-lspatched.apk` 到手机安装
3. 手机系统设置里**关闭知乎自动更新**(否则商店会把它刷回带广告的原版)
4. 打开知乎,顶栏出现「知了」入口即成功;在知了设置里按需勾选去广告项

## 已知限制:模拟器不可用

在雷电 9(Android 9,x86_64 + houdini ARM 转译)实测:

- 修补包装装成功,知了模块正常加载(签名补丁生效)
- 但知乎卡死在启动页;换旧版 LSPatch v0.6 则直接 SIGSEGV 闪退
- 对照组:同一模拟器安装**原版知乎一切正常** → 问题在 LSPatch 的
  native hook 层(Vector/Dobby)与 x86_64→ARM 转译不兼容,属已知共性限制

**结论:请勿在模拟器使用,真机(arm64)是 LSPatch 的设计目标环境。**

## 版本更新后重新修补

知了发布新版本适配新知乎后(见上游 releases),改 `patch.bat` 顶部的
`ZHIHU_URL` / `ZHIHU_MD5` / `ZHIHU_VER` / `ZHILIAO_VERSION` 四个变量,重跑即可。
注意:新版本知了的 dex 里白名单常量位置可能变化,`patch_zhiliao.py` 会校验
旧常量恰好出现 1 次,不符时报错退出(需要人工重新定位)。

## 目录约定

- 依赖与缓存固定放在 `G:\nixang\huanjing`(本机软件环境根目录,不装 C 盘):
  - `G:\nixang\huanjing\lspatch\lspatch.jar`
  - `G:\nixang\huanjing\lspatch\Zhiliao_*.apk`
  - `G:\nixang\huanjing\installers\zhihu-*.apk`
- Java 21 + Python 3(已在本机 PATH),keytool 需在 PATH(脚本用其导出证书)

## 注意

- 知乎 APK 直链来自豌豆荚历史版本页,仅作个人去广告用途缓存,不入库
- 补丁签名是 LSPatch 内置证书,微信/QQ 授权登录、设备指纹等可能受影响,介意请用手机号登录
- 仅供个人学习研究,APK 版权归知乎、知了作者所有
