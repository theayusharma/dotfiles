#!/usr/bin/env python3
import os
import time
import subprocess
import shutil

def get_cpu():
    try:
        with open("/proc/stat", "r") as f:
            fields1 = [float(x) for x in f.readline().strip().split()[1:]]
        time.sleep(0.03)
        with open("/proc/stat", "r") as f:
            fields2 = [float(x) for x in f.readline().strip().split()[1:]]
        idle1, total1 = fields1[3] + fields1[4], sum(fields1)
        idle2, total2 = fields2[3] + fields2[4], sum(fields2)
        idle_delta = idle2 - idle1
        total_delta = total2 - total1
        usage = 100.0 * (1.0 - idle_delta / max(1.0, total_delta))
        temp = 0.0
        for p in ["/sys/class/hwmon/hwmon5/temp1_input", "/sys/class/thermal/thermal_zone0/temp"]:
            if os.path.exists(p):
                with open(p, "r") as tf:
                    temp = float(tf.read().strip()) / 1000.0
                    break
        return max(0.0, min(100.0, usage)), temp
    except Exception:
        return 0.0, 0.0

def get_ram():
    try:
        mem = {}
        with open("/proc/meminfo", "r") as f:
            for line in f:
                parts = line.split(":")
                if len(parts) == 2:
                    mem[parts[0].strip()] = int(parts[1].split()[0])
        total = mem.get("MemTotal", 1) / (1024 * 1024)
        avail = mem.get("MemAvailable", 0) / (1024 * 1024)
        used = total - avail
        pct = (used / total) * 100.0
        return used, total, pct
    except Exception:
        return 0.0, 1.0, 0.0

def get_swap_zram():
    try:
        zram_used = 0.0
        zram_total = 0.0
        disk_swap_used = 0.0
        disk_swap_total = 0.0
        
        with open("/proc/swaps", "r") as f:
            lines = f.readlines()[1:]
            for line in lines:
                parts = line.split()
                if len(parts) >= 4:
                    dev = parts[0]
                    size = float(parts[2]) / (1024 * 1024)
                    used = float(parts[3]) / (1024 * 1024)
                    if "zram" in dev:
                        zram_total += size
                        zram_used += used
                    else:
                        disk_swap_total += size
                        disk_swap_used += used
        total_swap = zram_total + disk_swap_total
        total_used = zram_used + disk_swap_used
        pct = (total_used / total_swap * 100.0) if total_swap > 0 else 0.0
        return zram_used, zram_total, disk_swap_used, disk_swap_total, pct
    except Exception:
        return 0.0, 0.0, 0.0, 0.0, 0.0

def get_amd_gpu():
    try:
        load = 0.0
        temp = 0.0
        p_busy = "/sys/class/drm/card1/device/gpu_busy_percent"
        if os.path.exists(p_busy):
            with open(p_busy, "r") as f:
                load = float(f.read().strip())
        p_temp = "/sys/class/hwmon/hwmon4/temp1_input"
        if os.path.exists(p_temp):
            with open(p_temp, "r") as f:
                temp = float(f.read().strip()) / 1000.0
        return load, temp
    except Exception:
        return None

def get_nvidia_gpu():
    try:
        out = subprocess.check_output(
            ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"],
            stderr=subprocess.DEVNULL,
            timeout=0.3
        ).decode().strip()
        parts = [p.strip() for p in out.split(",")]
        return float(parts[0]), float(parts[1])
    except Exception:
        return None

def make_meter(pct, width=14):
    filled = int(round((pct / 100.0) * width))
    filled = max(0, min(width, filled))
    if pct >= 85:
        color = "\033[38;5;196m"
    elif pct >= 65:
        color = "\033[38;5;214m"
    else:
        color = "\033[38;5;75m"
    dim = "\033[38;5;238m"
    rst = "\033[0m"
    return f"{color}{'━' * filled}{dim}{'┄' * (width - filled)}{rst}"

def build_card(title, line1, line2, pct):
    border = "\033[38;5;240m"
    title_c = "\033[1;38;5;222m"
    lbl_c = "\033[38;5;244m"
    val_c = "\033[38;5;253m"
    rst = "\033[0m"
    
    # 18-column solid box
    top = f"{border}╭────────────────╮{rst}"
    
    # Header row
    h_text = f"{title_c}{title:<14}{rst}"
    row0 = f"{border}│ {rst}{h_text}{border} │{rst}"
    
    # Data rows
    l1_text = f"{lbl_c}{line1[0]:<5}{rst} {val_c}{line1[1]:>8}{rst}"
    row1 = f"{border}│ {rst}{l1_text}{border} │{rst}"
    
    l2_text = f"{lbl_c}{line2[0]:<5}{rst} {val_c}{line2[1]:>8}{rst}"
    row2 = f"{border}│ {rst}{l2_text}{border} │{rst}"
    
    # Progress meter
    bar = make_meter(pct, width=14)
    row3 = f"{border}│ {rst}{bar}{border} │{rst}"
    
    bot = f"{border}╰────────────────╯{rst}"
    
    return [top, row0, row1, row2, row3, bot]

def print_centered(rows, num_cards, term_width):
    # Each card is 18 chars, separated by 2 spaces
    total_w = (num_cards * 18) + ((num_cards - 1) * 2)
    pad = " " * max(0, (term_width - total_w) // 2)
    for line in rows:
        print(pad + line)

def main():
    cpu_pct, cpu_temp = get_cpu()
    ram_used, ram_total, ram_pct = get_ram()
    z_used, z_tot, d_used, d_tot, swp_pct = get_swap_zram()
    
    amd = get_amd_gpu()
    nv = get_nvidia_gpu()

    c_cpu = build_card(
        " CPU",
        ("Load:", f"{cpu_pct:4.1f}%"),
        ("Temp:", f"{cpu_temp:.0f}°C" if cpu_temp > 0 else "N/A"),
        cpu_pct
    )

    c_ram = build_card(
        " RAM",
        ("Used:", f"{ram_used:4.1f} GB"),
        ("Free:", f"{ram_total - ram_used:4.1f} GB"),
        ram_pct
    )

    c_swp = build_card(
        "󰓅 SWP",
        ("ZRAM:", f"{z_used:3.1f}/{z_tot:3.1f}G"),
        ("Disk:", f"{d_used:3.1f}/{d_tot:3.1f}G"),
        swp_pct
    )

    amd_l, amd_t = amd if amd else (0.0, 0.0)
    nv_l, nv_t = nv if nv else (0.0, 0.0)
    max_gpu = max(amd_l, nv_l)
    
    c_gpu = build_card(
        "󰢮 GPU",
        ("AMD :", f"{amd_l:2.0f}% {amd_t:.0f}°C"),
        ("NVD :", f"{nv_l:2.0f}% {nv_t:.0f}°C"),
        max_gpu
    )

    cards = [c_cpu, c_ram, c_swp, c_gpu]
    term_width = shutil.get_terminal_size((80, 24)).columns
    
    print()
    if term_width >= 82:
        rows = ["  ".join(cards[c][r] for c in range(4)) for r in range(6)]
        print_centered(rows, 4, term_width)
    else:
        rows1 = ["  ".join([cards[0][r], cards[1][r]]) for r in range(6)]
        print_centered(rows1, 2, term_width)
        rows2 = ["  ".join([cards[2][r], cards[3][r]]) for r in range(6)]
        print_centered(rows2, 2, term_width)
    print()

if __name__ == "__main__":
    main()
