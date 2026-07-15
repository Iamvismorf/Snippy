let
  pkgs = import <nixpkgs> {};
in
  pkgs.mkShell {
    packages = with pkgs.qt6Packages;
      [
        qtbase
        qtdeclarative
        # full
      ]
      ++ [
        pkgs.qt6.wrapQtAppsHook
        pkgs.makeWrapper
        pkgs.kdePackages.kirigami
        pkgs.qtcreator
        pkgs.cmake
        pkgs.ninja
      ];

    QT_LOGGING_RULES = "quickshell.dbus.properties=false;kf.kirigami.platform=false";

    # Qt 6 specific environment variables
    shellHook = ''
      export QML_IMPORT_PATH=$(pwd)/build/qml:${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}
      setQtEnvironment=$(mktemp)
      random=$(openssl rand -base64 20 | sed "s/[^a-zA-Z0-9]//g")
      makeShellWrapper "$(type -p sh)" "$setQtEnvironment" "''${qtWrapperArgs[@]}" --argv0 "$random"
      sed "/$random/d" -i "$setQtEnvironment"
      source "$setQtEnvironment"
    '';
  }
