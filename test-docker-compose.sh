#!/bin/bash
# Test script to validate Docker Compose configurations

set -e

echo "==================================="
echo "Docker Compose Configuration Tests"
echo "==================================="
echo ""

# Test 1: Base configuration
echo "Test 1: Validating base docker-compose.yml..."
docker compose -f docker-compose.yml config > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Base configuration is valid"
else
    echo "✗ Base configuration is invalid"
    exit 1
fi

# Test 2: Linux configuration (base + override)
echo "Test 2: Validating Linux configuration (base + override)..."
docker compose -f docker-compose.yml -f docker-compose.override.yml config > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Linux configuration is valid"
else
    echo "✗ Linux configuration is invalid"
    exit 1
fi

# Test 3: Windows configuration
echo "Test 3: Validating Windows configuration..."
docker compose -f docker-compose.yml -f docker-compose.windows.yml config > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Windows configuration is valid"
else
    echo "✗ Windows configuration is invalid"
    exit 1
fi

# Test 4: Check that base config has no volumes
echo "Test 4: Verifying base config has no volumes..."
VOLUME_COUNT=$(docker compose -f docker-compose.yml config | grep -c "volumes:" || true)
if [ "$VOLUME_COUNT" -eq 0 ]; then
    echo "✓ Base configuration correctly has no volumes"
else
    echo "✗ Base configuration should not have volumes"
    exit 1
fi

# Test 5: Check that Linux config has X11 volumes
echo "Test 5: Verifying Linux config has X11 volumes..."
LINUX_VOLUME_COUNT=$(docker compose -f docker-compose.yml -f docker-compose.override.yml config | grep "/tmp/.X11-unix" | wc -l)
if [ "$LINUX_VOLUME_COUNT" -gt 0 ]; then
    echo "✓ Linux configuration correctly includes X11 volumes"
else
    echo "✗ Linux configuration should include X11 volumes"
    exit 1
fi

# Test 6: Check that Windows config has no volumes
echo "Test 6: Verifying Windows config has no volumes..."
WIN_VOLUME_COUNT=$(docker compose -f docker-compose.yml -f docker-compose.windows.yml config | grep -c "volumes:" || true)
if [ "$WIN_VOLUME_COUNT" -eq 0 ]; then
    echo "✓ Windows configuration correctly has no volumes"
else
    echo "✗ Windows configuration should not have volumes"
    exit 1
fi

# Test 7: Check that Dockerfile exists
echo "Test 7: Verifying Dockerfile exists..."
if [ -f "docker/Dockerfile.vintrospect" ]; then
    echo "✓ Dockerfile.vintrospect exists"
else
    echo "✗ Dockerfile.vintrospect not found"
    exit 1
fi

echo ""
echo "==================================="
echo "All tests passed! ✓"
echo "==================================="
echo ""
echo "Usage instructions:"
echo "  Linux:   docker compose up --build"
echo "  Windows: docker compose -f docker-compose.yml -f docker-compose.windows.yml up --build"
