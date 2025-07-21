{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls";
  };

  outputs = { nixpkgs, ... } @ inputs: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
    };

  in {
    devShells.${system}.default = pkgs.mkShell {
      name = "lang";
      packages = with pkgs; [
        inputs.zig.packages.${system}.master
        inputs.zls.packages.${system}.default
        lldb hyperfine clang-tools
      ];
    };
  };
}
