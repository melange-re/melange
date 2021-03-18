let
  pkgs = import ../sources.nix { };


in

import ./.. {
  inherit pkgs;
}
