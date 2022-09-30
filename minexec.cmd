@echo off
setlocal EnableDelayedExpansion EnableExtensions

REM miniconda3 batchtool (minexec.cmd) v0.3
REM 
REM Author:   (c) 2022 Robert Smith <nightwintertooth@gmail.com>
REM License:  Distributed under the DBAD v1.1 open source license:
REM           https://dbad-license.org/
REM
REM About:
REM
REM     This tool allows easy control of miniconda3 environments for
REM     portabilization of HuggingFace experiment projects on Windows.
REM
REM     You can use this tool to ease workflow for locally run
REM     experiments, or experiments that use the HuggingFace
REM     inference API.
REM
REM Requirements:
REM
REM     miniconda3 installed from:
REM         https://docs.conda.io/en/latest/miniconda.html
REM
REM     Git for Windows installed from:
REM         https://gitforwindows.org/
REM
REM     A HuggingFace login and token that can be obtained
REM     from here:
REM        https://huggingface.co/settings/tokens/

set "CONDA_ENV_NAME=hokkiando"
set "CONDA_CUSTOM_PATH=E:\source\env\miniconda3"
set "FUNC="

:GETOPTS
  set "TRUE="
  IF /I "%1" == "-h" set TRUE=1
  IF /I "%1" == "--help" set TRUE=1
  IF defined TRUE (
    call :HEADER
    echo.
    call :USAGE
    exit /b 0
  )

  set "TRUE="
  IF /I "%1" == "-i" set TRUE=1
  IF /I "%1" == "--install" set TRUE=1
  IF defined TRUE (
    set "FUNC=!FUNC!;install"
    shift
    goto GETOPTS
  )

  set "TRUE="
  IF /I "%1" == "-u" set TRUE=1
  IF /I "%1" == "--update" set TRUE=1
  IF defined TRUE (
    set "FUNC=!FUNC!;update"
    shift
    goto GETOPTS
  )

  set "TRUE="
  IF /I "%1" == "-cp" set TRUE=1
  IF /I "%1" == "--conda-path" set TRUE=1
  IF defined TRUE (
    shift
    setx CONDA_CUSTOM_PATH "%~1"
    shift
    goto GETOPTS
  )

  set "TRUE="
  IF /I "%1" == "-ce" set TRUE=1
  IF /I "%1" == "--conda-env" set TRUE=1
  IF defined TRUE (
    shift
    setx CONDA_ENV_NAME "%1"
    shift
    goto GETOPTS
  )

  REM /// Easter egg:  keep for fun, remove for professionals.
  set "TRUE="
  IF /I "%1" == "-k" set TRUE=1
  IF /I "%1" == "--kokan" set TRUE=1
  IF defined TRUE (
    echo. mauw^? ¯^\^_^(ツ^)^_^/¯
    start https^:^/^/www^.youtube^.com^/watch^?v^=QH2^-TGUlwu4
    goto :EOF
  )
  REM /// End easter egg

  set "TRUE="
  IF /I "%1" == "-s" set TRUE=1
  IF /I "%1" == "--shell" set TRUE=1
  IF defined TRUE (
    shift
    set "FUNC=!FUNC!;shell"
    set SHELL_STRING=%~2
    shift
    goto GETOPTS
  )

  set "TRUE="
  IF /I "%1" == "-r" set TRUE=1
  IF /I "%1" == "--remove" set TRUE=1
  IF defined TRUE (
    set "FUNC=!FUNC!;remove"
    shift
    goto GETOPTS
  )

  IF /I "%1" == "" if not defined FUNC (
    echo E^: This script cannot be run without command arguments.
    call :HEADER
    echo.
    call :USAGE
    exit /b 1
  )

  IF /I "%1" NEQ "" (
    echo E^: Invalid command line option: %1
    call :HEADER
    echo.
    call :USAGE
    exit /b 1
  )

  call :MAIN
  GOTO :EOF

:HEADER
  echo. ------------- miniconda3 batchtool ^(minexec.cmd^) v0.3 -------------
  echo. Author:   ^(c^) 2022 Robert Smith ^<nightwintertooth^@gmail^.com^>
  echo. License:  Distributed under the DBAD v1.1 open source license:
  echo.           https^:^/^/dbad^-license^.org^/
  echo. -------------------------------------------------------------------
  exit /b

:USAGE
  echo. About:
  echo.     This tool allows easy control of miniconda3 environments for 
  echo.     portabilization of HuggingFace experiment projects on Windows.
  echo.
  echo.     You can use this tool to ease workflow for locally run
  echo.     experiments^, or experiments that use the HuggingFace
  echo.     inference API. 
  echo.
  echo. Usage:
  echo.   minexec.cmd ^[parameters^] ^[options^]..
  echo.
  echo. Parameters^:
  echo.     -h ^, --help
  echo.         Displays this help and exit
  echo.     -i ^, --install
  echo.         Install miniconda3 environment
  echo.     -u ^, --update
  echo.         Update miniconda3 environment
  echo.     -r ^, --remove
  echo.         Remove miniconda3 environment
  echo.     -s ^, --shell command_string
  echo.         Run command_string in environment
  echo.
  echo. Options:
  echo.     -cp ^, --conda-path path_string
  echo.         Specify custom miniconda3 installation path with path_string
  echo.     -ce ^, --conda-env value
  echo.         Specify custom conda environment name with value
  echo.
  exit /b

:VALIDATECONDA
  set paths=%ProgramData%\miniconda3
  set paths=%paths%;%USERPROFILE%\miniconda3
  set paths=%paths%;%ProgramData%\anaconda3
  set paths=%paths%;%USERPROFILE%\anaconda3

  if not "%CONDA_CUSTOM_PATH%"=="" (
    set paths=%CONDA_CUSTOM_PATH%;%paths%
  )

  for %%a in (%paths%) do ( 
    IF EXIST "%%a\Scripts\activate.bat" SET CONDA_PATH=%%a
  )

  if "%CONDA_PATH%"=="" (
    echo E^: miniconda3 not found^!  Install from^:  https^:^/^/docs^.conda^.io^/en^/latest^/miniconda^.html
    echo. 
    goto :EOF
  ) else (
    echo Using miniconda3^:  %CONDA_PATH%
  )
  exit /b

:INSTALL
  echo. ---- MiniExec Command: Install
  call :VALIDATECONDA
  call "%CONDA_PATH%\Scripts\activate.bat" "base"
  call conda update -n base -c defaults conda --yes
  call conda env create -n "%CONDA_ENV_NAME%" --file environment.yaml
  if "%ERRORLEVEL%" == "1" (
    echo E^: An envrionemnt with the %CONDA_ENV_NAME% prefix already exists^!
    echo.
    exit /b 1
  )
  call git config --global credential.helper store
  call conda deactivate
  exit /b

:UPDATE
  echo. ---- MiniExec Command: Update
  call :VALIDATECONDA
  call "%CONDA_PATH%\Scripts\activate.bat" "base"
  call conda env update -n %CONDA_ENV_NAME% --file environment.yaml --prune
  if "%ERRORLEVEL%" == "1" (
    echo E^: Updating the  %CONDA_ENV_NAME% prefix failed.^!
    echo.
    exit /b 1
  )
  call conda deactivate
  exit /b

:REMOVE
  echo. ---- MiniExec Command: Remove
  call :VALIDATECONDA
  if not exist "%CONDA_PATH%\envs\%CONDA_ENV_NAME%" (
    echo E^: The %CONDA_ENV_NAME% prefix does not exist^!
    echo.
    exit /b 1
  )
  call "%CONDA_PATH%\Scripts\activate.bat" "base"
  call conda env remove -n %CONDA_ENV_NAME%
  call conda deactivate
  exit /b

:SHELL
  echo. ---- MiniExec Command: Shell
  call :VALIDATECONDA
  call "%CONDA_PATH%\Scripts\activate.bat" "%CONDA_ENV_NAME%"
  call !SHELL_STRING!
  call conda deactivate
  exit /b

rem call "%CONDA_PATH%\Scripts\activate.bat" "%conda_env_name%"
rem python "%CD%"\scripts\relauncher.py

:MAIN
  set "TRUE="
  for %%a in (!FUNC!) do ( 
    if "%%a" == "install" (
      set TRUE=1
      call :INSTALL
    )
    if "%%a" == "update" (
      set TRUE=1
      call :UPDATE
    )
    if "%%a" == "shell" (
      set TRUE=1
      call :SHELL
    )
    if "%%a" == "remove" (
      set TRUE=1
      call :REMOVE
    )
  )
  if not defined TRUE (
    echo E^: No action specified.
    call :HEADER
    echo.
    call :USAGE
    exit /b 1
  )
  exit /b

:PROMPT

exit /b

:EOF
  echo. Script exiting
  endlocal
