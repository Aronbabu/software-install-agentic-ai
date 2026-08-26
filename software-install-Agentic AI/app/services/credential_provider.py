
import os

def get_windows_credentials():
    return {
        "username": os.getenv("WINRM_USERNAME"),
        "password": os.getenv("WINRM_PASSWORD"),
        "transport": os.getenv("WINRM_TRANSPORT", "ntlm"),
    }

def get_linux_credentials():
    return {
        "username": os.getenv("SSH_USERNAME", "root"),
        "password": os.getenv("SSH_PASSWORD", "root"),
        "port": int(os.getenv("SSH_PORT", "2222")),
        "private_key_path": os.getenv("SSH_PRIVATE_KEY_PATH"),
    }
