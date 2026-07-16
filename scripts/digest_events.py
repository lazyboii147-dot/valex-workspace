#!/usr/bin/env python3
import os
import sqlite3
from collections import Counter

# Path to the database
DB_PATH = os.path.expanduser("~/clearboxx_events.db")

if not os.path.exists(DB_PATH):
    print(f"Error: Database not found at {DB_PATH}")
    exit(1)

def run_digest():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    print("=" * 60)
    print("         CLEARBOXX EVENTS DATABASE DIGEST")
    print("=" * 60)

    # 1. Total Event Count
    cursor.execute("SELECT COUNT(*) FROM events;")
    total_events = cursor.fetchone()[0]
    print(f"Total Events Tracked: {total_events}\n")

    if total_events == 0:
        print("No events found in the database.")
        conn.close()
        return

    # 2. Breakdown by Severity
    print("--- Severity Breakdown ---")
    cursor.execute("SELECT severity, COUNT(*) FROM events GROUP BY severity ORDER BY COUNT(*) DESC;")
    for severity, count in cursor.fetchall():
        print(f"  [{severity.upper()}]".ljust(15) + f": {count}")
    print()

    # 3. Top Active Actors
    print("--- Top 5 Active Actors ---")
    cursor.execute("SELECT actor_id, COUNT(*) FROM events GROUP BY actor_id ORDER BY COUNT(*) DESC LIMIT 5;")
    for actor, count in cursor.fetchall():
        print(f"  Actor: {actor.ljust(20)} | Events: {count}")
    print()

    # 4. Unique IP Addresses
    cursor.execute("SELECT COUNT(DISTINCT source_ip) FROM events WHERE source_ip IS NOT NULL;")
    unique_ips = cursor.fetchone()[0]
    print(f"Unique Source IPs: {unique_ips}\n")

    # 5. Top 5 Most Common Event Types
    print("--- Top 5 Event Types ---")
    cursor.execute("SELECT event_type, COUNT(*) FROM events GROUP BY event_type ORDER BY COUNT(*) DESC LIMIT 5;")
    for e_type, count in cursor.fetchall():
        print(f"  {e_type.ljust(25)}: {count}")
    print()

    # 6. Recent Activity Timeline (Last 10 Events)
    print("--- Recent Activity Timeline (Last 10) ---")
    cursor.execute("""
        SELECT created_at, severity, actor_id, event_type, payload_summary 
        FROM events 
        ORDER BY id DESC 
        LIMIT 10;
    """)
    
    print(f"{'Timestamp':<23} | {'Severity':<8} | {'Actor':<15} | {'Event Type':<20} | {'Payload Summary'}")
    print("-" * 90)
    for row in cursor.fetchall():
        created_at, severity, actor, event_type, payload = row
        payload_str = payload if payload else "N/A"
        # Truncate payload summary if it's too long for the terminal view
        if len(payload_str) > 30:
            payload_str = payload_str[:27] + "..."
            
        print(f"{created_at:<23} | {severity.upper():<8} | {actor:<15} | {event_type:<20} | {payload_str}")
    
    print("=" * 60)
    conn.close()

if __name__ == "__main__":
    run_digest()
/*
EOF-METADATA-BEGIN
HASH: e412b2b9ae9a46aa71055870f4b3694c931d869c24b1bb071bd3338195613b699de5826b35c657f38fdb3f9d5319317cc23a259f801802b193797e7daf7b1351
SIGNATURE: MEUCIDyO5SLIzZXF0rqcEiox1pV+J4CdpEIdxCDimKEK/V+wAiEAs0+eZRLNGcpEQRDBOOOcAI3Dy4zJoXjRF+5fpSil5aM=
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: digest_events.py
EOF-METADATA-END
*/
