#!/bin/bash
set -e
umask 002

# Discover packages
packages=$(find "$PACKAGES_PATH" -maxdepth 3 -type f -name composer.json \
    -exec grep -Po '"name":\s*"[^"/]+/[^"/]+"' {} \; \
    | cut -d: -f2 | tr -d ' "' | awk 'NF{print $0 ":@dev"}' | xargs)

# Manage repositiories
# Workaround: first, we want to use packages from $PACKAGES_PATH, and then from Magento repository. The order of repositories is important.
gosu "application" composer config -d "$MAGENTO_PATH" repositories.0 "{\"type\": \"path\", \"url\": \"$PACKAGES_PATH/*/*\", \"options\": {\"symlink\": true}}" 2>/dev/null
gosu "application" composer config -d "$MAGENTO_PATH" repositories.1 "{\"type\": \"composer\", \"url\": \"https://repo.magento.com/\"}" 2>/dev/null

# Require packages
[ -n "$packages" ] && gosu "application" composer require -d "$MAGENTO_PATH" $packages

# Check if all packages have been symlinked
for package in $packages; do
    name="$(echo $package | cut -d: -f1)"

    if [ ! -L "$MAGENTO_PATH/vendor/$name" ]; then
        echo "$name package has not been symlinked... terminating"
        exit 2
    fi
done
