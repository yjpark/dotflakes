{flake, ...}: {
  imports = [
    (flake.inputs.self + /mixins/home/ai)
  ];
}
