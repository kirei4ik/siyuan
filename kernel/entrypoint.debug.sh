#!/bin/sh
set -e

# Default values
PUID=${PUID:-1000}
PGID=${PGID:-1000}
USER_NAME=${USER_NAME:-siyuan}
GROUP_NAME=${GROUP_NAME:-siyuan}
WORKSPACE_DIR="/siyuan/workspace"

# Get or create group
group_name="${GROUP_NAME}"
if getent group "${PGID}" > /dev/null 2>&1; then
    group_name=$(getent group "${PGID}" | cut -d: -f1)
    echo "Using existing group: ${group_name} (${PGID})"
else
    echo "Creating group ${group_name} (${PGID})"
    addgroup --gid "${PGID}" "${group_name}" 2>/dev/null || echo "Group already exists"
fi

# Get or create user
user_name="${USER_NAME}"
if getent passwd "${PUID}" > /dev/null 2>&1; then
    user_name=$(getent passwd "${PUID}" | cut -d: -f1)
    echo "Using existing user ${user_name} (PUID: ${PUID}, PGID: ${PGID})"
else
    echo "Creating user ${user_name} (PUID: ${PUID}, PGID: ${PGID})"
    adduser --uid "${PUID}" --ingroup "${group_name}" --disabled-password --gecos "" "${user_name}" 2>/dev/null || echo "User already exists"
fi

# Parse command line arguments for --workspace option or SIYUAN_WORKSPACE_PATH env variable
if [[ -n "${SIYUAN_WORKSPACE_PATH}" ]]; then
    WORKSPACE_DIR="${SIYUAN_WORKSPACE_PATH}"
fi
ARGS=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --workspace=*) WORKSPACE_DIR="${1#*=}"; shift ;;
        --accessAuthCode=*) ACCESS_AUTH_CODE="${1#*=}"; shift ;;
        --network=*) NETWORK_MODE="${1#*=}"; shift ;;
        *) ARGS="$ARGS $1"; shift ;;
    esac
done

# Create workspace directory if it doesn't exist
mkdir -p "${WORKSPACE_DIR}"

# Change ownership of relevant directories
echo "Adjusting ownership of /opt/siyuan, /home/siyuan/, and ${WORKSPACE_DIR}"
chown -R "${PUID}:${PGID}" /opt/siyuan || echo "Warning: Could not change ownership of /opt/siyuan"
chown -R "${PUID}:${PGID}" /home/siyuan/ || echo "Warning: Could not change ownership of /home/siyuan/"

# Check if workspace directory exists and set permissions
if [ -d "${WORKSPACE_DIR}" ]; then
    chown -R "${PUID}:${PGID}" "${WORKSPACE_DIR}"
    echo "Workspace ${WORKSPACE_DIR} found and permissions set"
else
    echo "ERROR: Workspace directory ${WORKSPACE_DIR} does not exist!"
    exit 1
fi

# Verify kernel executable exists and is executable
if [ ! -f "/opt/siyuan/kernel" ]; then
    echo "ERROR: Kernel binary not found at /opt/siyuan/kernel"
    exit 1
fi

if [ ! -x "/opt/siyuan/kernel" ]; then
    echo "Making kernel executable..."
    chmod +x /opt/siyuan/kernel
fi

# Print diagnostic information
echo "PUID: ${PUID}, PGID: ${PGID}"
echo "WORKSPACE_DIR: ${WORKSPACE_DIR}"
echo "ARGS: ${ARGS}"
echo "User permissions: $(id siyuan)"
echo "Kernel exists: $(ls -la /opt/siyuan/kernel)"

# Switch to the newly created user and start the main process with all arguments
echo "Starting Siyuan with UID:${PUID} and GID:${PGID} in workspace ${WORKSPACE_DIR}"
exec su-exec "${PUID}:${PGID}" /opt/siyuan/kernel --workspace="${WORKSPACE_DIR}" ${ARGS}