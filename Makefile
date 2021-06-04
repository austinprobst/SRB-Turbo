.POSIX:
.SUFFIXES: .asm

name = srb-turbo
src  = src
obj  = src/main.o src/core.o

all: clean $(name).gb

clean:
	@rm -f $(obj) $(name).gb $(name).sym

gfx:
	@find . -iname "*.png" -exec sh -c 'rgbgfx -o $${1%.png}.2bpp $$1' _ {} \;

.asm.o:
	@rgbasm -i $(src)/ -o $@ $<

$(name).gb: gfx $(obj)
	@rgblink -n $(name).sym -o $@ $(obj)
	@rgbfix -jv -i BEAT -k XX -l 0x33 -m 0x01 -p 0 -r 0 -t SRBTURBO $@