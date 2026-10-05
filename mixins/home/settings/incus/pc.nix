{lib, pkgs, ...}: {
  # Adds the 'pc' remote to incus if not already present.
  # Note: certificate trust must be set up manually after activation:
  #   incus remote add pc https://pc.yjpark.org:8443
  home.activation.incuspcRemote = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! ${pkgs.incus}/bin/incus remote list --format csv 2>/dev/null | grep -q "^pc,"; then
      $VERBOSE_ECHO "Registering incus remote: pc (https://pc.yjpark.org:8443)"
      ${pkgs.incus}/bin/incus remote add pc https://pc.yjpark.org:8443 || true
    fi
  '';
}
