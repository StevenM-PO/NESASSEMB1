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
up_press:
  LDA $0200,X
  SEC
  SBC #$02
  STA $0200,X
  CPX #$0C
  CLC
  TXA
  ADC #$04
  TAX
  BNE up_press
up_noPress:
  JSR readNextInput
  BEQ dwn_noPress
  LDX #$00
dwn_press:
  LDA $0200,X
  CLC
  ADC #$02
  STA $0200,X
  CPX #$0C
  CLC
  TXA
  ADC #$04
  TAX
  BNE dwn_press
dwn_noPress:
  JSR readNextInput
  BEQ lft_noPress
lft_press:
  LDA $0203,X
  SEC
  SBC #$02
  STA $0203,X
  CPX #$0F
  CLC
  TXA
  ADC #$04
  TAX
  BNE lft_press
lft_noPress:
  JSR readNextInput
  BEQ rgt_noPress
  LDX #$00
rgt_press:
  LDA $0203,X
  CLC
  ADC #$02
  STA $0203,X
  CPX #$0F
  CLC
  TXA
  ADC #$04
  TAX
  BNE rgt_press
rgt_noPress:

endcontroller:
  JMP vblankwait

readNextInput:
  LDA $4016
  AND #%00000001
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
