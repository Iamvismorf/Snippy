buildir := "build"

configure:
   cmake -GNinja -B {{buildir}} -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_BUILD_TYPE=Release

build:
   cmake --build {{buildir}}

clean:
   rm -fr {{buildir}}
