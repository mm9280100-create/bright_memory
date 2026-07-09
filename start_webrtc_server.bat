@echo off
cd /d E:\br_memory_2026
echo Starting BR Memory WebRTC signaling server...
echo Keep this window open while both mobile apps are calling.
C:\development\flutter\bin\dart.bat tools\webrtc_signaling_server.dart
pause
