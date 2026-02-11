# Docker Compose Setup for Vintrospect

This directory contains Docker configuration files for running the vintrospect application across different platforms.

## Files

- `docker-compose.yml` - Base configuration (platform-agnostic)
- `docker-compose.override.yml` - Linux-specific overrides (automatically applied)
- `docker-compose.windows.yml` - Windows-specific configuration
- `Dockerfile.vintrospect` - Docker image definition

## Usage

### Linux/Ubuntu

On Linux, Docker Compose automatically uses both `docker-compose.yml` and `docker-compose.override.yml`:

```bash
# Build and run
docker compose up --build

# Run in background
docker compose up -d

# Stop
docker compose down
```

The Linux configuration includes X11 forwarding for GUI applications with safe defaults:
- X11 socket: `/tmp/.X11-unix`
- XAUTHORITY: Uses `$XAUTHORITY` if set, otherwise `~/.Xauthority`
- XDG_RUNTIME_DIR: Uses `$XDG_RUNTIME_DIR` if set, otherwise `/run/user/1000`

### Windows

On Windows, you need to explicitly specify the Windows configuration file:

```bash
# Build and run on Windows
docker compose -f docker-compose.yml -f docker-compose.windows.yml up --build

# Run in background
docker compose -f docker-compose.yml -f docker-compose.windows.yml up -d

# Stop
docker compose -f docker-compose.yml -f docker-compose.windows.yml down
```

#### GUI Support on Windows

Windows doesn't natively support X11 forwarding. To run GUI applications:

**Option 1: WSL2 with WSLg (Windows 11)**
- WSLg is built into Windows 11 and provides GUI support
- No additional configuration needed when running from WSL2

**Option 2: X Server (Windows 10/11)**
1. Install an X server (VcXsrv, Xming, or X410)
2. Configure the X server to allow connections
3. Uncomment and set the DISPLAY environment variable in `docker-compose.windows.yml`:
   ```yaml
   - DISPLAY=host.docker.internal:0.0
   ```

## Environment Variables

### Linux (automatically set by docker-compose.override.yml)
- `DISPLAY` - X11 display (default: `:0`)
- `XAUTHORITY` - X11 authentication file (default: `~/.Xauthority`)
- `XDG_RUNTIME_DIR` - Runtime directory (default: `/run/user/1000`)

### GPU Support (all platforms)
- `NVIDIA_VISIBLE_DEVICES=all` - Makes all GPUs visible
- `NVIDIA_DRIVER_CAPABILITIES=all` - Enables all GPU capabilities

## Troubleshooting

### Linux Issues

**X11 connection failed**
```bash
# Allow X11 connections from docker
xhost +local:docker

# After use, restore security
xhost -local:docker
```

**Permission denied on X11 socket**
```bash
# Check XAUTHORITY is set
echo $XAUTHORITY

# If empty, set it
export XAUTHORITY=~/.Xauthority
```

### Windows Issues

**Volume mount errors**
- Windows paths in environment variables can cause issues
- The Windows configuration avoids problematic Linux-specific mounts
- Use named volumes instead of bind mounts when possible

**GPU support**
- Requires NVIDIA Docker runtime
- Requires NVIDIA drivers installed on Windows host
- WSL2 required for GPU support on Windows

## Notes

- The `privileged: true` flag is required for certain GPU operations
- Port 10000 is bound to localhost (127.0.0.1) for security
- The container hostname is set to `vintrospect` for consistent networking

## Building from Source

Make sure your vintrospect application files are in the correct location before building:

```bash
# Place your vintrospect.x86_64 binary in the appropriate location
# Update Dockerfile.vintrospect to copy the necessary files
```

## Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Desktop WSL2 Backend](https://docs.docker.com/desktop/windows/wsl/)
- [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker)
