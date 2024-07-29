#!/bin/sh

# Getting current fanspeed setting from pwm1
fanSetting=$(cat /sys/class/hwmon/hwmon0/pwm1)
# Getting current temperature from sensors command
currentTemp=$(sensors -u | grep temp1_input | cut -c 16-)
# Remove the decimals from sensor reading
currentTemp=$(echo ${currentTemp%.*})
# Set threshold temperature to start raising or lowering fan speed at
thresholdTemp=55
# Minimum fan speed to run, from my test any value below 36 causes the fan to oscillate between 0 and 300rpm
minimumFanSpeed=36

echo "Fan speed   : ${fanSetting}"
echo "Current temp: ${currentTemp}"

case 1 in
    $(($currentTemp > 75)))
        echo "Set speed to 73"
        newFanspeed=73
        ;;
    $(($currentTemp > 70)))
        echo "Set speed to 60"
        newFanspeed=60
        ;;
    $(($currentTemp > 65)))
        echo "Set speed to 50"
        newFanspeed=50
        ;;
    $(($currentTemp > 60)))
        echo "Set speed to 40"
        newFanspeed=40
        ;;
    *)
        echo "Set speed to 36"
        newFanspeed=36
        ;;
esac

if [ "$newFanspeed" -ne "$fanSetting" ]; then
    echo "Changed"

    # Unlock pwm1 file so we can modify it
    chmod 644 "/sys/class/hwmon/hwmon0/pwm1"
    echo $newFanspeed > /sys/class/hwmon/hwmon0/pwm1
    # Lock pwm1 file so system can't change our values back again
    chmod 444 "/sys/class/hwmon/hwmon0/pwm1"
else
    echo "No change"
fi

exit 0

