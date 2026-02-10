# Configuration for SiYuan in Docker/Coolify environment

# Recommended startup command with explicit parameters
# docker run -d -p 6806:6806 -v /path/to/workspace:/siyuan/workspace b3log/siyuan \
#   --workspace=/siyuan/workspace --accessAuthCode=your_code_here

# Environment variables to pass to container
SIYUAN_WORKSPACE_PATH=/siyuan/workspace
SIYUAN_ACCESS_AUTH_CODE_BYPASS=false

# Common startup parameters:
# --workspace: Path to SiYuan workspace directory
# --accessAuthCode: Authorization code for accessing SiYuan
# --network: Network mode (local, public) - default is local
# --lang: Language (zh_CN, en_US, ja_JP, etc.) - default is auto-detected

# Notes for Coolify deployment:
# 1. Make sure to mount the workspace directory as a volume
# 2. Set up proper authentication code
# 3. Expose port 6806 for web access
# 4. WebSocket endpoint /ws needs to be accessible