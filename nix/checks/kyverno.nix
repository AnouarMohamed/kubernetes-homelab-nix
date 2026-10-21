{ pkgs }:
let
  yaml = pkgs.formats.yaml { };
  policyObjects = builtins.filter
    (object: builtins.elem object.kind [ "ClusterPolicy" "ValidatingPolicy" "ImageValidatingPolicy" ])
    (import ../policies/resources.nix);
  resourceObjects = import ../tests/kyverno-resources.nix;
  namedPolicyFiles = map (object: {
    name = "${object.metadata.name}.yaml";
    file = yaml.generate "${object.metadata.name}.yaml" object;
  }) policyObjects;
  namedResourceFiles = map (object: {
    name = "${object.metadata.name}.yaml";
    file = yaml.generate "${object.metadata.name}.yaml" object;
  }) resourceObjects;
  valuesFile = yaml.generate "values.yaml" (builtins.head (import ../tests/kyverno-values.nix));
  testDefinition = (builtins.head (import ../tests/kyverno-test.nix)) // {
    policies = map (entry: entry.name) namedPolicyFiles;
    resources = map (entry: entry.name) namedResourceFiles;
    variables = "values.yaml";
  };
  testFile = yaml.generate "kyverno-test.yaml" testDefinition;
in
pkgs.runCommand "kyverno-policy-tests" { nativeBuildInputs = [ pkgs.kyverno ]; } ''
  mkdir suite
  cp ${testFile} suite/kyverno-test.yaml
  cp ${valuesFile} suite/values.yaml
  ${builtins.concatStringsSep "\n" (map (entry: "cp ${entry.file} suite/${entry.name}") (namedPolicyFiles ++ namedResourceFiles))}
  kyverno test suite
  touch "$out"
''
