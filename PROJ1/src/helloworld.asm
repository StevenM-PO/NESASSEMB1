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

forever:
  LDX PPUSTATUS
  LDX #$3F
  STX PPUADDR
  LDX #$00
  STX PPUADDR
  LDA #$11
  STA PPUDATA
  LDA #$1A
  STA PPUDATA
  LDA #$0A
  STA PPUDATA
  LDA #$10
  STA PPUDATA
  LDA #$70
  STA $0200
  LDA #$07
  STA $0201
  LDA #$00
  STA $0202
  LDA #$80
  STA $0203

vblankwait:
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000
  STA PPUCTRL
  LDA #%00111110
  STA PPUMASK
  jmp forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "graphics.chr"
