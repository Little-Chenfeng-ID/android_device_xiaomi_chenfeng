#!/system/bin/sh
# Post-install script to ensure correct slot after OTA/update
# This runs after OTA package installation

LOG_TAG="auto_slot_set"
LOG_FILE="/cache/recovery/log"

log() {
    echo "$LOG_TAG: $1" >> $LOG_FILE
    log -t "$LOG_TAG" "$1"
}

log "Starting auto slot configuration..."

# Get current slot suffix
SLOT_SUFFIX=$(getprop ro.boot.slot_suffix 2>/dev/null)
SLOT=$(getprop ro.boot.slot 2>/dev/null)

# Fallback: try to get slot from bootctl
if [ -z "$SLOT_SUFFIX" ]; then
    if [ -x /system/bin/bootctl ]; then
        ACTIVE_SLOT=$(bootctl get-active-slot 2>/dev/null)
        case "$ACTIVE_SLOT" in
            0)
                SLOT="_a"
                SLOT_VAL="a"
                ;;
            1)
                SLOT="_b"
                SLOT_VAL="b"
                ;;
            *)
                SLOT="_a"
                SLOT_VAL="a"
                ;;
        esac
    else
        SLOT="_a"
        SLOT_VAL="a"
    fi
else
    # Convert suffix to slot value
    case "$SLOT_SUFFIX" in
        _a)
            SLOT_VAL="a"
            ;;
        _b)
            SLOT_VAL="b"
            ;;
        *)
            SLOT_VAL="a"
            ;;
    esac
fi

log "Current slot suffix: $SLOT_SUFFIX, slot value: $SLOT_VAL"

# Set the active slot to match current boot slot
if [ -x /system/bin/bootctl ]; then
    log "Setting active slot to: $SLOT_VAL"
    bootctl set-active-slot $SLOT_VAL 2>/dev/null
    
    if [ $? -eq 0 ]; then
        log "Successfully set active slot to: $SLOT_VAL"
    else
        log "Warning: Failed to set active slot"
    fi
else
    log "bootctl not available, skipping slot configuration"
fi

log "Auto slot configuration complete"

# Exit with success
exit 0
