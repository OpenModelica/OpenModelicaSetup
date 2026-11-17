# OpenModelicaSetup

OpenModelica Windows installer based on [NSIS](https://nsis.sourceforge.io/Main_Page).

## Dependencies

  - [NSIS 3.0.4](https://nsis.sourceforge.io/Main_Page)
    - Copy `AccessControl.dll` (checked into this repo) into your NSIS Unicode
      plugin directory, e.g. into `C:\Program Files (x86)\NSIS\Plugins\x86-unicode`.
  - [git](https://git-scm.com/)
  - [OMDev](https://gitlab.liu.se/OpenModelica/OMDevUCRT)
  - (optional) [SignTool](https://learn.microsoft.com/en-us/windows/win32/seccrypto/signtool),
    part of
    [Microsoft Windows Software Development Kit](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/).

## Build Windows installer

### Environment variables

You'll need to export all tools to `PATH` environment variable in your MSYS2 UCRT64 shell
`%OMDEV%\tools\msys\ucrt64.exe`:

```bash
export PATH=$PATH:/c/Program\ Files/Git/bin
export PATH=$PATH:/c/Program\ Files\ \(x86\)/NSIS/Bin
```

Also make sure to set environment variables

  - `OMDEV`, e.g. `c:\\OMDev`
  - `OPENMODELICAHOME`, e.g. `d:\\path\\to\\OpenModelica\\build_cmake\\install_cmake`
  - `OPENMODELICALIBRARY`, e.g. `d:\\path\\to\\OpenModelica\\build_cmake\\install_cmake\\lib\\omlibrary`

with Windows style paths using `\`.

Build:

  - OpenModelica
  - OpenModelica libraries
  - OMPython
  - OMSimulator
  - OMSens

Download the HTML and PDF versions of OpenModelica User's Guide:

```bash
cd ${OPENMODELICAHOME}/share/doc/omc
wget --no-check-certificate https://openmodelica.org/doc/openmodelica-doc-latest.tar.xz
tar -xJf openmodelica-doc-latest.tar.xz --strip-components=2
rm openmodelica-doc-latest.tar.xz
wget --no-check-certificate https://openmodelica.org/doc/OpenModelicaUsersGuide/OpenModelicaUsersGuide-latest.pdf
```

## Run NSIS

Start `%OMDEV%\tools\msys\ucrt64.exe` or `%OMDEV%\tools\msys\mingw64.exe` and run:

```bash
export PLATFORM="64"        # 64 or 32 bit
export OPENMODELICA_SOURCE_DIR="d:\\path\\to\\OpenModelica"
export REVISION=`cd $OPENMODELICA_SOURCE_DIR; git describe --match "v*.*" --always`
export REVISION_SHORT=`cd $OPENMODELICA_SOURCE_DIR; git describe --match "v*.*" --always --abbrev=0`
export PRODUCT_VERSION="${REVISION_SHORT:1}"
# make a valid VIProductVersion by stripping everything after "-"
BEGIN=${PRODUCT_VERSION/-*/}
PRODUCT_VERSION=${PRODUCT_VERSION::${#BEGIN}}
PRODUCT_VERSION=${PRODUCT_VERSION}.0

# derive MSYSRUNTIME from MSYSTEM (set by the MSYS2 shell you're running in)
MSYSRUNTIME="mingw"
if [ "${MSYSTEM}" = "UCRT64" ]; then
  MSYSRUNTIME="ucrt"
fi

# generate the list of files for the installer from your CMake install directory
python GenerateFilesList.py --MSYSRUNTIME="${MSYSRUNTIME}" --PLATFORMVERSION="${PLATFORM}" \
       --OPENMODELICAHOME="${OPENMODELICAHOME}" --OPENMODELICASOURCEDIR="${OPENMODELICA_SOURCE_DIR}"

makensis //DMSYSRUNTIME="${MSYSRUNTIME}" \
         //DPLATFORMVERSION="${PLATFORM}" \
         //DOMVERSION="${REVISION:1}" \
         //DPRODUCTVERSION="${PRODUCT_VERSION}" \
         OpenModelicaSetup.nsi
```

> [!NOTE]
> `PRODUCT_VERSION` needs to be in `X.X.X.X` format.

> [!NOTE]
> `OMVERSION` is the full revision without the leading `v`, e.g. `1.27.0` for a release and
> `1.28.0-dev-1962-g6e348e217c` for a nightly build. Add `//DOMNIGHTLY=1` for anything that is
> not built from a release tag.

## Multiple installations

Different versions can be installed side by side
([OpenModelica#5809](https://github.com/OpenModelica/OpenModelica/issues/5809)). The version is
part of everything the installer registers:

  - registry keys `SOFTWARE\OpenModelica <version>` (`Path`, `InstallMode`, `Version`, `Nightly`)
    and `SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenModelica <version>`,
  - environment variable `OPENMODELICAHOME_<version>`, with the version sanitized to letters,
    digits and underscores, e.g. `OPENMODELICAHOME_1_27_0`,
  - default installation directory and start menu folder.

The installer handles what is already installed as follows:

  - the same version is uninstalled first (or the setup quits),
  - a release from before the side by side installations: offers to uninstall it,
  - another nightly build, when a nightly build is installed: offers to uninstall it,
  - any other version is kept.

The component *Default installation* (selected by default) makes the installed version the one
that `OPENMODELICAHOME` points to and that opens the `.mo` and `.onb` files. When the default
installation is uninstalled, the highest remaining version takes over.

Command line options, in addition to the NSIS ones (`/S`, `/D=<directory>`):

  - `/DEFAULT=0` do not make this installation the default one,
  - `/REMOVENIGHTLIES` with `/S`: uninstall the other nightly builds when a nightly build is
    installed. A silent install always uninstalls the same version and a release from before the
    side by side installations, as it did before.

> [!WARNING]
> `OpenModelicaSetup.nsi` compresses with `SetCompressor /FINAL LZMA`, NSIS's
> slowest but best-ratio compressor. It single-threads through the entire MSYS2
> toolchain plus your OpenModelica install (tens of thousands of files, several
> GB), so a full `makensis` run can easily take **over an hour**.

## Optional: Sign the installer

To sign the installer you'll need a code-signing certificate (SPC).
See the [doc for more information](https://learn.microsoft.com/en-us/dotnet/framework/tools/signtool-exe).

```bash
export SIGNTOOL=`find /c/Program\ Files\ \(x86\)/Windows\ Kits/10/ -wholename "*${XPREFIX}/signtool.exe" | tail -1`
"${SIGNTOOL}" sign /n "Me" /f MySPC.pfx /tr "http://timestamp.globalsign.com/tsa/r6advanced1" /a /td SHA256 /v OpenModelica.exe
```

## Bug Reports

  - Submit bugs through the [OpenModelica GitHub issues](https://github.com/OpenModelica/OpenModelica/issues/new).
  - [Pull requests](../../pulls) are welcome ❤️
