🛠️ Windows Repair & Deep Cleanup Script

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-support-yellow.svg?style=for-the-badge&logo=buy-me-a-coffee)](https://buymeacoffee.com/drowfear)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support-ff5e5b.svg?style=for-the-badge&logo=ko-fi)](https://ko-fi.com/drowfear)


A lightweight, automated Batch script designed to repair, optimize, and clean up Windows operating systems. By combining Microsoft’s recommended diagnostic tools into a single execution sequence, this script restores system stability and frees up valuable disk space without needing third-party software.


✨ Key Features
DISM Image Repair: Scans, verifies, and restores corrupted Windows system image files directly via Windows Update.

SFC System Scan: Performs an in-depth System File Checker (sfc /scannow) pass to repair damaged or missing core system files.

WinSxS Optimization: Cleans up superseded component store files (/ResetBase) to recover significant SSD/HDD storage.

Non-Intrusive Disk Check: Runs a fast live scan (chkdsk C: /scan) to catch file system errors without forcing a reboot.

Cache & Temp File Purge: Safe removal of temporary system files, Prefetch data, and stuck/corrupted Windows Update download caches.

Network Stack Reset: Flushes the DNS cache and resets Winsock and TCP/IP protocols to fix common connectivity issues.

🚀 How to Use
Download or copy windows_repair_script.bat.

Right-click the file and select Run as administrator.

Follow the on-screen prompts and reboot your PC once completed.

Disclaimer: Always run maintenance tools with administrator privileges. A system reboot is recommended after completion to finalize network and service changes.

## ☕ Support the Project

If this script saved you time and clicks, consider supporting my work!

👉 **[buymeacoffee.com/drowfear](https://buymeacoffee.com/drowfear)**
👉 **[ko-fi.com/drowfear](https://ko-fi.com/drowfear)**
