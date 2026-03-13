#!/bin/bash
# Status line script: shows model + context usage percentage
# Reads JSON from stdin (provided by Claude Code)
jq -r '"[" + .model.display_name + "] " + (.context_window.used_percentage | tostring) + "% context | $" + (.cost.total_cost_usd | tostring | .[0:6])'
