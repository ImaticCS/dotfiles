alias rebuild='nh os switch --ask ~/nixos -H vm'

case ":$PATH:" in
    *":$HOME/nixos/scripts:"*) ;;
    *) export PATH="$PATH:$HOME/nixos/scripts" ;;
esac