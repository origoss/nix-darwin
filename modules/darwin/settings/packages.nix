{ pkgs }:

with pkgs; [ 
  git
  git-crypt
  pre-commit
  gnupg

  # Programing
  python3
  virtualenv
  go
  neovim

  fzf-zsh
  
  jq
  fzf
  tree
  direnv
  nix-direnv
  
  # VPN
  openfortivpn
  
  # Shell
  zsh
  zsh-autosuggestions
  zsh-nix-shell
  zsh-syntax-highlighting

  # K8s
  k9s
  kustomize
  kubectl
  kubernetes-polaris
  minikube
  kubernetes-helm
  (google-cloud-sdk.withExtraComponents
    [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])

  neofetch
]


