# 🚀 项目启动状态

## 启动时间
$(date '+%Y-%m-%d %H:%M:%S')

## ✅ 服务状态

### 后端服务器
- **状态**: ✅ 运行中
- **进程ID**: $(ps aux | grep 'bin/server' | grep -v grep | awk '{print $2}')
- **端口**: 8080
- **健康检查**: $(curl -s http://localhost:8080/health | head -1)
- **日志**: /tmp/gymates_backend.log

### Flutter应用
- **状态**: ⏳ 正在启动
- **目标设备**: Android模拟器 (emulator-5554)
- **Android版本**: Android 16 (API 36)
- **架构**: android-arm64

## 📱 可用设备

$(flutter devices 2>&1 | grep -E "(emulator|device)" | head -3)

## 🎯 启动命令

### 启动后端
```bash
cd backend && ./bin/server > /tmp/gymates_backend.log 2>&1 &
```

### 启动Flutter应用
```bash
cd gymates_flutter && flutter run -d emulator-5554
```

## 📝 检查命令

### 检查后端状态
```bash
curl http://localhost:8080/health
tail -f /tmp/gymates_backend.log
```

### 检查Flutter进程
```bash
ps aux | grep "flutter run"
```

## ⚠️ 注意事项

1. 首次启动可能需要几分钟时间编译
2. 应用会自动安装到模拟器
3. 如果遇到问题，可以查看日志文件
