#lang racket

(module+ main
  (require racket/gui)
  (require racket/date)
  (define (draw-in dc x-mid y-mid using-color total-depth  remaining-depth)
    (when (> remaining-depth 0)
      (define depth-to-go-% (/ remaining-depth total-depth))  ; 100% -> 0%
      (define general-decay-weight (expt 4 (- depth-to-go-% 1)))
      ;; Time stuff
      (define curr (current-date))
      (define curr-h (remainder (date-hour curr) 12))
      (define curr-m (date-minute curr))
      (define curr-s (date-second curr))
      ;; Coordinates
      (define hour-arm-length (* 80 general-decay-weight))
      (define minute-arm-length (* 150 general-decay-weight))
      (define second-arm-length (* 200 general-decay-weight))
      (define hour-arm-end-x (+ x-mid (* hour-arm-length (sin (* (/ curr-h 12.0) 2 pi)))))
      (define hour-arm-end-y (- y-mid (* hour-arm-length (cos (* (/ curr-h 12.0) 2 pi)))))
      (define minute-arm-end-x (+ x-mid (* minute-arm-length (sin (* (/ curr-m 60.0) 2 pi)))))
      (define minute-arm-end-y (- y-mid (* minute-arm-length (cos (* (/ curr-m 60.0) 2 pi)))))
      (define second-arm-end-x (+ x-mid (* second-arm-length (sin (* (/ curr-s 60.0) 2 pi)))))
      (define second-arm-end-y (- y-mid (* second-arm-length (cos (* (/ curr-s 60.0) 2 pi)))))
      ;; Draw the arms
      (define c (make-color (send using-color red)
                            (send using-color green)
                            (send using-color blue)
                            (* (send using-color alpha) general-decay-weight)))
      (send dc set-pen (make-pen #:color c #:width (* 10 general-decay-weight 1.2)))
      (send dc draw-line x-mid y-mid hour-arm-end-x hour-arm-end-y)
      (send dc set-pen (make-pen #:color c #:width (* 10 general-decay-weight 0.8)))
      (send dc draw-line x-mid y-mid minute-arm-end-x minute-arm-end-y)
      (send dc set-pen (make-pen #:color c #:width (* 10 general-decay-weight 0.6)))
      (send dc draw-line x-mid y-mid second-arm-end-x second-arm-end-y)
      ;; Draw a smaller clock in each end of the arms
      (draw-in dc
               hour-arm-end-x
               hour-arm-end-y
               using-color total-depth (- remaining-depth 1))
      (draw-in dc
               minute-arm-end-x
               minute-arm-end-y
               using-color total-depth (- remaining-depth 1))
      (draw-in dc
               second-arm-end-x
               second-arm-end-y
               using-color total-depth (- remaining-depth 1))
      (void)))
  (define (handle-frame canvas dc)
    (define width (send canvas get-width))
    (define height (send canvas get-height))
    (define bg-color (make-color 0 0 0 1.0))
    (send dc set-brush bg-color 'solid)
    (send dc draw-rectangle 0 0 width height)
    (define base-color (make-color 17 156 194 1.0)) ; Blueish
    (define remaining-depth 5)
    (draw-in dc (/ width 2) (/ height 2) base-color remaining-depth remaining-depth)
    ;; Time at the top-left corner
    (define curr (current-date))
    (define curr-h (date-hour curr))
    (define curr-m (date-minute curr))
    (define curr-s (date-second curr))
    (define time-string (format "~a:~a:~a" curr-h curr-m curr-s))
    (send dc set-text-foreground (make-color 255 255 255 1.0))
    (send dc draw-text time-string 0 0)
    (void))
  (define frame (new frame% [label "Fractal Clock"] [width 1600] [height 1200]))
  (new canvas% [parent frame] [paint-callback handle-frame])
  ;; Setup timer to redraw every second
  (define timer (new timer% [notify-callback (lambda () (send frame refresh))]))
  (send timer start 1000)
  ;; Show the frame (apprantly)
  (send frame show #t))
