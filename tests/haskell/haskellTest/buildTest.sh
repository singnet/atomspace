BIN_DIR=$1

if [ "$(id -u)" -ne 0 ]
then
  # Build haskell bindings package.
  stack test --no-run-tests --extra-lib-dirs=${BIN_DIR}
  patchelf --set-rpath ${BIN_DIR} `stack path --dist-dir`"/build/haskell-test-suite/haskell-test-suite"
else
  echo "Can't build Haskell-Tests as root"
  exit 1
fi
