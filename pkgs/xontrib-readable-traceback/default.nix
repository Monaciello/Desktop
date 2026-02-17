{
  lib,
  python3,
  fetchFromGitHub,
  python-backtrace,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "xontrib-readable-traceback";
  version = "0.4.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "vaaaaanquish";
    repo = "xontrib-readable-traceback";
    rev = version;
    sha256 = "sha256-ek+GTWGUpm2b6lBw/7n4W46W2R0Gy6JxqWoLuQilCXQ=";
  };

  propagatedBuildInputs =
    (with python3.pkgs; [
      xonsh
      colorama
    ])
    ++ [ python-backtrace ];

  doCheck = false;

  prePatch = ''
    substituteInPlace xontrib/readable-traceback.xsh \
      --replace 'sys.stderr.write(msg)' '__flush(msg)'
  '';

  meta = with lib; {
    description = "Make traceback easier to see for the xonsh shell";
    homepage = "https://github.com/vaaaaanquish/xontrib-readable-traceback";
    license = licenses.mit;
  };
}
