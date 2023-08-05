#!/bin/bash

printUsage() {
    echo "Usage: helper.sh install|uninstall|upgrade|package name-of-the-script"
    echo "   or: helper.sh show-dev-console"
}

install() {
    local scriptName=$1
    kpackagetool5 -i "$scriptName"
}

uninstall() {
    local scriptName=$1
    kpackagetool5 -r "$scriptName"
}

upgrade() {
    local scriptName=$1
    kpackagetool5 -u "$scriptName"
}

package() {
    local scriptName=$1

    cd "$scriptName" || {
        printerr "Failed to \`cd\` into '$scriptName'"
        exit 1
    }

    # Check if directory contains necessary files
    if [ ! -d "contents" ]; then
        printerr "'contents' directory is missing in target directory"
        exit 1
    fi
    if [ ! -f "metadata.desktop" ]; then
        printerr "'metadata.desktop' file is missing in target directory"
        exit 1
    fi

    local scriptVersion
    scriptVersion=$(grep -Po "Version=\K(.*)" metadata.desktop)
    zip -r "$scriptName-$scriptVersion.kwinscript" contents metadata.desktop

    cd ..
}

show-dev-console() {
    # Try to use the command for Plasma versions >=5.23
    RESULT=$(plasma-interactiveconsole --kwin)

    # If that fails, try to run the command for Plasma versions <5.23
    if [ "$RESULT" != 0 ]; then
        RESULT=$(qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.showInteractiveKWinConsole)

        # If that also fails, plasma may have removed the >=5.23 command as well in the future
        if [ "$RESULT" != 0 ]; then
            printerr "Failed to show dev console."
        fi
    fi
}

printerr() {
    printf "%s\n" "$*" >&2
}

main() {
    local command=$1

    case $command in
        install|uninstall|upgrade|package)
            [[ -z "$2" ]] && {
                printUsage
                exit 1
            }
            $command "$2"
            ;;

        show-dev-console)
            $command
            ;;

        *)
            printUsage
            exit 1
            ;;
    esac
}

main "$@"
