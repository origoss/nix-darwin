{ pkgs }:

with pkgs; [ 
  git
  git-crypt
  pre-commit
  gnupg

  python3
  virtualenv

  oh-my-zsh
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
  minikube
  kubernetes-helm
  (google-cloud-sdk.withExtraComponents
    [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
]

