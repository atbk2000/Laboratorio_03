        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(2)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB

SYSCTL_RCGCGPIO_R       EQU     0x400FE608 
SYSCTL_PRGPIO_R		EQU     0x400FEA08 
PORTN_BIT               EQU     1000000000000b ; bit 12 = Port N
PORTF_BIT               EQU     100000b ;bit 5 = PORT F

GPIO_PORTN_DATA_R    	EQU     0x40064000
GPIO_PORTN_DIR_R     	EQU     0x40064400
GPIO_PORTN_DEN_R     	EQU     0x4006451C
GPIO_PORTF_DATA_R    	EQU     0x4005d000
GPIO_PORTF_DIR_R     	EQU     0x4005d400
GPIO_PORTF_DEN_R     	EQU     0x4005d51C

BIT_0_OUT               EQU     00000001b
BIT_1_OUT               EQU     00000010b
BIT_4_OUT               EQU     00010000b


clock_Init ;sub-rotina para habilitar clock das portas N e F
      
       MOV R2, #PORTN_BIT
       LDR R0, =SYSCTL_RCGCGPIO_R
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita port N
       STR R1, [R0] ; escrita do novo estado

       LDR R0, =SYSCTL_PRGPIO_R
waitN
       LDR R2, [R0] ; leitura do estado atual
       TEQ R1, R2 ; clock do port N habilitado?
       BNE waitN ; caso negativo, aguarda (NE = not equal)

       MOV R2, #PORTF_BIT
       LDR R0, =SYSCTL_RCGCGPIO_R
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita port F
       STR R1, [R0] ; escrita do novo estado

       LDR R0, =SYSCTL_PRGPIO_R
waitF 
       LDR R2, [R0] ; leitura do estado atual
       TEQ R1, R2 ; clock do port F habilitado?
       BNE waitF ; caso negativo, aguarda (NE = not equal) 

       BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IO_Init ;sub-rotina para configurar portas como entrada ou saída
       MOV R2, #BIT_0_OUT
       
       LDR R0, =GPIO_PORTN_DIR_R ;porta N
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; bit de saída (terminal 0)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_1_OUT
       
       LDR R0, =GPIO_PORTN_DIR_R ;porta N
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; bit de saída (terminal 1)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_0_OUT
       
       LDR R0, =GPIO_PORTF_DIR_R ;porta F
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; bit de saída (terminal 0)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_4_OUT
       
       LDR R0, =GPIO_PORTF_DIR_R ;porta F
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; bit de saída (terminal 4)
       STR R1, [R0] ; escrita do novo estado

       BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     
      
digital_Enable ;sub-rotina para ativar funções digitais
       MOV R2, #BIT_0_OUT

       LDR R0, =GPIO_PORTN_DEN_R
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita função digital (terminal 0)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_1_OUT

       LDR R0, =GPIO_PORTN_DEN_R
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita função digital (terminal 1)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_0_OUT

       LDR R0, =GPIO_PORTF_DEN_R
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita função digital (terminal 0)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_4_OUT

       LDR R0, =GPIO_PORTF_DEN_R
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita função digital (terminal 4)
       STR R1, [R0] ; escrita do novo estado

       BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

delay
        PUSH {R3}
        MOVT R3, #0x002F ; constante de atraso 
repeat   
        CBZ R3, theend ; 1 clock
        SUB R3, R3, #1 ; 1 clock
        B repeat ; 3 clocks
theend
        POP {R3}
        BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LED1change 
        ;LED 1 troca de estado
        PUSH {R1}
        LSL R1, R1, #1 ;bit 1 da porta N segue estado do bit 0 do contador
        STR R1, [R0, #0x8] ;(afeta apenas bit 1)
        POP {R1}
        
        BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LED2change
        ;LED 2 troca de estado
        PUSH {R1}
        LSR R1, R1, #1 ;bit 0 da porta N segue o estado do bit 1 do contador
        STR R1, [R0, #0x4] ;(afeta apenas bit 0)
        POP {R1}
        
        BX LR        
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LED3change
        ;LED 3 troca de estado
        PUSH {R1}
        LSL R1, R1, #2 ;bit 4 da porta F segue o estado do bit 2 do contador
        STR R1, [R2, #0x40] ;(afeta apenas bit 4)
        POP {R1}
        
        BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LED4change
        ;LED 4 troca de estado
        PUSH {R1}
        LSR R1, R1, #3 ;bit 0 da porta F segue o estado do bit 3 do contador
        STR R1, [R2, #0x4] ;(afeta apenas bit 0)
        POP {R1}
        
        BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;       
        

__iar_program_start

        
main   
        BL clock_Init
        BL IO_Init
        BL digital_Enable
        
 	LDR R0, = GPIO_PORTN_DATA_R
        LDR R2, = GPIO_PORTF_DATA_R
        
        MOV R1, #0 ;faz os LEDS começarem apagados e é utilizado como contador
        STR R1, [R0, #0x3FC] 
        STR R1, [R2, #0x3FC]
        
loop    
        CMP R1, #16
        BEQ again

        BL LED1change
        BL LED2change
        BL LED3change
        BL LED4change
        BL delay
        
        ADD R1, R1, #1
        B loop
        
again
        MOV R1, #0
        B loop
        ;programm ends here


        ;; Forward declaration of sections.
        SECTION CSTACK:DATA:NOROOT(3)
        SECTION .intvec:CODE:NOROOT(2)
        
        DATA

__vector_table
        DCD     sfe(CSTACK)
        DCD     __iar_program_start

        DCD     NMI_Handler
        DCD     HardFault_Handler
        DCD     MemManage_Handler
        DCD     BusFault_Handler
        DCD     UsageFault_Handler
        DCD     0
        DCD     0
        DCD     0
        DCD     0
        DCD     SVC_Handler
        DCD     DebugMon_Handler
        DCD     0
        DCD     PendSV_Handler
        DCD     SysTick_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Default interrupt handlers.
;;

        PUBWEAK NMI_Handler
        PUBWEAK HardFault_Handler
        PUBWEAK MemManage_Handler
        PUBWEAK BusFault_Handler
        PUBWEAK UsageFault_Handler
        PUBWEAK SVC_Handler
        PUBWEAK DebugMon_Handler
        PUBWEAK PendSV_Handler
        PUBWEAK SysTick_Handler

        SECTION .text:CODE:REORDER:NOROOT(1)
        THUMB

NMI_Handler
HardFault_Handler
MemManage_Handler
BusFault_Handler
UsageFault_Handler
SVC_Handler
DebugMon_Handler
PendSV_Handler
SysTick_Handler
Default_Handler
__default_handler
        CALL_GRAPH_ROOT __default_handler, "interrupt"
        NOCALL __default_handler
        B __default_handler

        END