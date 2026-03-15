{lib, pkgs, ...}: {
  # Adds the 'edger' remote to incus if not already present.
  # Note: certificate trust must be set up manually after activation:
  #   incus remote add edger https://edger.yjpark.org:8443
  home.activation.incusEdgerRemote = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! ${pkgs.incus}/bin/incus remote list --format csv 2>/dev/null | grep -q "^edger,"; then
      $VERBOSE_ECHO "Registering incus remote: edger (https://edger.yjpark.org:8443)"
      ${pkgs.incus}/bin/incus remote add edger https://edger.yjpark.org:8443 || true
    fi
  '';
}
