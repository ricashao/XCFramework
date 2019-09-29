#bin/sh
set path=`pwd`
for d in * ; do
	if [ -d "$d" ] ; then
		TexturePacker --sheet ../GenAltas/$d/${d}_tp{n}.png --data \
		../GenAltas/$d/${d}_tp{n}_cfg.txt \
		--texture-format png \
		--trim-mode None \
		--disable-rotation \
		--format unity \
		--multipack  \
		--max-size 1024  \
		--size-constraints POT  $d
    fi
done

java -jar imagesetcheck.jar -path `pwd`/../GenAltas