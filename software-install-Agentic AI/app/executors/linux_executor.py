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
    port = job.target_port

    # ✅ NEW: get structured policy
    policy = get_execution_command("linux", job.software_name, job.software_version)

    install_cmd = policy["install"]
    verify_cmd = policy["verify"]

    start = time.time()

    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        print(
            f"HOST={host}, "
            f"PORT={job.target_port}, "
            f"CONNECTION={job.connection_method}",
            print("DEBUG"),
            print("HOST", job.target_host),
            print("PORT", job.target_port),
            print("METHOD", job.connection_method)
        )
        client.connect(
            hostname=host,
            port=port,
            username=username,
            password=password,
            timeout=job.timeout_seconds or 300
        )

        # ✅ STEP 1: INSTALL
        print(f"INSTALL CMD: {install_cmd}")
        stdin, stdout, stderr = client.exec_command(install_cmd)
        print("WAITING FOR INSTALL TO COMPLETE")
        exit_code = stdout.channel.recv_exit_status()
        print(f"INSTALL EXIT CODE = {exit_code}")

        install_out = stdout.read().decode(errors="ignore")
        install_err = stderr.read().decode(errors="ignore")

        print(f"INSTALL STDOUT = {install_out}")
        print(f"INSTALL STDERR = {install_err}")

        
        # ✅ STEP 2: VERIFY
        print(f"VERIFY CMD = {verify_cmd}")
        stdin, stdout, stderr = client.exec_command(verify_cmd)
        verify_output = stdout.read().decode(errors="ignore")

        # ✅ ✅ CORE LOGIC (IMPORTANT)
        success = False
        if job.software_name.lower() in verify_output:
            success = True
        print(f"VERIFY OUTPUT = {verify_output}")
        duration = round(time.time() - start, 2)

        return ExecutionResult(
            success=success,
            exit_code=exit_code,
            stdout=verify_output,
            stderr=install_err,
            duration_seconds=duration,
            transport="ssh"
        )
    except Exception as ex:
            print(f"EXECUTION ERROR = {str(ex)}")

            return ExecutionResult(
                success=False,
                exit_code=-1,
                stdout="",
                stderr=str(ex),
                duration_seconds=round(time.time() - start, 2),
                transport="ssh"
            )
    finally:
        client.close()
