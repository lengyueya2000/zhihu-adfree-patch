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

脚本自动完成:下载依赖(带缓存)→ 校验知乎 APK 的 MD5 → 集成知了模块 →
签名伪造等级 2 → 输出 `output\` 下的修补 APK。

## 安装到手机

1. **先卸载**手机上的原版知乎(签名不同无法覆盖安装;重装需重新登录)
2. 传 `output\` 里的 `*-lspatched.apk` 到手机安装
3. 手机系统设置里**关闭知乎自动更新**(否则商店会把它刷回带广告的原版)
4. 打开知乎,顶栏出现「知了」入口即成功;在知了设置里按需勾选去广告项

## 版本更新后重新修补

知了发布新版本适配新知乎后(见上游 releases),改 `patch.bat` 顶部的
`ZHIHU_URL` / `ZHIHU_MD5` / `ZHILIAO_VERSION` 三个变量,重跑即可。

## 目录约定

- 依赖与缓存固定放在 `G:\nixang\huanjing`(本机软件环境根目录,不装 C 盘):
  - `G:\nixang\huanjing\lspatch\lspatch.jar`
  - `G:\nixang\huanjing\lspatch\Zhiliao_*.apk`
  - `G:\nixang\huanjing\installers\zhihu-*.apk`
- Java 21(已在本机 PATH)

## 注意

- 知乎 APK 直链来自豌豆荚历史版本页,仅作个人去广告用途缓存,不入库
- 补丁签名是自签名的,微信/QQ 授权登录、设备指纹等可能受影响,介意请用手机号登录
- 仅供个人学习研究,APK 版权归知乎所有
