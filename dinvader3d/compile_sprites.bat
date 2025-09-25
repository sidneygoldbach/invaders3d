@echo off
REM Script para compilar sprites.rc em sprites.res
REM Execute este arquivo no Windows com Delphi instalado

echo Compilando sprites.rc...
brcc32.exe sprites.rc

if exist sprites.res (
    echo sprites.res criado com sucesso!
) else (
    echo ERRO: Falha ao criar sprites.res
    echo Verifique se o BRCC32.EXE está no PATH
)

pause