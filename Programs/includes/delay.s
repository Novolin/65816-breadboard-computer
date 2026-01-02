; Simple delay sub, mostly for boot.
.IFNDEF delay
delay:          ; Delays for ~1 ms per # in A when called
 PHX                                    ; Save X in the stack
 TAX                                    ; Use X for our loop, it's a bit easier.
 LDA            #$C8                    ; A will keep our actual looper, 200 loops = ~1000 cycles @ 1MHz
@loop:                                  ; Loop for actually doing things:
 DEC            A                       ; Decrement A
 BNE            @loop                   ; Go until we're at 0
 LDA            #$C8                    ; Reset the A counter
 DEX                                    ; Decrement our X counter
 BNE            @loop                   ; Go until it's empty
 PLX                                    ; Return X to where it started
 RTS                                    ; Go back to where we came from
.ENDIF