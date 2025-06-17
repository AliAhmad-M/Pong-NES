.include "delay_timer.asm"
.include "score_point.asm"

; +ve x | +ve y, -ve x | +ve y, +ve x | -ve y, -ve x | -ve y
VELOCITES_X:
  .byte %00000000, %10000000, %00000000, %10000000 

VELOCITES_Y:
  .byte %00000000, %00000000, %10000000, %10000000

MOV_BALL:
  ; Check if need to add delay
  CPY #$FF
  BEQ HANDLE_DELAY

  ; Handle movement normally
  JMP HANDLE_WALL_Y

  HANDLE_DELAY:
    JSR INCREMENT_TIMER

    LDA delay_timer
    CMP #$00
    BNE SKIP_MOV_BALL

    ; Reset the delay flag now
    LDY #$00

  HANDLE_WALL_Y:
    LDA $0208

    ; Invert y velocity for walls
    CMP #TOP_WALL
    BCC INVERT_VEL_Y

    CMP #BOTTOM_WALL
    BCS INVERT_VEL_Y

    JMP HANDLE_WALL_X
    INVERT_VEL_Y:
      LDA ball_vel_y
      EOR #%10000000
      STA ball_vel_y

  HANDLE_WALL_X:
    LDA $020B
    
    ; Reset ball position if out of bounds
    CMP #LEFT_WALL
    BCC PLAYER_2_SCORE

    CMP #RIGHT_WALL
    BCS PLAYER_1_SCORE

    JMP HANDLE_PADDLES

    PLAYER_1_SCORE:
      LDX $022D ; Player 1 score sprite index
      JSR SCORE_POINT

      STA $022D ; Store the new sprite index
      JMP RESET_BALL_POS

    PLAYER_2_SCORE:
      LDX $0231 ; Player 2 score sprite index
      JSR SCORE_POINT

      STA $0231 ; Store the new sprite index
      JMP RESET_BALL_POS

    RESET_BALL_POS:
      ; Reset X position
      LDA #$7C
      STA $020B

      ; Reset Y position
      LDA #$74
      STA $0208

      ; A flag to indicate we need to add delay
      LDY #$FF

      ; Set new initial velocity
      LDX ball_vel_index

      LDA VELOCITES_X, X
      STA ball_vel_x

      LDA VELOCITES_Y, X
      STA ball_vel_y

      ; Handle index range (0 - 3)
      LDA ball_vel_index
      CMP #$03
      BEQ RESET_INDEX

      CLC
      ADC #$01
      JMP STORE_INDEX

      RESET_INDEX:
        LDA #$00

      STORE_INDEX:
        STA ball_vel_index

      JMP HANDLE_PADDLES

  ; Had to add 2 jumps cuz range error
  SKIP_MOV_BALL:
    JMP END_MOV_BALL

  HANDLE_PADDLES:
    HANDLE_PADDLE_1:
      ; Check collision with paddle 1
      LDA $020B ; Load ball x position
      CMP #$16  ; Compare with paddle 1 right x position
      BCS HANDLE_PADDLE_2

      CMP #$14  ; Compare with paddle 1 mid x position
      BCC HANDLE_PADDLE_2

      LDX $020C ; Paddle 1 first sprite y position
      LDY $0218 ; Paddle 1 final sprite y position

      JMP CHECK_PADDLE_Y

    HANDLE_PADDLE_2:
      LDA $020B ; Load ball x position
      CMP #$E4  ; Compare with paddle 2 left x position
      BCC CHECK_VEL_X

      CMP #$E6  ; Compare with paddle 2 mid x position
      BCS CHECK_VEL_X

      LDX $021C ; Paddle 2 first sprite y position
      LDY $0228 ; Paddle 2 final sprite y position

      JMP CHECK_PADDLE_Y

    ; Compare ball y position with paddles
    ; X register stores first paddle sprite y position
    ; Y register stores final paddle sprite y position
    CHECK_PADDLE_Y:
      CHECK_PADDLE_TOP:
        TXA       ; Load paddle first sprite position
        STA temp  ; Store in temporary variable

        LDA $0208 ; Load the ball y position
        CMP temp  ; Compare with paddle top position
        BCS CHECK_PADDLE_BOTTOM

        JMP CHECK_VEL_X

      CHECK_PADDLE_BOTTOM:
        TYA       ; Load paddle last sprite position
        CLC
        ADC #$08  ; Calculate paddle bottom position
        STA temp  ; Store in temporary variable

        LDA $0208 ; Load the ball y position
        CMP temp  ; Compare with paddle 1 bottom position
        BCC INVERT_VEL_X

        JMP CHECK_VEL_X
        
        INVERT_VEL_X:
          LDA ball_vel_x
          EOR #%10000000
          STA ball_vel_x

          JMP CHECK_VEL_X


  CHECK_VEL_X:
    ; Move ball x
    LDA ball_vel_x
    AND #%10000000
    BEQ MOV_NEG_X
    JMP MOV_POS_X

  MOV_POS_X:
    ; Load x position
    LDA $020B
    CLC
    ADC #$02  ; Move right

    JMP END_MOV_X

  MOV_NEG_X:
    ; Load x position
    LDA $020B
    SEC
    SBC #$02  ; Move left

    JMP END_MOV_X

  END_MOV_X:
    ; Save x position
    STA $020B
  
  CHECK_VEL_Y:
    ; Move ball y
    LDA ball_vel_y
    AND #%10000000
    BEQ MOV_NEG_Y
    JMP MOV_POS_Y

  MOV_POS_Y:
    ; Load y position
    LDA $0208
    CLC
    ADC #$01  ; Move down
    
    JMP END_MOV_Y
  MOV_NEG_Y:
    ; Load y position
    LDA $0208
    SEC
    SBC #$01  ; Move up

    JMP END_MOV_Y

  END_MOV_Y:
    ; Save y position
    STA $0208
  
  END_MOV_BALL:
  RTS