{
  lib,
  python3,
  fetchFromGitHub,
  uv,
}:
python3.pkgs.buildPythonPackage {
  pname = "xontrib-uvox";
  version = "0.1.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "LoicGrobol";
    repo = "xontrib-uvox";
    rev = "edecbfe0d1a816ba908f382119af975b373c5c9b";
    hash = "sha256-VM/TV3/L1QCw/kmsw/9JTO61CnWuP0l8s3FyGbNtLqE=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
    pythonRelaxDepsHook
  ];

  pythonRemoveDeps = [ "uv" ];

  propagatedBuildInputs = with python3.pkgs; [
    xonsh
  ];

  postPatch = ''
    substituteInPlace xontrib_uvox/uvoxapi.py \
      --replace-warn "from uv import find_uv_bin" 'def find_uv_bin(): return "${uv}/bin/uv"'
  '';

  doCheck = false;

  pythonImportsCheck = [
    "xontrib_uvox"
  ];

  meta = with lib; {
    description = "Python virtual environment manager for xonsh using uv";
    homepage = "https://github.com/LoicGrobol/xontrib-uvox";
    license = licenses.mit;
    mainProgram = "xontrib-uvox";
    maintainers = with maintainers; [
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
