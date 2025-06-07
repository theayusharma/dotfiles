# #!/bin/bash
#
# # get windows
# json_data=$(hyprctl clients -j)
# if [ -z "$json_data" ]; then
#     echo "Error: Hyprland is not running or 'hyprctl' failed."
#     exit 1
# fi
#
# # format (address, workspace id & name, title)
# formatted_data=$(echo "$json_data" | jq -r 'sort_by(.focusHistoryID) | .[] | [.address, .workspace.id, .title, .focusHistoryID] | @tsv')
# if [ -z "$formatted_data" ]; then
#     echo "No windows found."
#     exit 1
# fi
#
# # use fuzzel to select window
# selected=$(echo "$formatted_data" | awk -F'\t' '{print $2 "    " $3}' | fuzzel --dmenu --placeholder="search window!")
#
# # match selection with address
# if [ -n "$selected" ]; then
#     address=$(echo "$formatted_data" | awk -F'\t' -v selected="$selected" '$2 "    " $3 == selected {print $1}')
#     hyprctl dispatch focuswindow address:"$address"
# fi


# Get windows
json_data=$(hyprctl clients -j)
if [ -z "$json_data" ]; then
    echo "Error: Hyprland is not running or 'hyprctl' failed."
    exit 1
fi

# Format (address, workspace id & name, title)
formatted_data=$(echo "$json_data" | jq -r 'sort_by(.focusHistoryID) | .[] | [.address, .workspace.id, .title, .focusHistoryID] | @tsv')
if [ -z "$formatted_data" ]; then
    echo "No windows found."
    exit 1
fi

# Use rofi to select window
selected=$(echo "$formatted_data" | awk -F'\t' '{print $2 "    " $3}' | rofi -dmenu -p "Search window!" -theme "$HOME/.config/rofi/config-activeapps.rasi")

# Match selection with address
if [ -n "$selected" ]; then
    address=$(echo "$formatted_data" | awk -F'\t' -v selected="$selected" '$2 "    " $3 == selected {print $1}')
    hyprctl dispatch focuswindow address:"$address"
fi
