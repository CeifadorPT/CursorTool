# Cursor ID Reset Tool

## 🚀 Quick Installation

Open PowerShell as Administrator and run:
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; iwr -Uri "https://raw.githubusercontent.com/CeifadorPT/CursorTool/refs/heads/main/powershellcode.ps1" -UseBasicParsing | iex
```
That's it! The script will handle everything else automatically.

## 🔍 Compatibility

- ✅ Tested on Cursor v0.45.9 and earlier versions

## 🛠️ Features

- 🔄 Automatic backup of existing device IDs
- 🎲 Generation of new random device identifiers
- 🔐 Registry modification handling
- 📝 Detailed logging of changes
- 🔍 Verification of process state

## ⚡ Quick Start

1. Close Cursor completely (including background processes)
2. Run the script with administrator privileges
3. Wait for the process to complete
4. Restart Cursor

## 🚨 Prerequisites

- Windows operating system
- PowerShell 5.1 or later
- Administrator privileges
- Cursor editor must be completely closed

## ⚠️ Important Notes

- **Backup**: The script automatically creates backups of your original device IDs
- **Process Check**: Includes automatic verification that Cursor is not running
- **Registry Changes**: Modifies system registry entries related to device identification

## 🔍 Technical Details

The script manages the following identifiers:
- Machine GUID
- Telemetry Machine ID
- MAC Machine ID
- Device ID
- SQM ID

## 📝 Logging

All changes are logged with timestamps, including:
- Backup file locations
- New generated IDs
- Modified registry entries

## ⚠️ Disclaimer

This tool is provided for educational and research purposes only. Users assume all responsibility for its use. The developer:
- Makes no warranties about the tool's functionality
- Is not responsible for any potential issues
- Does not guarantee compatibility with future Cursor versions

## 🤝 Contributing

Feel free to submit issues and enhancement requests via GitHub.

## 📜 License

[MIT License](LICENSE)

---

💡 **Note**: Always ensure you have a backup of your system before making registry modifications.
