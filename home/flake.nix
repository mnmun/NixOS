{
  description = "home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    scripts = {
      url = "../scripts";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs =
    {
      home-manager,
      helix,
      scripts,
      ...
    }:
    {
      makeHomeModule = userName: stateVersion: system: {
        imports = [
          home-manager.nixosModules.home-manager

          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              extraSpecialArgs = {
                inherit
                  system
                  helix
                  scripts
                  ;
              };

              users.${userName} = {
                imports = [
                  ./home.nix
                  ./git.nix
                  ./bash.nix
                  ./helix.nix
                  ./kitty.nix
                  ./syncthing.nix
                ];
                home = {
                  username = userName;
                  homeDirectory = "/home/${userName}";
                  stateVersion = stateVersion;
                };
              };
            };

            environment.systemPackages = [
              home-manager.packages.${system}.home-manager
            ];
          }
        ];
      };
    };
}
