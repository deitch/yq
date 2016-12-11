#!/bin/bash

# error out if anything fails
set -e

# get our raw data
INFILE="./docker-compose.yml"
DATA=$(cat $INFILE)


# we must be passed an image name, or we run locally
if [[ -n "$IMAGE" ]]; then
    YQ="docker run -i --rm $IMAGE "
else
    YQ="./yq "
fi


runtest() {
    local filter="$1"
    local expected="$2"
    RET=$(echo "$DATA" | $YQ $filter)
    if [[ "$RET" != "$expected" ]]; then
        echo "Failed: $filter"
        echo "Expected:"
        echo "$expected"
        echo "Actual:"
        echo "$RET"
				return 1
    fi
}

# this should be a very simple set of tests
runtest .version '"2"'
runtest .services.web.image nginx
runtest . "$DATA"
runtest "" "$DATA"
runtest .services.web.environment "$(echo -e "$DATA" | awk '/ENV/ {print $1,$2}')"
runtest .services.web.environment[] "$(echo -e "$DATA" | awk '/ENV/ {print $2}')"

envdata=$(echo "$DATA" | grep ENV)
runtest .services.web.environment "$(echo -n "$envdata" | sed -e 's/^[ \t]*//g')"


echo "All tests pass!"
exit 0
