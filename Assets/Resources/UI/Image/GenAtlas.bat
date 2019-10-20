@echo off

for /d %%d in (*.*) do (
	echo %%d
	TexturePacker --sheet %cd%\..\GenAltas\%%d\%%d_tp{n}.png ^
	--data %cd%\..\GenAltas\%%d\%%d_tp{n}_cfg.txt ^
	--texture-format png ^
	--disable-rotation ^
	--format unity ^
	--multipack  ^
	--max-size 1024 ^
	--trim-mode None ^
	--size-constraints POT  %%d
)
@:java -cp imagesetcheck.jar ToolMain -path %cd%\..\GenAltas
pause:

pause: