#!/usr/bin/env bash
set -eu # exit on error or undefined variable
bash -c 'set -o pipefail' # return code of first cmd to fail in a pipeline

EXPECTED_ARGS=1

if [[ $# -lt ${EXPECTED_ARGS} ]]
then
  echo "Usage:"
  echo "  `basename $0` TARGET"
  echo ""
  echo "Execute the specified target"
  echo ""
  echo "Examples:"
  echo "  `basename $0` app"
  echo "  `basename $0` test"
  exit 1
fi

TARGET=${1}

# Binary to kill/restart,
APP_EXE=${APP_EXE}
# Use full path to avoid conflicts
APP_EXE_PATH="$(pwd)/${APP_EXE}"

# Depends lists, and can be used to check for, programs this script depends on
depends() {
    if [[ ${1} == "go" ]]; then
        go version >/dev/null 2>&1 || \
        { printf >&2 \
            "Install https://golang.org\n"; exit 1; }
    elif [[ ${1} == "fswatch" ]]; then
        fswatch --version >/dev/null 2>&1 || \
        { printf >&2 \
            "Install https://github.com/emcrisostomo/fswatch\n"; exit 1; }
    else
        echo "unknown dependency ${1}"
        exit 1
    fi
}

detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo 'macOS'
        ;;
        Linux)
            echo 'linux'
        ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            echo 'windows'
        ;;
        # Detect additional OS's here...
        # See correspondence table at the bottom of this link
        # https://stackoverflow.com/a/27776822/639133
        *)
            echo 'other'
        ;;
    esac
}

# Kill process by matching full path to bin
kill_path() {
    OS=$(detect_os)
    if [[ ${OS} == "macOS" ]] || [[ ${OS} == "linux" ]]; then
        PID=$(pgrep -fx "${1}" || echo "")
        if [[ -n "${PID}" ]]; then
            kill ${PID}
        fi
    else
        echo "OS ${OS} not implemented"
        exit 1
    fi
}

app_build_dev() {
    echo ${FUNCNAME}
    scripts/build.dev.sh
}

app_kill() {
    echo ${FUNCNAME}
    kill_path ${APP_EXE_PATH}
}

# Run the binary, no live reload.
# Use full path to avoid conflicts
app_run() {
    echo ${FUNCNAME}
    depends go
    app_kill
    app_build_dev; (if [[ "${?}" -eq 0 ]]; then (${APP_EXE_PATH} ); fi)
}

# Restart the binary (for use with fswatch).
# Use full path to avoid conflicts
app_restart() {
    echo ${FUNCNAME}
    depends go
    app_kill
    app_build_dev; (if [[ "${?}" -eq 0 ]]; then (${APP_EXE_PATH}& ); fi)
}

# Run app bin with live reload
# Watch .go files for changes then recompile & try to start bin
# will also kill bin on ctrl+c
# fswatch includes everything unless an exclusion filter says otherwise
# https://stackoverflow.com/a/37237681/639133
app() {
    echo ${FUNCNAME}
    depends fswatch
    app_restart
    fswatch -or --exclude ".*" \
    --include "^.*pkg.*go$" \
    --include "./main.go$" \
    --include "./middleware.go$" ./ | \
	xargs -n1 bash -c "./make.sh app_restart" || bash -c "./make.sh app_kill"
}

# Execute target if it's a func defined in this script.
TYPE=$(type -t ${TARGET} || echo "undefined")
if [[ ${TYPE} == "function" ]]; then
    # Additional arguments, after the target, are passed through.
    # For example, `./make.sh depends something`
    ${TARGET} ${@:2}
else
    echo "TARGET ${TARGET} not implemented"
    exit 1
fi
