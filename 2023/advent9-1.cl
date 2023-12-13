;; Advent of Code 2023 - Day 9: Mirage Maintenance, part 1
;; Mic, 2023

(defun diffpairs (x)
  "E.g. (1 1 2 5) -> (0 1 3)"
  (if (null (cdr x)) nil
      (cons (- (car (cdr x)) (car x)) (diffpairs (cdr x)))))

(defun complete-history (x)
    (cond
        ((numberp (car x)) (complete-history (list x)))
        ((= 0 (reduce 'logior (car (last x)) :initial-value 0)) x)
        (t (complete-history (append x (list (diffpairs (car (last x)))))))))

(defun predict (x)
  (if (null (cdr x)) (append x '(0))
      (cons
        (append (car x)(list (+ (car (last (car x))) (car (last (car (predict (cdr x))))))))
        (cdr x))))

(defun split-string (string)
  (loop for i = 0 then (1+ j)
    as j = (position #\Space string :start i)
    collect (subseq string i j)
    while j))

(defun get-file (filename)
  (with-open-file (stream filename)
    (loop for line = (read-line stream nil)
      while line
      collect line)))

(defun get-histories-from-file (filename)
    (mapcar (lambda (arg) (mapcar 'parse-integer arg)) (mapcar 'split-string (get-file filename))))

(if (null (car *ARGS*)) (format t "Error: no input file specified")
    (format t "Sum of extrapolated values: ~D~%" (apply '+
      (mapcar (lambda (arg) (car (last (car (predict (complete-history arg))))))
              (get-histories-from-file (car *ARGS*))))))