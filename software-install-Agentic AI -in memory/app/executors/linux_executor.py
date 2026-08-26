import time
import paramiko

from app.executors.result_models import ExecutionResult
from app.services.credential_provider import get_linux_credentials
from app.services.execution_policy import get_execution_command


def run_linux(job):
    creds = get_linux_credentials()

    host = job.target_host
    username = creds["username"]
    password = creds["password"]
    port = creds["port"]

    # ✅ NEW: get structured policy
    policy = get_execution_command("linux", job.software_name, job.software_version)

    install_cmd = policy["install"]
    verify_cmd = policy["verify"]

    start = time.time()

    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        client.connect(
            hostname=host,
            port=port,
            username=username,
            password=password,
            timeout=job.timeout_seconds or 300
        )

        # ✅ STEP 1: INSTALL
        stdin, stdout, stderr = client.exec_command(install_cmd)
        exit_code = stdout.channel.recv_exit_status()

        install_out = stdout.read().decode(errors="ignore")
        install_err = stderr.read().decode(errors="ignore")

        # ✅ STEP 2: VERIFY
        stdin, stdout, stderr = client.exec_command(verify_cmd)
        verify_output = stdout.read().decode(errors="ignore")

        # ✅ ✅ CORE LOGIC (IMPORTANT)
        success = False
        if job.software_name.lower() in verify_output:
            success = True

        duration = round(time.time() - start, 2)

        return ExecutionResult(
            success=success,
            exit_code=exit_code,
            stdout=verify_output,
            stderr=install_err,
            duration_seconds=duration,
            transport="ssh"
        )

    finally:
        client.close()