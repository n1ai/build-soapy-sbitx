# Set TOP if it isn't already set in the environment
: "${TOP:=${HOME}}"
# Set JFLAG if it isn't already set in the environment
: "${JFLAG:=-j$(nproc)}"
