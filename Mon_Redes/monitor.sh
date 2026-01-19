#!/bin/bash

# Network Monitoring Script
# Dependencies: nmap, tshark (wireshark)

REPORT_FILE="network_report_$(date +%Y%m%d_%H%M%S).txt"
INTERFACE="eth0" # Change this if needed, or make it interactive
SUBNET="192.168.1.0/24" # Default subnet, can be detected or passed as arg

echo "Starting Network Monitor..." | tee -a "$REPORT_FILE"
echo "Report File: $REPORT_FILE" | tee -a "$REPORT_FILE"
echo "Date: $(date)" | tee -a "$REPORT_FILE"
echo "----------------------------------------" | tee -a "$REPORT_FILE"

# 1. Check Dependencies
echo "[*] Checking dependencies..."
if ! command -v nmap &> /dev/null; then
    echo "[!] Error: nmap is not installed." | tee -a "$REPORT_FILE"
    exit 1
fi

if ! command -v tshark &> /dev/null; then
    echo "[!] Error: tshark is not installed." | tee -a "$REPORT_FILE"
    exit 1
fi

# 2. Network Discovery (Ping Scan)
echo "[*] Discovering active hosts in $SUBNET..." | tee -a "$REPORT_FILE"
nmap -sn "$SUBNET" -oG - | grep "Up" | awk '{print $2}' > live_hosts.txt
HOST_COUNT=$(wc -l < live_hosts.txt)
echo "Found $HOST_COUNT live hosts." | tee -a "$REPORT_FILE"
cat live_hosts.txt | tee -a "$REPORT_FILE"
echo "----------------------------------------" | tee -a "$REPORT_FILE"

# 3. Port Scanning
echo "[*] Scanning ports on live hosts..." | tee -a "$REPORT_FILE"
if [ "$HOST_COUNT" -gt 0 ]; then
    nmap -iL live_hosts.txt -p 21,22,80,443,3389,8080 --open | tee -a "$REPORT_FILE"
else
    echo "No hosts to scan." | tee -a "$REPORT_FILE"
fi
echo "----------------------------------------" | tee -a "$REPORT_FILE"

# 4. Traffic Capture & Anomaly Detection (Short sample)
CAPTURE_DURATION=30
CAPTURE_FILE="traffic_capture.pcap"
echo "[*] Capturing traffic on $INTERFACE for $CAPTURE_DURATION seconds..." | tee -a "$REPORT_FILE"
# Check if interface exists
if ! ip link show "$INTERFACE" &> /dev/null; then
    echo "[!] Warning: Interface $INTERFACE not found. Listing available interfaces:"
    ip link show | grep -E '^[0-9]' | awk -F: '{print $2}'
    echo "Please edit the script to set the correct INTERFACE variable."
else
    # Run tshark capture
    tshark -i "$INTERFACE" -a duration:"$CAPTURE_DURATION" -w "$CAPTURE_FILE" -q 2>/dev/null
    
    echo "[*] Analyzing traffic..." | tee -a "$REPORT_FILE"
    
    # Simple Anomaly: High packet count from single IP (Top 5 talkers)
    echo "Top 5 Source IPs by Packet Count:" | tee -a "$REPORT_FILE"
    tshark -r "$CAPTURE_FILE" -T fields -e ip.src 2>/dev/null | sort | uniq -c | sort -nr | head -n 5 | tee -a "$REPORT_FILE"
    
    # Simple Anomaly: Check for potential SYN scan patterns (High number of TCP SYN packets)
    SYN_COUNT=$(tshark -r "$CAPTURE_FILE" -Y "tcp.flags.syn==1 && tcp.flags.ack==0" 2>/dev/null | wc -l)
    echo "Total TCP SYN packets observed: $SYN_COUNT" | tee -a "$REPORT_FILE"
    
    if [ "$SYN_COUNT" -gt 100 ]; then 
        echo "[!] POTENTIAL ANOMALY: High number of SYN packets detected ($SYN_COUNT). Possible port scan." | tee -a "$REPORT_FILE"
    fi
fi

echo "----------------------------------------" | tee -a "$REPORT_FILE"
echo "[*] Monitor completed." | tee -a "$REPORT_FILE"
