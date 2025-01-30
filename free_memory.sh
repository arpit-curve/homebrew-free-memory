#!/bin/bash

# Ensure the script runs with sudo for necessary permissions
if [[ $EUID -ne 0 ]]; then
   echo "❌ This command must be run as root (sudo)."
   exit 1
fi

# Function to display memory and system usage in tabular format
display_usage() {
    echo "📊 System Resource Usage:"
    echo "------------------------------------------------------"
    
    # Total memory
    total_mem=$(sysctl -n hw.memsize)
    total_mem_gb=$((total_mem / 1024 / 1024 / 1024))

    # Memory details
    page_size=$(vm_stat | head -n1 | awk '{print $8}' | sed 's/.$//')
    active_mem=$(vm_stat | awk '/Pages active/ {print $3}' | sed 's/.$//')
    wired_mem=$(vm_stat | awk '/Pages wired down/ {print $4}' | sed 's/.$//')
    compressed_mem=$(vm_stat | awk '/Pages occupied by compressor/ {print $5}' | sed 's/.$//' )
    free_mem=$(vm_stat | awk '/Pages free/ {print $3}' | sed 's/.$//' )

    # Convert memory values to MB
    active_mem_mb=$((active_mem * page_size / 1024 / 1024))
    wired_mem_mb=$((wired_mem * page_size / 1024 / 1024))
    compressed_mem_mb=$((compressed_mem * page_size / 1024 / 1024))
    free_mem_mb=$((free_mem * page_size / 1024 / 1024))

    used_mem_mb=$((active_mem_mb + wired_mem_mb + compressed_mem_mb))
    used_percent=$((used_mem_mb * 100 / (total_mem / 1024 / 1024)))
    free_percent=$((free_mem_mb * 100 / (total_mem / 1024 / 1024)))

    # Display memory details in tabular format
    printf "🖥  %-20s %10s\n" "Total Memory:" "${total_mem_gb}GB"
    printf "📌 %-20s %10s (%d%%)\n" "Used Memory:" "${used_mem_mb}MB" "${used_percent}"
    printf "⚡ %-20s %10s\n" "Wired Memory:" "${wired_mem_mb}MB"
    printf "🗜️  %-20s %10s\n" "Compressed Memory:" "${compressed_mem_mb}MB"
    printf "🟢 %-20s %10s (%d%%)\n" "Free Memory:" "${free_mem_mb}MB" "${free_percent}"

    # Swap usage (safe calculation)
    swap_stats=$(sysctl -n vm.swapusage)
    swap_used=$(echo "$swap_stats" | awk '{print $7}' | sed 's/M//')
    swap_total=$(echo "$swap_stats" | awk '{print $10}' | sed 's/M//')

    if [[ $swap_total -gt 0 ]]; then
        swap_percent=$((swap_used * 100 / swap_total))
        printf "🔄 %-20s %10s / %sMB (%d%%)\n" "Swap Used:" "${swap_used}MB" "${swap_total}" "${swap_percent}"
    else
        printf "🔄 %-20s %10s\n" "Swap Used:" "${swap_used}MB (No swap allocated)"
    fi

    # CPU usage
    cpu_usage=$(ps -A -o %cpu | awk '{s+=$1} END {print s}')
    printf "🚀 %-20s %10s%%\n" "CPU Usage:" "${cpu_usage}"

    echo "------------------------------------------------------"
}

# Show stats before cleanup
echo -e "\n📌 Before Memory Cleanup:\n"
display_usage

# Free up memory with a loader animation
echo -n "🧹 Freeing up inactive memory and cache "
sudo purge &  # Run purge in the background

# Loader animation
for i in {1..7}; do
    echo -n "🕗"
    sleep 1.5
done
echo " ✅ Done!"

# Show stats after cleanup
echo -e "\n✅ After Memory Cleanup:\n"
display_usage

echo "🎯 Memory cleanup completed successfully!"