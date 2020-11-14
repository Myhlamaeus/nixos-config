{ pkgs, ... }:

{
  custom.editors = { env = { bin.packages = with pkgs; [ ledger ]; }; };
}
