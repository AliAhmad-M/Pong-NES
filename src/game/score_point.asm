; X register stores address for index of sprite
SCORE_POINT:
  ; At max score already
  CPX #$0B
  BEQ END_SCORE_POINT

  ; Move to next number sprite to increment score by 1
  INX

  END_SCORE_POINT:
    TXA
  
  RTS