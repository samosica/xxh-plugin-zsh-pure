# This script will be executed ON THE HOST when you connect to the host.
# Put here your functions, environment variables, aliases and whatever you need.

CURR_DIR="$(cd "$(dirname "$0")" && pwd)"

fpath+=($CURR_DIR/pure)

autoload -U promptinit; promptinit
prompt pure
