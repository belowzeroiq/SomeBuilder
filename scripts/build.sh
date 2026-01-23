#!/bin/bash
set -e

export LC_ALL=C

# ===== Configuration =====
ROM_NAME="${MAKEFILENAME%%_*}"
SAFE_TIME=5760  # 96 minutes in seconds
LOG_FILE="build.log"

# ===== Functions =====

cleanup() {
    echo "Performing cleanup..."
    kill "$TIMER_PID" 2>/dev/null || true
}
trap cleanup EXIT

upload_ota() {
    echo "Uploading OTA ZIP..."
    local ota_file=$(find "out/target/product/${DEVICE_CODENAME}" -name "*.zip" -type f | head -n 1)
    
    if [ -z "$ota_file" ]; then
        echo "No OTA ZIP file found!"
        return 1
    fi
    
    echo "Found OTA ZIP: $ota_file"
    local response=$(curl -s -X POST \
        -H "Authorization: Basic $(echo -n ":$PIXELDRAIN_API_KEY" | base64)" \
        -F "file=@$ota_file" \
        "https://pixeldrain.com/api/file")
    
    local file_id=$(echo "$response" | jq -r '.id')
    if [ -n "$file_id" ] && [ "$file_id" != "null" ]; then
        echo "OTA ZIP uploaded: https://pixeldrain.com/u/$file_id"
        return 0
    else
        echo "Failed to upload OTA ZIP!"
        return 1
    fi
}

monitor_time() {
    local start_time=$(date +%s)
    local last_display_time=$start_time
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local remaining=$((SAFE_TIME - elapsed))
        
        if (( remaining <= 0 )); then
            echo -e "\n\nTimeout reached! Stopping build..."
            kill -TERM $BUILD_PID 2>/dev/null || true
            exit 1
        fi
        
        # Display status every 5 minutes
        if (( current_time - last_display_time >= 300 )); then
            echo -e "\n$(date): Elapsed: ${elapsed}s | Remaining: ${remaining}s"
            echo "--- Latest Build Logs ---"
            tail -n 10 "$LOG_FILE" 2>/dev/null || echo "No logs yet"
            echo "-------------------------"
            last_display_time=$current_time
        fi
        
        sleep 1
    done
}

build() {
    echo "Setting up build environment..."
    source build/envsetup.sh || . build/envsetup.sh
    
    # Run optional extra commands
    [ -n "$EXTRACMD" ] && eval "$EXTRACMD"
    
    echo "Starting build with target: $TARGET"
    $TARGET -j$(nproc --all) >> "$LOG_FILE" 2>&1 &
    BUILD_PID=$!
    
    # Wait for build to complete
    if wait $BUILD_PID; then
        echo "Build completed successfully!"
        return 0
    else
        echo "Build failed!"
        return 1
    fi
}

# ===== Main Execution =====
main() {
    echo "===== Build Script Starting ====="
    echo "ROM: $MAKEFILENAME"
    echo "Device: $DEVICE_CODENAME"
    echo "Variant: $VARIANT"
    echo "Target: $TARGET"
    echo "=============================="
    
    # Initialize log file
    : > "$LOG_FILE"
    
    # Start time monitor in background
    monitor_time &
    TIMER_PID=$!
    
    # Run the build
    if build; then
        # Upload the OTA ZIP
        upload_ota || echo "Warning: OTA upload failed"
        echo "===== Build Completed Successfully ====="
        exit 0
    else
        echo "===== Build Failed ====="
        exit 1
    fi
}

main "$@"
