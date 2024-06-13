#!/bin/bash

WORKDIR=`pwd`
CFGFILE="$WORKDIR/config.yml"

if [ ! -f "$CFGFILE" ]; then
    echo "The file '$CFGFILE' does not exist. Did you mount $WORKDIR and put a config file in there?" >&2
    exit 1
fi

PORT=587  # Default Port

found_receive=0
while IFS= read -r line; do
    # Remove all whitespace from the line
    trimmed_line=$(echo "$line" | tr -d '[:space:]')

    # Check if the line starts with "receive:"
    if [[ $trimmed_line == receive:* ]]; then
        found_receive=1
        continue
    fi

    # If "receive:" line was found, look for the next "port:" line
    if [[ $found_receive -eq 1 && $trimmed_line == *port:* ]]; then
        # Check if the line starts with #
        if ! [[ $trimmed_line == \#* ]]; then
            # Split the trimmed line by ":" and get the port number
            PORT=$(echo "$trimmed_line" | cut -d':' -f2)
        fi
        break
    fi
done < "$CFGFILE"


# Run SMTP2Graph
node /bin/smtp2graph.js --receive.port=$PORT
