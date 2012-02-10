;;; Fleet related functions
;;; ---------------------------
;;; - route-indices returns list of node IDs, given <vehicle>/<problem>
;;; - vehicle-with-node returns <vehicle> that has the node-ID
;;; - create-vehicles generates a list of <Vehicle> objects
;;; - total-dist returns the total distance given a <vehicle>/<problem> object

(in-package :open-vrp.util)

(defgeneric route-indices (obj)
  (:method (vehicle) "Input is not a <vehicle>/<problem> object!")
  (:documentation "When input is a <vehicle>, returns its route as a list of node IDs. When input is <fleet>/<problem>, list all routes."))

(defmethod route-indices ((v vehicle))
  (mapcar #'node-ID (vehicle-route v)))

(defmethod route-indices ((p problem))
  (mapcar #'route-indices (problem-fleet p)))

(defgeneric vehicle-with-node-ID (obj node-id)
  (:method (obj node) "Expects <problem> and int as inputs!")
  (:documentation "Given a node-ID, return the vehicle-ID that has the node in its route. The function for the input of the base-node 0 is undefined. Returns NIL if node-ID cannot be found."))

(defmethod vehicle-with-node-ID ((p problem) node-ID)
  (position-if #'(lambda (route) (member node-ID route)) (route-indices p)))

(defgeneric total-dist (veh/prob dist-array)
  (:method (veh/prob dist-array) "Expects <problem> as input!")
  (:documentation "Returns total distance of the route(s) given a vehicle or a fleet."))

(defmethod total-dist ((v vehicle) dist-array)
  (let ((route (vehicle-route v)))
    (labels ((iter (togo sum)
	       (if (null (cdr togo)) sum
		   (iter (cdr togo)
			 (+ sum
			    (handler-case (distance (node-id (car togo))
						    (node-id (cadr togo))
						    dist-array)
			      (same-origin-destination () 0)))))))
      (iter route 0))))
	       

(defmethod total-dist ((p problem) dist-array)
  (sum (mapcar #'(lambda (v) (total-dist v dist-array)) (get-busy-vehicles p))))

;; Accessor functions
;; ------------------
(defmethod vehicle ((p problem) id)
  (nth id (problem-fleet p)))
;; ------------------

;; Create Vehicle macro
;; ------------------
(defmacro new-vehicle (id base-node to-depot &key capacity speed)
  `(make-instance 'vehicle
		  :id ,id
		  :route ,(if to-depot `(list ,base-node ,base-node) `(list ,base-node))
		  ,@(when capacity `(:capacity ,capacity))
		  ,@(when speed `(:speed ,speed))))