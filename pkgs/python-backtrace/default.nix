{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "backtrace";
  version = "0.4.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "nir0s";
    repo = "backtrace";
    # Pinned: upstream has no tags; this is the commit that matched the previous fixed-output hash.
    rev = "a1f75c956f669a6175088693802d5392e6bd7e51";
    hash = "sha256-F4tvYQ9XmKALMiwak+oa7nqWoLe2zvVOiTv9/gmQfcQ=";
  };

  doCheck = false;

  meta = {
    description = "Makes Python tracebacks easier to see";
    homepage = "https://github.com/nir0s/backtrace";
    license = lib.licenses.asl20;
  };
}
