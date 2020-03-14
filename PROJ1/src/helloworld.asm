.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  RTI
.endproc

.import reset_handler

.export main
.proc main
  LDX PPUSTATUS
  LDX #$3F
  STX PPUADDR
  LDX #$00
  STX PPUADDR
  LDX #$00
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$10
  BNE load_palettes
  LDX #$00
load_spritePalettes:
  LDA palettes,x
  STA PPUDATA
  INX
  CPX #$10
  BNE load_spritePalettes
  LDX #$00
load_sprites:
  LDA sprites,X
  STA $0200,X
  INX
  CPX #$10
  BNE load_sprites
vblankwait:
  BIT PPUSTATUS
  BPL vblankwait
  LDA #%10010000
  STA PPUCTRL
  LDA #%00111110
  STA PPUMASK

forever:
LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  JSR readNextInput
  BEQ a_noPress
a_noPress:
  JSR readNextInput
  BEQ b_noPress
b_noPress:
  JSR readNextInput
  BEQ sel_noPress
sel_noPress:
  JSR readNextInput
  BEQ strt_noPress
strt_noPress:
  JSR readNextInput
  BEQ up_noPress
  LDX #$00
  LDY #$04
up_press:
  JSR negMov
up_noPress:
  JSR readNextInput
  BEQ dwn_noPress
  LDX #$00
  LDY #$04
dwn_press:
  JSR posMov
dwn_noPress:
  JSR readNextInput
  BEQ lft_noPress
  LDX #$03
  LDY #$04
lft_press:
  JSR negMov
lft_noPress:
  JSR readNextInput
  BEQ rgt_noPress
  LDX #$03
  LDY #$04
rgt_press:
  JSR posMov
rgt_noPress:

endcontroller:
  JMP vblankwait

;Sprite movement subroutines
readNextInput:
  LDA $4016
  AND #%00000001
  RTS
posMov:
  LDA $0200,X
  CLC
  ADC #$01
  STA $0200,X
  JSR countY4
  BNE posMov
  RTS
negMov:
  LDA $0200,X
  SEC
  SBC #$01
  STA $0200,X
  JSR countY4
  BNE negMov
  RTS
countY4:
  CLC
  TXA
  ADC #$04
  TAX
  DEY
  CPY #$00
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "graphics.chr"

.segment "RODATA"
palettes:
.byte $11, $19, $09, $0f
.byte $23, $01, $05, $35
.byte $23, $01, $05, $35
.byte $23, $01, $05, $35
sprites:
.byte $60, $05, $01, $80
.byte $60, $06, $01, $88
.byte $68, $07, $02, $80
.byte $68, $08, $03, $88
