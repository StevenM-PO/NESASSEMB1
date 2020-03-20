.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
bulletAge: .res 1
aReleased: .res 1

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

  LDX #$00
  STX bulletAge
vblankwait:
  BIT PPUSTATUS
  BPL vblankwait
  LDA #%10010000
  STA PPUCTRL
  LDA #%00111110
  STA PPUMASK

LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  JSR readNextInput
  BEQ a_noPress
  JSR bulletShoot
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

;bulletMovement
  LDX bulletAge
  CPX #$00
  BEQ vblankwait
  JSR moveBullet
  JMP vblankwait

;Sprite movement subroutines.
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

;bullet subroutines
bulletShoot:
  LDX bulletAge
  CPX #$00
  BEQ createBullet
  RTS
createBullet:
  LDX $0204
  STX $0210
  LDA $0207
  SEC
  SBC #$04
  STA $0213
  LDX #$09
  STX $0211
  LDX #$01
  STX $0212
  LDX bulletAge
  INX
  STX bulletAge
  RTS
moveBullet:
  LDA $0210
  SEC
  SBC #$05
  STA $0210
  ;LDX $0213
  ;INX
  ;STX $0213
  LDX bulletAge
  INX
  CPX #$20
  STX bulletAge
  BEQ clearBullet
  LDX #$05
EoSDetect:
  CPX $0210
  BEQ clearBullet
  DEX
  CPX #$0
  BNE EoSDetect
  RTS
clearBullet:
  LDX #$00
  STX $0210
  STX $0211
  STX $0212
  STX $0213
  STX bulletAge
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
