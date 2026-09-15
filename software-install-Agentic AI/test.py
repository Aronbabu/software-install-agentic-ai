import paramiko

HOST = "10.84.40.84"
USERNAME = 'ctscsitlab\\458027-admin1'
PASSWORD = 'N7@qL9!xP2#m'

client = paramiko.SSHClient()
client.set_missing_host_key_policy(
    paramiko.AutoAddPolicy()
)

try:
    client.connect(
        hostname=HOST,
        username=USERNAME,
        password=PASSWORD,
        port=22,
        timeout=10
    )

    stdin, stdout, stderr = client.exec_command("hostname")

    print("OUTPUT:")
    print(stdout.read().decode())

    print("ERROR:")
    print(stderr.read().decode())

finally:
    client.close()