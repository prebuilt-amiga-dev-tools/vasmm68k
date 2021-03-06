Param (
    [Parameter(Mandatory=$True)][string]$BUILD_RESULTS_DIR,
    [Parameter(Mandatory=$True)][string]$VASM_VERSION
)

$VASM_PACKAGE_VERSION = & windows/scripts/get-package-version.ps1 -VASM_VERSION $VASM_VERSION

if (Test-Path "${BUILD_RESULTS_DIR}/temp")
{
    Remove-Item -ErrorAction Stop -Force -Recurse "${BUILD_RESULTS_DIR}/temp"
}

mkdir -ErrorAction Stop -Force "${BUILD_RESULTS_DIR}/temp"
& choco install -y "${BUILD_RESULTS_DIR}/vasmm68k.${VASM_PACKAGE_VERSION}.nupkg"; if ($LASTEXITCODE -ne 0) { throw }
& vasmm68k_mot.exe -Fhunk -o "${BUILD_RESULTS_DIR}/temp/test_mot.o" "tests/test_mot.s"; if ($LASTEXITCODE -ne 0) { throw }; if (((Get-FileHash "tests/test_mot.o.expected").hash) -ne ((Get-FileHash "${BUILD_RESULTS_DIR}/temp/test_mot.o").hash)) { throw 'vasmm68k_mot output does not match reference' }
& vasmm68k_std.exe -Fhunk -o "${BUILD_RESULTS_DIR}/temp/test_std.o" "tests/test_std.s"; if ($LASTEXITCODE -ne 0) { throw }; if (((Get-FileHash "tests/test_std.o.expected").hash) -ne ((Get-FileHash "${BUILD_RESULTS_DIR}/temp/test_std.o").hash)) { throw 'vasmm68k_std output does not match reference' }
& vobjdump.exe "tests/test_vobjdump.o" > "${BUILD_RESULTS_DIR}/temp/test_vobjdump.dis"; if ($LASTEXITCODE -ne 0) { throw }; if (Compare-Object -ReferenceObject (Get-Content "tests/test_vobjdump.dis.expected") -DifferenceObject (Get-Content "${BUILD_RESULTS_DIR}/temp/test_vobjdump.dis")) { throw 'vobjdump output does not match reference' }
& choco uninstall vasmm68k; if ($LASTEXITCODE -ne 0) { throw }
Remove-Item -ErrorAction Stop -Force -Recurse ${BUILD_RESULTS_DIR}/temp
