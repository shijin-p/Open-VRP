;;; Nearest Neighborhood algorithm (greedy) for TSP (NOT defined for (C)VRP(TW)!)
;;; -----
;;; Start at base, and keep choosing the next closest one
(in-package :open-vrp.algo)    

(defclass greedy-NN (algo)
  ((name :initform "Greedy NN-algo")
   (desc :initform "Nearest Neighborhood algo; from base/random, select next closest one")))

;; Greedy NN algo for TSP problem (no fleet)

(defmethod run-algo ((p problem) (a greedy-NN))
  "While there exists unchosen nodes, keep appending it. Returns the <Algo> object when done. Also prints the fitness and solution (run-algo :after method)."
  (let ((v (vehicle p 0)))
    (awhile (get-closest-node p 0 (route-indices v))
      (append-node v it)))
  (init-algo p a)
  a)