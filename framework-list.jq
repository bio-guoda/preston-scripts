#
# jq filter to select active frameworks . 
#
.frameworks[] | select(.active) | .registered_time |= (now - .) / (24*3600) | .days_active = .registered_time | .days_active |= round | { name: .name, active: .active, id: .id, webui_url: .webui_url, days_active: .days_active, resources: .used_resources }


