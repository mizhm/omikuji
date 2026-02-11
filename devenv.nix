{ pkgs, lib, config, inputs, ... }:

{
  
  packages = [ pkgs.git ];

  languages.javascript = {
    enable = true;
    bun.enable = true;
  };

  languages.go = {
    enable = true;
  };
}
