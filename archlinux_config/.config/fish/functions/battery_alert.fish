function battery_alert
    set battery_level (acpi -b | grep -Po '\d+(?=%)')
    if test $battery_level -le 20
        notify-send 电量不足 "当前电量：$battery_level%，请及时充电！" --urgency=critical
        for i in (seq 5)
            canberra-gtk-play --id="dialog-warning"
            sleep 1
        end
    end
end
