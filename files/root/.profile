# This is where we designate the branch to use from our script repos
# main is production and we can set others for testing.
REPO=main
export REPO

# Source our base OpenWRT functions
. /lib/functions.sh

# Log to the system log and echo if needed
log_say()
{
    echo "Log Say: ${1}"
    logger -s "Log Say: ${1}"
    echo "${1}" >> "/tmp/console_log_say.log"
}

install_packages() {
    # Update the package list
    log_say "Installing packages: ${1}"
    local count=$(echo "${1}" | wc -w)
    log_say "Packages to install: ${count}"

    # Check for upgradable packages
    local upgradable=$(opkg list-upgradable | cut -d ' ' -f 1)

    for package in ${1}; do
        if ! opkg list-installed | grep -q "^$package -"; then
            log_say "Installing $package..."
            # use --force-maintainer to preserve the existing config
            opkg install --force-maintainer $package
            if [ $? -eq 0 ]; then
                log_say "$package installed successfully."
            else
                log_say "Failed to install $package."
            fi
        else
            log_say "$package is already installed."
            # Check if the package is in the list of upgradable packages
            if echo "${upgradable}" | grep -q "^$package$"; then
                log_say "An upgrade is available for $package."
                log_say "Upgrading $package..."
                opkg upgrade $package
                if [ $? -eq 0 ]; then
                    log_say "$package upgraded successfully."
                else
                    log_say "Failed to upgrade $package."
                fi
            else
                log_say "$package is up to date."
            fi
        fi
    done
}

export log_say
export install_packages