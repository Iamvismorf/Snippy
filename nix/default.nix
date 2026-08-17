{
  stdenv,
  lib,
  qt6,
  cmake,
  ninja,
}:
stdenv.mkDerivation {
  name = "snippy-qml-plugin";
  src = ../plugins;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
  ];

  dontWrapQtApps = true;
  cmakeFlags = [
    (lib.cmakeFeature "INSTALL_QMLDIR" qt6.qtbase.qtQmlPrefix)
  ];
}
