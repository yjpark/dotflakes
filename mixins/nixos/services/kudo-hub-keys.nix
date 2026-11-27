{ pkgs, ... }: {
  services.hub.trustFile = pkgs.writeText "kudo-hub-trust" ''
    hub 4bcecd34ca3fe63626a026c9e44e7f9f76de962e11cd323f367b08236778419e peer,consumer
    edger cad2c628cf11b0d3536efb564eb92ba71c21b40dd07ba3fe029c2e57672af751 peer,node,session,consumer
    pc e58d9dcba52cc1d0414e8a7cbeba0e00a1051a000d0d5cdb723ee31bd3eb75b6 peer,node,session,consumer
    yolo 7e517cb31f88c4327836851b632803cc6f2d399bfdb570c4d1c2c1272d5d8430 node,session,consumer
    yolo 98eedc61c48832ce962939d6c8fbb9f3c175b6dcf47198a69c6785ad9af3edee node,session,consumer
  '';
}
