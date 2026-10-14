# Homeserver command shortcuts
# Run `just` or `just --list` to see available commands.

default:
    @just --list

# ---------------------------------------------------------------------------
# Overview
# ---------------------------------------------------------------------------

# Show running Docker containers
ps:
    sudo docker ps --format 'table {{ "{{" }}.Names{{ "}}" }}\t{{ "{{" }}.Status{{ "}}" }}\t{{ "{{" }}.Ports{{ "}}" }}'

# Show CPU, memory and uptime
status:
    @echo "=== Uptime ==="
    uptime
    @echo
    @echo "=== Memory ==="
    free -h
    @echo
    @echo "=== Disk ==="
    df -h /
    @echo
    @echo "=== Containers ==="
    sudo docker ps --format 'table {{ "{{" }}.Names{{ "}}" }}\t{{ "{{" }}.Status{{ "}}" }}'

# Show Docker container resource usage once
stats:
    sudo docker stats --no-stream

# Show disk usage of Docker
docker-disk:
    sudo docker system df

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

# Show main network information
network:
    @echo "=== Interfaces ==="
    ip -br addr
    @echo
    @echo "=== Routes ==="
    ip route
    @echo
    @echo "=== Tailscale ==="
    tailscale status

# Show Wi-Fi connection quality
wifi:
    iw dev wlp2s0 link
    nmcli -f IN-USE,SSID,SIGNAL,RATE,CHAN,FREQ dev wifi

# Test router and internet
ping:
    @echo "=== Router ==="
    ping -c 5 192.168.29.1
    @echo
    @echo "=== Internet ==="
    ping -c 5 1.1.1.1

# Show listening ports
ports:
    sudo ss -tulpn

# Show firewall rules
firewall:
    sudo ufw status numbered

# ---------------------------------------------------------------------------
# Tailscale
# ---------------------------------------------------------------------------

# Tailscale status
ts:
    tailscale status

# Show Tailscale IP addresses
ts-ip:
    tailscale ip

# ---------------------------------------------------------------------------
# AdGuard
# ---------------------------------------------------------------------------

# Test AdGuard through LAN
dns:
    nslookup google.com 192.168.29.239

# Test AdGuard through Tailscale
dns-ts:
    nslookup google.com 100.80.240.46

# Follow AdGuard logs
adguard-logs:
    sudo docker logs -f --tail 100 adguard

# ---------------------------------------------------------------------------
# Home Assistant
# ---------------------------------------------------------------------------

# Follow Home Assistant logs
ha-logs:
    sudo docker logs -f --tail 100 homeassistant

# Restart Home Assistant
ha-restart:
    sudo docker restart homeassistant

# ---------------------------------------------------------------------------
# Voice Assistant
# ---------------------------------------------------------------------------

# Follow Linux Voice Assistant logs
voice-logs:
    sudo docker logs -f --tail 100 linux-voice-assistant

# Follow Whisper logs
whisper-logs:
    sudo docker logs -f --tail 100 whisper

# Follow Piper logs
piper-logs:
    sudo docker logs -f --tail 100 piper

# ---------------------------------------------------------------------------
# Monitoring
# ---------------------------------------------------------------------------

# Follow Homepage logs
homepage-logs:
    sudo docker logs -f --tail 100 homepage

# Show recently detected container updates
updates:
    sudo docker logs --since 168h diun 2>&1 | grep -iE 'New image found|updated|failed|Jobs completed'

# ---------------------------------------------------------------------------
# Docker maintenance
# ---------------------------------------------------------------------------

# Show all containers including stopped ones
ps-all:
    sudo docker ps -a

# Show Docker networks
networks:
    sudo docker network ls

# Show Docker volumes
volumes:
    sudo docker volume ls

# Remove unused Docker images
docker-prune:
    sudo docker image prune

# ---------------------------------------------------------------------------
# Git / infrastructure
# ---------------------------------------------------------------------------

# Show infrastructure repository status
git:
    git status --short

# Pull latest repository changes
pull:
    git pull

# Show recent infrastructure commits
history:
    git log --oneline -10
