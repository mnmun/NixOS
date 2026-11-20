{
  description = "B550";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    keek = {
      url = "github:mnmun/keek/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    scripts = {
      url = "./scripts";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    helix = {
      url = "github:helix-editor/helix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home = {
      url = "./home";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        home-manager.follows = "home-manager";
        helix.follows = "helix";
        scripts.follows = "scripts";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      home,
      scripts,
      keek,
      ...
    }:
    let
      stateVersion = "25.05";
    in
    {
      nixosConfigurations = {
        B550 = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              system
              stateVersion
              scripts
              keek
              ;
          };
          modules = [
            ./host/hardware-configuration.nix
            ./host/configuration.nix
            (home.makeHomeModule "a" stateVersion system)
            (home.makeHomeModule "w" stateVersion system)
          ];
        };
      };
    };
}
