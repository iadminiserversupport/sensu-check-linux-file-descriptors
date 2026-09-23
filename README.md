# Sensu Linux File Descriptor Check

A Sensu check plugin for monitoring system-wide Linux file descriptor utilization.

The check reads `/proc/sys/fs/file-nr` and reports:

- Allocated file descriptors
- Unused file descriptors
- Maximum file descriptors
- Percentage of allocated descriptors

## Usage

```bash
check-linux-file-descriptors.sh -w 80 -c 90
````

Options:

* `-w` Warning threshold as a percentage
* `-c` Critical threshold as a percentage

Example:

```text
OK - file descriptors 0% used | allocated=13527 unused=0 maximum=9223372036854775807 used_percent=0%;80;90;0;100
```

Exit codes:

* `0` OK
* `1` WARNING
* `2` CRITICAL
* `3` UNKNOWN

## Sensu

This check is intended to be distributed as a Sensu dynamic runtime asset through Bonsai.

Example check configuration:

```yaml
---
type: CheckConfig
api_version: core/v2
metadata:
  name: linux-file-descriptors
spec:
  command: check-linux-file-descriptors.sh -w 80 -c 90
  interval: 60
  timeout: 10
  subscriptions:
    - linux
  runtime_assets:
    - iadminiserversupport/sensu-check-linux-file-descriptors:0.1.0
```

## Server Management

For Linux server administration, monitoring, security, and infrastructure management:

[https://iserversupport.com/server-management-services/](https://iserversupport.com/server-management-services/)
EOF

## cat > bonsai.yml <<'EOF'

description: "Sensu check for Linux system-wide file descriptor utilization"
builds:

* platform: "linux"
  arch: "amd64"
  asset_filename: "#{repo}_#{version}*linux_amd64.tar.gz"
  sha_filename: "#{repo}*#{version}_sha512-checksums.txt"
  filter:

  * "entity.system.os == 'linux'"
  * "entity.system.arch == 'amd64'"
