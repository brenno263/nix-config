

usage() {
    echo "Usage $0 <nixos_configuration_name> [-f]"
    echo "    -f    Update flake input as well"
    exit 1
}

if [ -z $1 ]; then
    echo "Error: Missing argument."
    usage
    exit 1
fi

cd "$(dirname "$0")"

echo "Updating git repo..."

git pull

if [ "$2" = "-f" ]; then
    echo "Flake update option set. Updating flake inputs..."
    nix flake update
fi

echo "Rebuilding system..."
sudo nixos-rebuild switch --flake .#$1