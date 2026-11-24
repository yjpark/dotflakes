{ ... }:

let
  moonFile = "0000007a6ad99c17.moon";
  moonDirectory = "/var/lib/zerotier-one/moons.d";
in
{
  systemd.services.zerotierone.preStart = ''
    mkdir -p ${moonDirectory}
    ln -sfn ${./0000007a6ad99c17.moon} ${moonDirectory}/${moonFile}
  '';
}
