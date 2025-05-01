(define (domain urbantraffic)

(:types junction link stage configuration)

(:predicates 
(controllable ?i - junction)
(inter ?p - stage)
(active ?p - stage)
(next ?p ?p1 - stage)
(trigger ?i - junction)
(contains ?i - junction ?p - stage)
(endcycle ?i - junction ?p - stage)
(activeconf ?i - junction ?c - configuration)
(availableconf ?i - junction ?c - configuration)
)

(:functions 
(turnrate ?x - stage ?r1 - link  ?r2 - link) 
(interlimit ?p - stage)
(occupancy ?r - link) 
(capacity ?r - link)  
(confgreentime ?p - stage ?c - configuration )
(greentime ?i - junction)
(intertime ?i - junction)
(counter ?r - link)
(countcycle ?i - junction)
(cyclelimit)
)

;; the maximum time limit for green has been reached, but no need to restart token!
(:event confgreenreached
 :parameters (?p - stage ?i - junction ?c - configuration)
 :precondition (and 
	(active ?p) (contains ?i ?p)
    (activeconf ?i ?c)
	(>= (greentime ?i) (confgreentime ?p ?c))
	)
  :effect (and
	(trigger ?i)
	)
)

;; process that keeps the green/intergreen on, and updates the greentime value
(:process keepgreen
:parameters (?p - stage ?i - junction ?c - configuration)
:precondition (and 
		(active ?p) (contains ?i ?p)
      (activeconf ?i ?c)
    (< (greentime ?i) (confgreentime ?p ?c))
)
:effect (and
		(increase (greentime ?i) (* #t 1 ) )
))

;;allows car to flow if the corresponding green is on
(:process flowrun_green
:parameters (?p - stage ?r1 ?r2 - link)
:precondition (and 
		(active ?p)
		(> (occupancy ?r1) 0.0)
		(> (turnrate ?p ?r1 ?r2) 0.0)
		(< (occupancy ?r2) (capacity ?r2))
)
:effect (and
		(increase (occupancy ?r2) (* #t (turnrate ?p ?r1 ?r2)))
		(decrease (occupancy ?r1) (* #t (turnrate ?p ?r1 ?r2)))
    (increase (counter ?r2) (* #t (turnrate ?p ?r1 ?r2)))
))

;; let the planner in control of changing configuration at the end of the phase cycle
(:action changeConfiguration
    :parameters (?p - stage ?i - junction ?c1 ?c2 - configuration)
    :precondition (and
        (inter ?p)
        (controllable ?i)
        (>= (countcycle ?i) (cyclelimit))
        (endcycle ?i ?p)
        (= (intertime ?i) (- (interlimit ?p) 1))
        (availableconf ?i ?c2)
        (activeconf ?i ?c1)
        (not (activeconf ?i ?c2))
    )
    :effect (and 
        (not (activeconf ?i ?c1))
        (activeconf ?i ?c2)
        (assign (countcycle ?i) 0)
    )
)

(:event trigger-inter
:parameters (?p - stage ?i - junction)
 :precondition (and
        (trigger ?i)
        (active ?p) (contains ?i ?p)
        )
  :effect (and
        (not (trigger ?i))
        (not (active ?p))
        (inter ?p)
	(assign (greentime ?i) 0)
        )
)


(:process keepinter
  :parameters (?p - stage ?i - junction)
  :precondition (and 
      (inter ?p) (contains ?i ?p)
      (< (intertime ?i) (interlimit ?p)  )
   )
   :effect (and
      (increase (intertime ?i) (* #t 1 ) )
   ))

(:event trigger-change
:parameters (?p ?p1 - stage ?i - junction)
 :precondition (and 
	(inter ?p) (contains ?i ?p)
        (next ?p ?p1)
        (>= (intertime ?i) (- (interlimit ?p) 0.1)  )
	)
  :effect (and
	(not (inter ?p))
        (active ?p1)
	(assign (intertime ?i) 0)
  (when (endcycle ?i ?p1) (increase (countcycle ?i) 1))
	)
)


)
