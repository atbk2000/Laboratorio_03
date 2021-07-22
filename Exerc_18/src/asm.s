        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(2)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB

SYSCTL_RCGCGPIO_R       EQU     0x400FE608 
SYSCTL_PRGPIO_R		EQU     0x400FEA08 
PORT_BITS               EQU     1000100100000b ; ativar portas N, J e F

GPIO_PORTN_DATA_R    	EQU     0x40064000
GPIO_PORTN_DIR_R     	EQU     0x40064400
GPIO_PORTN_DEN_R     	EQU     0x4006451C

GPIO_PORTF_DATA_R    	EQU     0x4005d000
GPIO_PORTF_DIR_R     	EQU     0x4005d400
GPIO_PORTF_DEN_R     	EQU     0x4005d51C

GPIO_PORTJ_DATA_R    	EQU     0x40060000
GPIO_PORTJ_DIR_R     	EQU     0x40060400
GPIO_PORTJ_DEN_R     	EQU     0x4006051C
GPIO_PORTJ_PUR_R        EQU     0x40060510

BIT_0                   EQU     00000001b
BIT_1                   EQU     00000010b
BIT_4                   EQU     00010000b




clock_Init ;sub-rotina para habilitar clock das portas N, F e J
       
       ;habilitar porta N
       MOV R2, #PORT_BITS
       LDR R0, =SYSCTL_RCGCGPIO_R
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita portas N, J e F
       STR R1, [R0] ; escrita do novo estado

       LDR R0, =SYSCTL_PRGPIO_R
wait
       LDR R2, [R0] ; leitura do estado atual
       TEQ R1, R2 ; clock das portas ativados?
       BNE wait ; caso negativo, aguarda (NE = not equal)

       BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IO_Init ;sub-rotina para configurar portas como entrada ou saída
       MOV R2, #BIT_0 ; bit 0 da porta N
       
       LDR R0, =GPIO_PORTN_DIR_R ; porta N
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; bit de saída (terminal 0)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_1 ; bit 1 da porta N
       
       LDR R0, =GPIO_PORTN_DIR_R ; porta N
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; bit de saída (terminal 1)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_0 ; bit 0 da porta F
       
       LDR R0, =GPIO_PORTF_DIR_R ; porta F
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; bit de saída (terminal 0)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_4 ; bit 4 da porta F
       
       LDR R0, =GPIO_PORTF_DIR_R ; porta F
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; bit de saída (terminal 4)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_0 ; bit 0 da porta J

       LDR R0, =GPIO_PORTJ_DIR_R ; porta J
       LDR R1, [R0] ; leitura do estado anterior
       BIC R1, R1, #BIT_0 ; bit de entrada (terminal 0)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_1 ; bit 1 da porta J

       LDR R0, =GPIO_PORTJ_DIR_R ; porta J
       LDR R1, [R0] ; leitura do estado anterior
       BIC R1, R1, #BIT_1 ; bit de entrada (terminal 1)
       STR R1, [R0] ; escrita do novo estado

       LDR R0, =GPIO_PORTJ_PUR_R ;habilitar pull-up nos botões
       LDR R1, [R0]
       ORR R1, #11b ;habilitar pull up nos bits 0 e 1
       STR R1, [R0]

       BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     
      
digital_Enable ;sub-rotina para ativar funções digitais
       MOV R2, #BIT_0

       LDR R0, =GPIO_PORTN_DEN_R ; porta N
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita função digital (terminal 0)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_1

       LDR R0, =GPIO_PORTN_DEN_R ; porta N
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita função digital (terminal 1)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_0

       LDR R0, =GPIO_PORTF_DEN_R ; porta F
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita função digital (terminal 0)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_4

       LDR R0, =GPIO_PORTF_DEN_R ; porta F
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita função digital (terminal 4)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_0

       LDR R0, =GPIO_PORTJ_DEN_R ; porta J
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita função digital (terminal 0)
       STR R1, [R0] ; escrita do novo estado

       MOV R2, #BIT_1

       LDR R0, =GPIO_PORTJ_DEN_R ; porta J
       LDR R1, [R0] ; leitura do estado anterior
       ORR R1, R2 ; habilita função digital (terminal 1)
       STR R1, [R0] ; escrita do novo estado

       BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

delay
        PUSH {R3}
        MOVT R3, #0x0004 ; constante de atraso 
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
        PUSH {R3}
        LSL R3, R3, #1 ;bit 1 da porta N segue estado do bit 0 do contador
        STR R3, [R0, #0x8] ;(afeta apenas bit 1)
        POP {R3}
        
        BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LED2change
        ;LED 2 troca de estado
        PUSH {R3}
        LSR R3, R3, #1 ;bit 0 da porta N segue o estado do bit 1 do contador
        STR R3, [R0, #0x4] ;(afeta apenas bit 0)
        POP {R3}
        
        BX LR        
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LED3change
        ;LED 3 troca de estado
        PUSH {R3}
        LSL R3, R3, #2 ;bit 4 da porta F segue o estado do bit 2 do contador
        STR R3, [R2, #0x40] ;(afeta apenas bit 4)
        POP {R3}
        
        BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LED4change
        ;LED 4 troca de estado
        PUSH {R3}
        LSR R3, R3, #3 ;bit 0 da porta F segue o estado do bit 3 do contador
        STR R3, [R2, #0x4] ;(afeta apenas bit 0)
        POP {R3}
        
        BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         

read_Buttons
        PUSH {R0, R2}
        
        LDR R0, [R1, #0x4] ; (lê estado do botão SW1)

        ORRS R2, R0, R4;somar contador apenas se R4 for 0 e R0 for 0
        IT EQ
         ADDEQ R3, R3, #1

        CMP R0, #0 
        ITE EQ
         MOVEQ R4, #1
         MOVNE R4, #0
         
         
        LDR R0, [R1, #0x8] ; (lê estado do botão SW2)

        ORRS R2, R0, R5;diminuir contador apenas se R5 for 0 e R0 for 0
        IT EQ
         SUBEQ R3, R3, #1

        
        CMP R0, #0
        ITE EQ
         MOVEQ R5, #1
         MOVNE R5, #0
         
        CMP R3, #16
        IT EQ
         MOVEQ R3, #0
         
        CMP R3, #-1
        IT EQ
         MOVEQ R3, #15
         
        POP {R0, R2}
         
        BX LR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
        

__iar_program_start

        
main   
        BL clock_Init
        BL IO_Init
        BL digital_Enable
        
 	LDR R0, = GPIO_PORTN_DATA_R
        LDR R1, = GPIO_PORTJ_DATA_R
        LDR R2, = GPIO_PORTF_DATA_R
        
        MOV R3, #0 ;faz os LEDS começarem apagados e é utilizado como contador
        STR R3, [R0, #0x3FC] 
        STR R3, [R2, #0x3FC]
        
        MOV R4, #0 ;indica se o botão SW1 está pressionado
        MOV R5, #0 ;indica se o botão SW2 está pressionado
        
loop    
        BL read_Buttons
        BL LED1change
        BL LED2change
        BL LED3change
        BL LED4change
        BL delay
       
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