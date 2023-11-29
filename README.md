# OpenModelicaSetup

OpenModelica Windows installer based on [NSIS](https://nsis.sourceforge.io/Main_Page).

## Dependencies

  - [NSIS 3.0.4](https://nsis.sourceforge.io/Main_Page)
    - Copy `AccessControlW.dll` into your NSIS plugin directory, e.g. into
      `C:\Program Files (x86)\NSIS\Plugins\x86-unicode`.
  - [git](https://git-scm.com/)
  - [OMDev](https://gitlab.liu.se/OpenModelica/OMDevUCRT)
  - [SignTool](https://learn.microsoft.com/en-us/windows/win32/seccrypto/signtool),
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

Download the the HTML and PDF versions of OpenModelica User's Guide:

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
export REVISION_SHORT=`cd $OPENMODELICA_SOURCE_DIR; git describe --match "v*.*" --always --abbrev=0`
export PRODUCT_VERSION="${REVISION_SHORT:1}"
# make a valid VIProductVersion by stripping everything after "-"
BEGIN=${PRODUCT_VERSION/-*/}
PRODUCT_VERSION=${PRODUCT_VERSION::${#BEGIN}}
PRODUCT_VERSION=${PRODUCT_VERSION}.0

makensis //DPLATFORMVERSION="${PLATFORM}" \
         //DOMVERSION="${REVISION_SHORT}" \
         //DPRODUCTVERSION="${PRODUCT_VERSION}" \
         //DOPENMODELICASOURCEDIR="${OPENMODELICA_SOURCE_DIR}" \
         //DOPENMODELICAHOME="${OPENMODELICAHOME}" \
         //DMSYSTEM="${MSYSTEM}" \
         OpenModelicaSetup.nsi
```

> [!NOTE]
> `PRODUCT_VERSION` needs to be in `X.X.X.X` format.

## Sign the installer

To sign the installer you'll need a code-signing certificate (SPC).
See the [doc for more information](https://learn.microsoft.com/en-us/dotnet/framework/tools/signtool-exe).

```bash
export SIGNTOOL=`find /c/Program\ Files\ \(x86\)/Windows\ Kits/10/ -wholename "*${XPREFIX}/signtool.exe" | tail -1`
"${SIGNTOOL}" sign /n "Me" /f MySPC.pfx /tr "http://timestamp.globalsign.com/tsa/r6advanced1" /a /td SHA256 /v OpenModelica.exe
```

## Bug Reports

  - Submit bugs through the [OpenModelica GitHub issues](https://github.com/OpenModelica/OpenModelica/issues/new).
  - [Pull requests](../../pulls) are welcome ❤️
