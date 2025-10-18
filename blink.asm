; DEFINITIONS
    #include "p10f202.inc"

; CONFIG
    __CONFIG _WDT_OFF & _CP_OFF & _MCLRE_OFF
    org 0x0000

INIT:
    ; by default, T0CKI pin is used as timer 0 clock input for counting
    ; disabling it enables using GP2 pin as I/O GPIO
    movlw ~(1 << T0CS)
    option
    ; set GP2 as output
    movlw ~(1 << GP2)
    tris GPIO

MAIN_LOOP:
    bsf GPIO, GP2   ; turn led off
    call DELAY_L3   ; 2
    bcf GPIO, GP2   ; turn led off
    call DELAY_L3   ; 2
    goto MAIN_LOOP  ; loop

var_delay_outer  EQU 10h
var_delay_middle EQU 11h
var_delay_inner  EQU 12h

; 1s +/- 2us @1MIPS
delay_outer_start  EQU 0x1E ; 30 dec
delay_middle_start EQU 0x37 ; 55 dec
delay_inner_start  EQU 0xC9 ; 201 dec

DELAY_L3:
    movlw delay_outer_start     ; 1
    movwf var_delay_outer       ; 1

DELAY_OUTER:
    movlw delay_middle_start    ; 1
    movwf var_delay_middle      ; 1

DELAY_MIDDLE:
    movlw delay_inner_start     ; 1
    movwf var_delay_inner       ; 1

DELAY_INNER:
    decfsz var_delay_inner, W   ; delay_outer_start*delay_middle_start*(delay_inner_start * 1 + 2)
    goto DELAY_INNER            ; delay_outer_start*delay_middle_start*((delay_inner_start-1) * 2)

    decfsz var_delay_middle, W  ; delay_outer_start*(delay_middle_start * 1 + 2)
    goto DELAY_MIDDLE           ; delay_outer_start*((delay_middle_start-1) * 2)

    decfsz var_delay_outer, W   ; delay_outer_start * 1 + 2
    retlw 00h                   ; 2
    goto DELAY_OUTER            ; (delay_outer_start-1) * 2

    end
