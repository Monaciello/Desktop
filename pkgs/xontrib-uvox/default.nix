{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonPackage rec {
  pname = "xontrib-uvox";
  version = "0.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "LoicGrobol";
    repo = "xontrib-uvox";
    rev = "edecbfe0d1a816ba908f382119af975b373c5c9b";
    hash = "sha256-VM/TV3/L1QCw/kmsw/9JTO61CnWuP0l8s3FyGbNtLqE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'license = "MIT"' 'license = {text = "MIT"}'
  '';

  build-system = [
    python3Packages.setuptools
    python3Packages.wheel
  ];

  dependencies = [
    python3Packages.xonsh
    python3Packages.uv
  ];

  doCheck = false;

  meta = with lib; {
    description = "Python virtual environment manager for xonsh using uv";
    homepage = "https://github.com/LoicGrobol/xontrib-uvox";
    license = licenses.mit;
    maintainers = [
      {
        name = "Loïc Grobol";
        github = "LoicGrobol";
      }
      {
        name = "sasha";
        github = "monaciello";
      }
    ];
  };
}
