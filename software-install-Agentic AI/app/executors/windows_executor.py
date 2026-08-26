import time
import winrm

from app.executors.result_models import ExecutionResult
from app.services.credential_provider import get_windows_credentials
from app.services.execution_policy import get_execution_command


def run_windows(job):
    creds = get_windows_credentials()

    host = job.target_host
    username = creds["username"]
    password = creds["password"]
    transport = creds["transport"]

    # ✅ Get structured policy
    policy = get_execution_command("windows", job.software_name, job.software_version)

    install_cmd = policy["install"]
    verify_cmd = policy["verify"]

    start = time.time()

    # ✅ Create WinRM session
    try:
        session = winrm.Session(
            target=host,
            auth=(username, password),
            transport=transport,
            server_cert_validation="ignore"
        )
    except Exception as e:
        return ExecutionResult(
            success=False,
            exit_code=1,
            stdout="",
            stderr=str(e),
            duration_seconds=0,
            transport="winrm"
        )

    # ✅ STEP 1 — INSTALL
    install_result = session.run_ps(install_cmd)

    install_stdout = install_result.std_out.decode(errors="ignore") if install_result.std_out else ""
    install_stderr = install_result.std_err.decode(errors="ignore") if install_result.std_err else ""

    # ✅ STEP 2 — VERIFY
    verify_result = session.run_ps(verify_cmd)
    verify_output = verify_result.std_out.decode(errors="ignore") if verify_result.std_out else ""

    # ✅ VERIFY LOGIC
    success = False

    #if job.software_name.lower() in verify_output.lower():
    #    success = True  
    if verify_output:
        output_lower = verify_output.lower().strip()

        if "true" in output_lower:
            success = True
        elif output_lower != "":
            success = True

    duration = round(time.time() - start, 2)

    return ExecutionResult(
        success=success,
        exit_code=install_result.status_code,
        stdout=verify_output,
        stderr=install_stderr,
        duration_seconds=duration,
        transport="winrm"
    )