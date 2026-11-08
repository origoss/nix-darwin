{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    git-crypt
    pre-commit
    gnupg

    # Programming
    python3
    go

    jq
    fzf
    tree
    direnv
    nix-direnv

    # VPN
    openfortivpn
    wireguard-tools

    # Shell
    zsh
    zsh-autosuggestions
    zsh-nix-shell
    zsh-syntax-highlighting

    # K8s
    k9s
    kustomize
    kubectl
    kubernetes-helm
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])

    fastfetch
    claude-code
    ollama
    pandoc
    gh

    glow
  ];
}
