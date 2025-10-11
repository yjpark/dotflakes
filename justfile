switch-home:
    #home-manager --flake .#yjpark switch
    home-manager --flake .#yjpark build

show:
    om show .

run *ARGS:
    nix run {{ARGS}}

update *ARGS:
    nix flake update {{ARGS}}
