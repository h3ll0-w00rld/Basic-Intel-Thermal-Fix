#!/bin/bash

echo "Installing necessary Intel-based thermal software and monitoring tools (Arch)"
sudo apt install thermald htop lm_sensors msr-tools

echo "Enabling thermald to run on startup"
sudo systemctl start thermald.service
sudo systemctl enable thermald.service

if [[ -z $(which rdmsr) ]]; then
    echo "msr-tools is not installed. Run 'sudo pacman -S (Depending on your distro) msr-tools' to install it." >&2
    exit 1
fi

if [[ ! -z $1 && $1 != "enable" && $1 != "disable" ]]; then
    echo "Invalid argument: Please type "disable" to disable, or "enable" to enable Turbo." >&2
    echo ""
    echo "Usage: $(basename $0) [disable|enable]"
    exit 1
fi

cores=$(cat /proc/cpuinfo | grep processor | awk '{print $3}')
for core in $cores; do
    if [[ $1 == "disable" ]]; then
        sudo wrmsr -p${core} 0x1a0 0x4000850089
    fi
    if [[ $1 == "enable" ]]; then
        sudo wrmsr -p${core} 0x1a0 0x850089
    fi
    state=$(sudo rdmsr -p${core} 0x1a0 -f 38:38)
    if [[ $state -eq 1 ]]; then
        echo "core ${core}: disabled"
    else
        echo "core ${core}: enabled"
    fi
    echo "To enable/disable turbo, type ./intel-anti-thermal.sh enable/disable."
done
#type ./intel-anti-thermal.sh enable or disable to toggle this.
