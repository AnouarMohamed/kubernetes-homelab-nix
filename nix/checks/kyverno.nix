{ pkgs }:
let
  yaml = pkgs.formats.yaml { };
  policyObjects = builtins.filter
    (object: builtins.elem object.kind [ "ClusterPolicy" "ValidatingPolicy" "ImageValidatingPolicy" ])
    (import ../policies/resources.nix);
  resourceObjects = import ../tests/kyverno-resources.nix;
  policyFiles = map (object: yaml.generate "${object.metadata.name}.yaml" object) policyObjects;
  resourceFiles = map (object: yaml.generate "${object.metadata.name}.yaml" object) resourceObjects;
  valuesFile = yaml.generate "values.yaml" (builtins.head (import ../tests/kyverno-values.nix));
  testDefinition = (builtins.head (import ../tests/kyverno-test.nix)) // {
    policies = map toString policyFiles;
    resources = map toString resourceFiles;
    variables = toString valuesFile;
  };
  testFile = yaml.generate "kyverno-test.yaml" testDefinition;
in
pkgs.runCommand "kyverno-policy-tests" { nativeBuildInputs = [ pkgs.kyverno ]; } ''
  mkdir suite
  cp ${testFile} suite/kyverno-test.yaml
  kyverno test suite
  touch "$out"
''
