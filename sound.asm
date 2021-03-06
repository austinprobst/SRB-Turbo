section "sound wram", wram0
wCh0Ptr: ds 2
wCh0Pitch: ds 1
wCh0Length: ds 1
wCh0Octave: ds 1

wCh1Ptr: ds 2
wCh1Pitch: ds 1
wCh1Length: ds 1
wCh1Octave: ds 1

section "sound", rom0
C_: macro
	db 0
	db \1
endm

C#: macro
	db 1
	db \1
endm

D_: macro
	db 2
	db \1
endm

D#: macro
	db 3
	db \1
endm

E_: macro
	db 4
	db \1
endm

F_: macro
	db 5
	db \1
endm

F#: macro
	db 6
	db \1
endm

G_: macro
	db 7
	db \1
endm

G#: macro
	db 8
	db \1
endm

A_: macro
	db 9
	db \1
endm

A#: macro
	db 10
	db \1
endm

B_: macro
	db 11
	db \1
endm

__: macro
	db 12
	db \1
endm

octave: macro
	db 13
	db \1
endm

InitSound::
	cp 2
	ld hl, FireAndFlames	
	ld de, FireAndFlames
	jr z, .gotSong
	cp 1
	ld hl, RussianFolk
	ld de, RussianFolk
	jr z, .gotSong
	ld hl, CanonChannel1
	ld de, CanonChannel1
.gotSong
	push de
	push hl
	ld a, %10000000
	ld [rNR52], a
	;ld a, %10000000
	ld [rNR11], a ; duty
	ld [rNR21], a ; duty
	ld a, %11111000
	ld [rNR12], a ; volume
	ld [rNR22], a ; volume
	ld a, %11111111
	ld [rNR51], a ; 
	ld a, $77
	ld [rNR50], a
	;ld a, $8
	;ld [rNR10], a
	ld a, $00
	ld [rNR14], a ; counter mode
	ld [rNR24], a
	;ld [rNR44], a
	pop hl
	call Ch0NextNote
	pop hl
	call Ch1NextNote
	ret

Ch0NextNote:
	ld a, [hli]
	cp 13
	jr nz, .notOctave
	ld a, [hli]
	ld [wCh0Octave], a
	ld a, [hli]
.notOctave
	ld [wCh0Pitch], a
	cp $FF
	ret z
	ld c, a
	ld a, [hli]
	ld [wCh0Length], a
	ld a, l
	ld [wCh0Ptr], a
	ld a, h
	ld [wCh0Ptr + 1], a
	ld a, [wCh0Octave]
	ld b, a
	ld a, c
	cp 12
	jr z, .rest
	call CalculateFrequency
	ld a, [rNR51]
	or %00010001
	ld [rNR51], a
	ld a, e
	ld [rNR13], a
	ld a, d
	res 6, a
	ld [rNR14], a
	ret
.rest
	ld a, [rNR51]
	and %11101110
	ld [rNR51], a
	xor a
	ld [rNR13], a
	ld [rNR14], a
	ret

Ch0UpdateSound:
	ld a, [wCh0Pitch]
	cp $FF
	ret z
	ld a, [wCh0Length]
	and a
	jr z, .nextNote
	dec a
	ld [wCh0Length], a
	ret
.nextNote
	ld a, [wCh0Ptr]
	ld l, a
	ld a, [wCh0Ptr + 1]
	ld h, a
	call Ch0NextNote
	ret

Ch1NextNote:
	ld a, [hli]
	cp 13
	jr nz, .notOctave
	ld a, [hli]
	ld [wCh1Octave], a
	ld a, [hli]
.notOctave
	ld [wCh1Pitch], a
	cp $FF
	ret z
	ld c, a
	ld a, [hli]
	ld [wCh1Length], a
	ld a, l
	ld [wCh1Ptr], a
	ld a, h
	ld [wCh1Ptr + 1], a
	ld a, [wCh1Octave]
	ld b, a
	ld a, c
	cp 12
	jr z, .rest
	call CalculateFrequency
	ld a, [rNR51]
	or %00100010
	ld [rNR51], a
	ld a, e
	ld [rNR23], a
	ld a, d
	res 6, a
	ld [rNR24], a
	ret
.rest
	ld a, [rNR51]
	and %11011101
	ld [rNR51], a
	xor a
	ld [rNR23], a
	ld [rNR24], a
	ret

Ch1UpdateSound:
	ld a, [wCh1Pitch]
	cp $FF
	ret z
	ld a, [wCh1Length]
	and a
	jr z, .nextNote
	dec a
	ld [wCh1Length], a
	ret
.nextNote
	ld a, [wCh1Ptr]
	ld l, a
	ld a, [wCh1Ptr + 1]
	ld h, a
	call Ch1NextNote
	ret

CalculateFrequency:
; return the frequency for note a, octave b in de
	ld h, 0
	ld l, a
	add hl, hl
	ld d, h
	ld e, l
	ld hl, Pitches
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, b
.loop
	cp 7
	jr z, .done
	sra d
	rr e
	inc a
	jr .loop
.done
	ret

Pitches:
	dw $F82C ; C_
	dw $F89D ; C#
	dw $F907 ; D_
	dw $F96B ; D#
	dw $F9CA ; E_
	dw $FA23 ; F_
	dw $FA77 ; F#
	dw $FAC7 ; G_
	dw $FB12 ; G#
	dw $FB58 ; A_
	dw $FB9B ; A#
	dw $FBDA ; B_


FireAndFlames:
	octave 5
	__ $78
	D_ 10
	E_ 10
	F_ 10
	D_ 10
	E_ 10
	F_ 10
	G_ 10
	F_ 10
	A_ 10
	F_ 10
	G_ 10
	E_ 10
	F_ 10
	D_ 10
	E_ 10
	C_ 10
	D_ 10
	E_ 10
	F_ 10
	D_ 10
	E_ 10
	F_ 10
	G_ 10
	F_ 10
	A_ 10
	F_ 10
	G_ 10
	E_ 10
	F_ 10
	D_ 10
	E_ 10
	C_ 10
	D_ 10
	E_ 10
	F_ 10
	D_ 10
	E_ 10
	F_ 10
	G_ 10
	F_ 10
	A_ 10
	F_ 10
	G_ 10
	E_ 10
	F_ 10
	D_ 10
	E_ 10
	C_ 10
	D_ 10
	E_ 10
	F_ 10
	D_ 10
	E_ 10
	F_ 10
	G_ 10
	E_ 10
	G_ 5
	F_ 5
	E_ 5
	D_ 5
	F_ 5
	E_ 5
	D_ 5
	C_ 5
	E_ 5
	D_ 5
	C_ 3
	__ 2
	C_ 5
	D_ 5
	C_ 5
	octave 6
	A# 5
	A_ 5
	octave 5

	F_ 20
	D_ 10
	F_ 20
	D_ 10
	F_ 10
	D_ 10
	F_ 20
	D_ 10
	F_ 20
	D_ 10
	F_ 10
	D_ 10
	A_ 20
	D_ 10
	A_ 20
	D_ 10
	A_ 10
	D_ 10
	A_ 20
	D_ 10
	A_ 20
	D_ 10
	A_ 10
	D_ 10
	G_ 20
	D_ 10
	G_ 20
	D_ 10
	G_ 10
	D_ 10
	G_ 20
	D_ 10
	G_ 20
	D_ 10
	G_ 10
	D_ 10
	F_ 20
	D_ 10
	F_ 20
	D_ 10
	F_ 10
	D_ 10
	C_ 5
	D_ 5
	F_ 5
	E_ 5
	C_ 5
	D_ 5
	E_ 5
	G_ 5
	D_ 5
	E_ 5
	F_ 5
	G_ 5
	A_ 5
	G_ 5
	__ 5
	octave 5
	A_ 9
	__ 1
	A_ 9
	__ 1
	A_ 10
	__ 10
	G_ 10
	F_ 10
	G_ 10
	A_ 20
	__ 20
	D_ 10
	F_ 10
	G_ 20
	A_ 20
	G_ 10
	F_ 20
	D_ 40
	D_ 20
	G_ 20
	G_ 20
	F_ 20
	G_ 20
	A_ 10
	G_ 20
	__ 20
	F_ 20
	G_ 20
	A_ 10
	G_ 20
	F_ 20
	D_ 10
	__ 40
	A_ 10
	A_ 10
	A_ 10
	__ 10
	G_ 10
	G_ 10
	__ 10
	F_ 10
	A_ 20
	__ 10
	D_ 10
	F_ 10
	G_ 10
	__ 10
	A_ 10
	__ 10
	G_ 10
	F_ 10
	D_ 30
	__ 20
	G_ 10
	__ 10
	G_ 10
	__ 10
	F_ 10
	__ 10
	G_ 10
	__ 10
	A_ 10
	__ 10
	G_ 10
	F_ 10
	D_ 40
	__ 1
	db $FF, $FF


CanonChannel2:
	__ $78
rept 9
	__ 80
endr
	octave 5
	C_ 80
	octave 6
	G_ 80
	A_ 80
	E_ 80
	F_ 80
	C_ 80
	F_ 80
	G_ 80
	octave 5
	C_ 80
	octave 6
	G_ 80
	A_ 80
	E_ 80
	F_ 80
	C_ 80
	F_ 80
	G_ 80
	octave 5
	C_ 80
	octave 6
	G_ 80
	A_ 80
	E_ 80
	F_ 80
	C_ 80
	F_ 80
	G_ 80
	octave 5
	C_ 80
	octave 6
	G_ 80
	A_ 80
	E_ 80
	F_ 80
	C_ 80
	F_ 80
	G_ 80
	__ 1
	db $FF, $FF
	
CanonChannel1:
	octave 5
	__ $78
	C_ 80
	octave 6
	G_ 80
	A_ 80
	E_ 80
	F_ 80
	C_ 80
	F_ 80
	G_ 80
	octave 5
	C_ 80
	octave 6
	G_ 80
	A_ 80
	E_ 80
	F_ 80
	C_ 80
	F_ 80
	G_ 80 ; end of main melody
	octave 5
	C_ 40
	E_ 40
	G_ 40
	F_ 40
	E_ 40
	C_ 40
	E_ 40
	D_ 40
	C_ 40
	octave 6
	A_ 40
	octave 5
	C_ 40
	G_ 40
	F_ 40
	A_ 40
	G_ 40
	F_ 40
	E_ 40
	C_ 40
	D_ 40
	B_ 40
	octave 4
	C_ 40
	E_ 40
	octave 5
	G_ 40
	E_ 40
	A_ 38
	__ 2
	A_ 40
	G_ 38
	__ 2
	G_ 40
	A_ 38
	__ 2
	A_ 40
	B_ 38
	__ 2
	B_ 40 ; end of second melody
	octave 5
	C_ 20
	E_ 20
	G_ 20
	octave 4
	C_ 20
	octave 6
	G_ 20
	B_ 20
	octave 5
	D_ 20
	G_ 20
	octave 6
	A_ 20
	octave 5
	C_ 20
	E_ 20
	A_ 20
	octave 6
	E_ 20
	G_ 20
	B_ 20
	octave 5
	E_ 20
	octave 6
	F_ 20
	A_ 20
	octave 5
	C_ 20
	F_ 20
	octave 6
	C_ 20
	E_ 20
	G_ 20
	octave 5
	C_ 20
	octave 6
	F_ 20
	A_ 20
	octave 5
	C_ 20
	F_ 20
	octave 6
	G_ 20
	B_ 20
	octave 5
	D_ 20
	G_ 20
	C_ 20
	E_ 20
	G_ 20
	octave 4
	C_ 20
	octave 6
	G_ 20
	B_ 20
	octave 5
	D_ 20
	G_ 20
	octave 6
	A_ 20
	octave 5
	C_ 20
	E_ 20
	A_ 20
	octave 6
	E_ 20
	G_ 20
	B_ 20
	octave 5
	E_ 20
	octave 6
	F_ 20
	A_ 20
	octave 5
	C_ 20
	F_ 20
	octave 6
	C_ 20
	E_ 20
	G_ 20
	octave 5
	C_ 20
	octave 6
	F_ 20
	A_ 20
	octave 5
	C_ 20
	F_ 20
	octave 6
	G_ 20
	B_ 20
	octave 5
	D_ 20
	G_ 20 ; end of 3rd melody
	octave 5
	G_ 20
	E_ 10
	F_ 10
	G_ 10
	__ 10
	octave 6
	G_ 10
	A_ 10
	B_ 10
	octave 5
	C_ 10
	D_ 10
	E_ 10
	F_ 10
	__ 10
	F_ 20
	E_ 10
	__ 10
	C_ 10
	D_ 10
	E_ 10
	__ 10
	octave 6
	E_ 10
	F_ 10
	G_ 10
	A_ 10
	G_ 10
	F_ 10
	G_ 10
	octave 5
	C_ 10
	octave 6
	B_ 10
	octave 5
	C_ 10
	octave 6
	A_ 10
	octave 5
	__ 10
	C_ 10
	octave 6
	B_ 10
	octave 5
	C_ 10
	__ 10
	octave 6
	B_ 10
	octave 5
	C_ 10
	octave 6
	A_ 10
	B_ 10
	octave 5
	C_ 10
	D_ 10
	E_ 10
	F_ 10
	G_ 10
	A_ 10
	F_ 10
	G_ 10
	A_ 10
	B_ 10
	octave 4
	C_ 10
	octave 5
	A_ 10
	B_ 10
	octave 4
	C_ 10
	D_ 10
	C_ 10
	D_ 10
	E_ 10
	F_ 10
	__ 10
	octave 5
	G_ 10
	__ 10  
	G_ 20
	E_ 10
	F_ 10
	G_ 10
	__ 10
	octave 6
	G_ 10
	A_ 10
	B_ 10
	octave 5
	C_ 10
	D_ 10
	E_ 10
	F_ 10
	__ 10
	F_ 20
	E_ 10
	__ 10
	C_ 10
	D_ 10
	E_ 10
	__ 10
	octave 6
	E_ 10
	F_ 10
	G_ 10
	A_ 10
	G_ 10
	F_ 10
	G_ 10
	octave 5
	C_ 10
	octave 6
	B_ 10
	octave 5
	C_ 10
	octave 6
	A_ 10
	octave 5
	__ 10
	C_ 10
	octave 6
	B_ 10
	octave 5
	C_ 10
	__ 10
	octave 6
	B_ 10
	octave 5
	C_ 10
	octave 6
	A_ 10
	B_ 10
	octave 5
	C_ 10
	D_ 10
	E_ 10
	F_ 10
	G_ 10
	A_ 10
	F_ 10
	G_ 10
	A_ 10
	B_ 10
	octave 4
	C_ 10
	octave 5
	A_ 10
	B_ 10
	octave 4
	C_ 10
	D_ 10
	C_ 10
	D_ 10
	E_ 10
	F_ 10
	__ 10
	octave 5
	G_ 20
	octave 5
	C_ 80
	octave 6
	G_ 80
	A_ 80
	E_ 80
	F_ 80
	C_ 80
	F_ 80
	G_ 80
	octave 5
	C_ 80
	__ 50
	db $FF, $FF

RussianFolk:
	__ $78
	octave 5
	D_ 12
	E_ 12
	F_ 12
	G_ 12
	A_ 12
	octave 4
	__ 12
	D_ 12
	__ 12
	octave 5
	A# 12
	octave 4
	C_ 12
	D_ 12
	octave 5
	A# 12
	A_ 12
	__ 12
	F_ 12
	__ 12
	G_ 10
	__ 1
	G_ 10
	__ 1
	A# 10
	__ 1
	G_ 10
	__ 1
	F_ 10
	__ 1
	F_ 10
	__ 1
	A_ 10
	__ 1
	F_ 10
	__ 1
	E_ 10
	__ 1
	E_ 10
	__ 1
	F_ 10
	__ 1
	E_ 10
	__ 1
	D_ 12
	E_ 12
	F_ 12
	G_ 12
	A_ 12
	__ 12
	octave 4
	D_ 12
	__ 12
	octave 5
	A# 12
	octave 4
	C_ 12
	D_ 12
	octave 5
	A# 12
	A_ 12
	__ 12
	F_ 12
	__ 12
	G_ 10
	__ 1
	G_ 10
	__ 1
	A# 10
	__ 1
	G_ 10
	__ 1
	F_ 10
	__ 1
	F_ 10
	__ 1
	A_ 10
	__ 1
	F_ 10
	__ 1
	E_ 10
	__ 1
	E_ 10
	__ 1
	F_ 10
	__ 1
	E_ 10
	__ 1
	D_ 10
	__ 30
	octave 4
	D_ 16
	__ 1
	C_ 16
	__ 1
	octave 5
	A# 16
	__ 1
	A_ 16
	__ 1
	octave 4
	D_ 16
	__ 1
	C_ 16
	__ 1
	octave 5
	A# 16
	__ 1
	A_ 16
	__ 1
	octave 4
	D_ 8
	__ 1
	C_ 10
	__ 1
	octave 5
	A# 8
	__ 1
	A_ 8
	__ 1
	octave 4
	D_ 8
	__ 1
	C_ 10
	__ 1
	octave 5
	A# 8
	__ 1
	A_ 8
	__ 1
	octave 4
	D_ 8
	__ 1
	C_ 8
	__ 1
	octave 5
	A# 8
	__ 1
	A_ 8
	__ 1
	octave 4
	D_ 8
	__ 1
	C_ 8
	__ 1
	octave 5
	A# 8
	__ 1
	A_ 8
	__ 1
	A# 8
	__ 1
	A_ 8
	__ 1
	G_ 8
	__ 1
	A_ 8
	__ 1
	A# 8
	__ 1
	G_ 8
	__ 1
	A_ 8
	__ 1
	F_ 8
	__ 1
	G_ 16
	__ 16
	E_ 16
	__ 1
	F_ 16
	__ 1
	E_ 16
	__ 8
	D_ 32
	__ 20
	db $FF, $FF

One:
	octave 5
	__ $78
	B_ 20
	octave 4
	F# 20
	octave 5
	B_ 20
	octave 4
	D_ 50
	__ 10
	D_ 40

	octave 6
	G_ 20
	octave 4
	F# 20
	octave 6
	G_ 20
	octave 4
	D_ 50
	__ 10
	D_ 40

	octave 5
	B_ 20
	octave 4
	F# 20
	octave 5
	B_ 20
	octave 4
	D_ 50
	__ 10
	D_ 40

	octave 6
	G_ 20
	octave 4
	F# 20
	octave 6
	G_ 20
	octave 4
	D_ 40
	G_ 60

	octave 5
	B_ 20
	octave 4
	F# 20
	octave 5
	B_ 20
	octave 4
	D_ 50
	__ 10
	D_ 40

	octave 6
	A_ 20
	octave 4
	F# 20
	octave 6
	A_ 20
	octave 4
	D_ 50
	__ 10
	D_ 40

	octave 6
	G_ 20
	octave 4
	F# 20
	octave 6
	G_ 20
	octave 4
	D_ 50
	__ 10
	D_ 40

	octave 6
	E_ 20
	octave 5
	B_ 20
	octave 6
	F# 20
	octave 5
	B_ 20

	octave 5
	E_ 10
	octave 4
	F# 10
	octave 3
	A_ 20
	B_ 10
	C# 10
	B_ 20
	__ 20
	db $FF, $FF

ThousandYears:
	octave 4
	D_ 60
	__ 20
	D_ 60
	__ 20
	D_ 60
	__ 20
	C_ 60
	__ 20
	D_ 60
	__ 20
	D_ 60
	__ 20
	D_ 60
	__ 20
	C_ 60
	__ 20
	D# 60
	__ 20
	D# 60
	__ 20
	D# 60
	__ 20
	octave 5
	A# 60
	__ 20
	octave 4
	D_ 60
	__ 20
	D_ 60
	__ 20
	C_ 60
	__ 20
	octave 5
	A# 20
	A_ 20
	F_ 20
	__ 20
	A# 60
	__ 20
	A# 60
	__ 20
	A# 60
	__ 20
	octave 4
	D_ 20
	C_ 60
	octave 5
	A# 20
	__ 5
	A# 60
	__ 20
	A# 60
	__ 20
	A# 60
	__ 1
	db $FF, $FF



	






















