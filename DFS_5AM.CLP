;; Создаём шаблон структуры для головоломки (Расположение ячейки; Факт использования; Число в ячейке)
(
    deftemplate Puzzle_8
      (slot Location (type INTEGER) (range 1 9))
      (slot isUsed (type SYMBOL) (allowed-symbols YES NO))
      (slot Numeral (type INTEGER) (range 1 9))
)

(
      deftemplate flag
        (slot f (type INTEGER) (default 0))
        (slot ff (type INTEGER) (default 0))
        (slot f_best (type INTEGER) (default 0))
)

(
      deftemplate final_depth
        (slot dpth (type INTEGER) (default 0))
)

(
      deftemplate iter_checker
        (slot icheck (type INTEGER) (default 0))
)

(
      deftemplate array_checker
        (slot acheck (type INTEGER) (default 0))
)

(
      deftemplate locator_checker
        (slot locator (type INTEGER) (default 0))
)

(
      deffacts flagtemp
        (flag (f 0))
        (flag (ff 0))
        (flag (f_best 0))
        (final_depth (dpth 0))
        (iter_checker (icheck 0))
        (array_checker (acheck 0))
        (locator_checker (locator 0))
)



;; Создаём факт по умолчанию для следующего вида входной головоломки
;;-------
;;-4 3 1-
;;-8 2 5-
;;-7 6 9-
;;-------

;; Целевое состояние
;;-------
;;-1 2 3-
;;-4 5 6-
;;-7 8 9-
;;-------
(
    deffacts Initial_Puzzle
      (Puzzle_8 (Location 1) (isUsed YES) (Numeral 1))
      (Puzzle_8 (Location 2) (isUsed YES) (Numeral 5))
      (Puzzle_8 (Location 3) (isUsed YES) (Numeral 2))
      (Puzzle_8 (Location 4) (isUsed YES) (Numeral 4))
      (Puzzle_8 (Location 5) (isUsed YES) (Numeral 8))
      (Puzzle_8 (Location 6) (isUsed YES) (Numeral 3))
      (Puzzle_8 (Location 7) (isUsed YES) (Numeral 7))
      (Puzzle_8 (Location 8) (isUsed YES) (Numeral 6))
      (Puzzle_8 (Location 9) (isUsed NO) (Numeral 9))
)

;; Таблица переходов состояний (из №ячейки в №ячейки)
;;  1 ->  2,4
;;  2 ->  1,3,5
;;  3 ->  2,6
;;  4 ->  1,5,7
;;  5 ->  2,4,6,8
;;  6 ->  0,3,5
;;  7 ->  4,8
;;  8 ->  0,5,7
;;  9 ->  6,8

;; Создаём шаблон-конструкцию возможных переходов
(
      deftemplate Step_Of_Puzzle
        (slot from (type INTEGER) (range 1 9))
        (multislot to (type INTEGER) (range 1 9))
)

;; Определяем факты как основу возможных переходов
(
      deffacts Facts_Of_Puzzle
        (Step_Of_Puzzle (from 1) (to 4 2))
        (Step_Of_Puzzle (from 2) (to 5 3 1))
        (Step_Of_Puzzle (from 3) (to 6 2))
        (Step_Of_Puzzle (from 4) (to 7 5 1))
        (Step_Of_Puzzle (from 5) (to 8 6 2 4))
        (Step_Of_Puzzle (from 6) (to 9 3 5))
        (Step_Of_Puzzle (from 7) (to 8 4))
        (Step_Of_Puzzle (from 8) (to 9 5 7))
        (Step_Of_Puzzle (from 9) (to 6 8))
)

(
      deftemplate state
        (slot Dead (type SYMBOL) (allowed-symbols YES NO) (default NO))
        (slot Location (type INTEGER) (default 0))
        (slot Depth (type INTEGER) (default 0))
        (slot flag_last (type SYMBOL) (allowed-symbols YES NO))
        (slot heuristic_cost (type INTEGER) (default 0))
        (multislot visited_numerals (default 0 0 0 0 0 0 0 0 0))
)

(
      deffacts states
        (state (Location 0) (Depth 0) (flag_last YES) (heuristic_cost 0))
)

;; Функция вычисления эвристики (число фишек не на своиъ местах)
(
      deffunction misplaced (?nums)
        ;;(bind ?nums (subseq$ ?st 5 5))
        (bind ?c 0)
        (bind ?d (+ ?c 1))
        (
            if (<> (nth$ 1 ?nums) 1)
              then
                (bind ?c (+ ?c ?d))
        )
        (
            if (<> (nth$ 2 ?nums) 2)
              then
                (bind ?c (+ ?c ?d))
        )
        (
            if (<> (nth$ 3 ?nums) 3)
              then
                (bind ?c (+ ?c ?d))
        )
        (
            if (<> (nth$ 4 ?nums) 4)
              then
                (bind ?c (+ ?c ?d))
        )
        (
            if (<> (nth$ 5 ?nums) 5)
              then
                (bind ?c (+ ?c ?d))
        )
        (
            if (<> (nth$ 6 ?nums) 6)
              then
                (bind ?c (+ ?c ?d))
        )
        (
            if (<> (nth$ 7 ?nums) 7)
              then
                (bind ?c (+ ?c ?d))
        )
        (
            if (<> (nth$ 8 ?nums) 8)
              then
                (bind ?c (+ ?c ?d))
        )
        (
            if (<> (nth$ 9 ?nums) 9)
              then
                (bind ?c (+ ?c ?d))
        )
        (return ?c)
)

;; Функция вычисления эвристики (манхэттен)
(
      deffunction manhattan (?nums)
        (bind ?i 9)
        (bind ?result 0)
        (while (> ?i 0)
            (bind ?numb (nth$ ?i ?nums))
            ;;(printout t crlf "Number is: " ?numb crlf)
            (bind ?goalcolumn (abs(mod (- ?numb 1) 3)))
            (bind ?goalrow (abs(div (- ?numb 1) 3)))
            ;;(printout t crlf "Goal col is: " ?goalcolumn ", Goal row is: " ?goalrow crlf)
            (bind ?curcolumn 0)
            (bind ?currow 0)
            (
            if (= ?i 9)
              then
                (bind ?curcolumn 2)
                (bind ?currow 2)
            )
            (
            if (= ?i 8)
              then
                (bind ?curcolumn 1)
                (bind ?currow 2)
            )
            (
            if (= ?i 7)
              then
                (bind ?curcolumn 0)
                (bind ?currow 2)
            )
            (
            if (= ?i 6)
              then
                (bind ?curcolumn 2)
                (bind ?currow 1)
            )
            (
            if (= ?i 5)
              then
                (bind ?curcolumn 1)
                (bind ?currow 1)
            )
            (
            if (= ?i 4)
              then
                (bind ?curcolumn 0)
                (bind ?currow 1)
            )
            (
            if (= ?i 3)
              then
                (bind ?curcolumn 2)
                (bind ?currow 0)
            )
            (
            if (= ?i 2)
              then
                (bind ?curcolumn 1)
                (bind ?currow 0)
            )
            (
            if (= ?i 1)
              then
                (bind ?curcolumn 0)
                (bind ?currow 0)
            )
            ;;(printout t crlf "Cur col is: " ?curcolumn ", Cur row is: " ?currow crlf)
            (bind ?temp (+ (abs(- ?curcolumn ?goalcolumn)) (abs(- ?currow ?goalrow))))
            (bind ?result (+ ?temp ?result))
            (bind ?i (- ?i 1))
        )
        ;;(printout t crlf "The final result is " ?result crlf)
        (return ?result)
)

(
      defrule backtracking
        (declare (salience 5))
        ?fd<-(final_depth (dpth ?dp))
        ?fmove<-(flag (f ?fmeaning) (ff ?finmeaning))
        (not
          (exists (Puzzle_8 (Location ?loc) (Numeral ~?loc)))
        )
        (state (Location ?value1) (Depth ?dp) (visited_numerals $?some_nums))
        ;;(not (state (Location ?value2&:(> ?value2 ?value1))))
        (test (= ?finmeaning 1))
        =>
        (printout t ?value1 "For depth, which is " ?dp " the state is " $?some_nums crlf)
        (modify ?fd (dpth (- ?dp 1)))
)

(
      defrule finish
        (declare (salience 6))
        ?fmove<-(flag (f ?fmeaning) (ff ?finmeaning))
        (test (<> ?finmeaning 1))
        (not
          (exists (Puzzle_8 (Location ?loc) (Numeral ~?loc)))
        )
        =>
        (modify ?fmove 
            (f 2)
        )
        (modify ?fmove 
            (ff 1)
        )
        (halt)
)

;; Вышеуказанное правило работоспособно только лишь в случае, когда в базе фактов
;; уже есть два состояния с различными идентификаторами (расположения), поэтому из нач состояние нельзя двигаться
(
        defrule first_move
          (declare (salience 3))
          ?fmove<-(flag (f ?fmeaning))
          ?id<-(iter_checker (icheck ?ich))
          ?ad<-(array_checker (acheck ?ach))
          ?locat<-(locator_checker (locator ?l))
          ?from<-(Puzzle_8 (Location ?from_location) (isUsed YES) (Numeral ?number))
          ?to<-(Puzzle_8 (Location ?to_location) (isUsed NO) (Numeral ~?number))
          ?stp<-(Step_Of_Puzzle (from ?from_location) (to $?to_array&:(member$ ?to_location ?to_array)))
          ?st<-(state (flag_last YES) (Location ?state_location) (Depth ?dep) (visited_numerals $?some_nums))
          (test (= ?fmeaning 0))
          (
            forall 
              (state (Location 0) (Depth 0) (visited_numerals $?nums))
              (state (Location 0) (Depth 0) (visited_numerals $?some_nums)) 
          )
          =>
          (modify ?from
            (isUsed NO) 
            (Numeral 9)
          )
          (modify ?to 
            (isUsed YES)
            (Numeral ?number)
          )
          (modify ?fmove 
            (f 1)
          )
          (bind ?c (+ ?ich 1))
          (bind ?new_l (+ ?l 1))
          (bind ?temp (nth$ 1 (find-fact ((?f Step_Of_Puzzle)) (= ?f:from ?to_location))))
          (bind $?from_array (fact-slot-value ?temp to))
          (bind ?len (length$ ?from_array))
          ;;(printout t crlf ?temp crlf)
          ;;(printout t crlf "From " ?from_location)
          ;;(printout t crlf "To " ?to_location)
          ;;(printout t crlf "Length of 'to' is " ?len)
          ;;(printout t crlf "Visited "?c crlf)
          (modify ?id 
            (icheck ?c)
          )
          (modify ?ad 
            (acheck ?len)
          )
          (modify ?locat 
            (locator ?new_l)
          )
          (assert (state (flag_last NO) (Location ?new_l) (Depth (+ ?dep 1))))
)

;; Вычисляем эвристическую стоимость по критерию (количество фишек не на своих местах)
(
      defrule get_h_cost
        (declare (salience 4))
        ?fd<-(final_depth (dpth ?dp))
        ?st<-(state (Location ?loc) (heuristic_cost ?cost) (visited_numerals $?nums))
        (test (= ?cost 0))
        =>
        (bind ?temp (+ ?dp (manhattan ?nums)))
        (modify ?st (heuristic_cost ?temp))
)

(
      deffunction find_minimal (?value1 ?value2)
        (< ?value1 ?value2)
)

(
      deffunction find_maximal (?value1 ?value2)
        (> ?value1 ?value2)
)

(
      defrule find_duplicate_heuristic
        (declare (salience 4))
        ?fd<-(final_depth (dpth ?dp))
        ?st<-(state (flag_last NO) (Location ?loc1) (Depth ?dp) (Dead NO) (heuristic_cost ?value1))
        ?st1<-(state (flag_last YES) (Location ?loc2&:(find_maximal ?loc2 ?loc1)) (Dead NO) (Depth ?dp) (heuristic_cost ?value1))
        ;;(exists (state (Depth ?dp) (flag_last YES)))
        =>
        ;;(printout t crlf ?st1 crlf)
        (modify ?st1
          (flag_last NO) 
        )
        (modify ?st
          (flag_last YES) 
        )
)

(
      defrule find_best_cost
        (declare (salience 2))
        ?id<-(iter_checker (icheck ?ich))
        ?ad<-(array_checker (acheck ?ach))
        ?element1<-(Puzzle_8 (Location 1))
        ?element2<-(Puzzle_8 (Location 2))
        ?element3<-(Puzzle_8 (Location 3))
        ?element4<-(Puzzle_8 (Location 4))
        ?element5<-(Puzzle_8 (Location 5))
        ?element6<-(Puzzle_8 (Location 6))
        ?element7<-(Puzzle_8 (Location 7))
        ?element8<-(Puzzle_8 (Location 8))
        ?element9<-(Puzzle_8 (Location 9))
        ?from<-(Puzzle_8 (Location ?from_location) (isUsed YES) (Numeral ?number))
        ?to<-(Puzzle_8 (Location ?to_location) (isUsed NO) (Numeral ~?number))
        ?stp<-(Step_Of_Puzzle (from ?from_location) (to $?to_array&:(member$ ?to_location ?to_array)))
        ?fbest<-(flag (f_best ?fb))
        (test (<> ?fb 1))
        ?fd<-(final_depth (dpth ?dp))
        ?penultimate_state<-(state (flag_last YES))
        ?st<-(state (Dead NO) (Depth ?dp) (flag_last NO) (heuristic_cost ?value1) (visited_numerals $?nums))
        (not (state (Dead NO) (Depth ?dp) (flag_last NO) (visited_numerals $?some_nums) (heuristic_cost ?value2&:(find_minimal ?value2 ?value1))))
        ;;(not (state (Location ?v2&:(find_minimal ?v2 ?v1)) (Dead NO) (Depth ?dp) (flag_last NO) (visited_numerals $?some_nums)))
        =>
        (bind ?temp (nth$ 1 (find-fact ((?f Step_Of_Puzzle)) (= ?f:from ?to_location))))
        (bind $?from_array (fact-slot-value ?temp to))
        (bind ?len (length$ ?from_array))
        ;;(printout t crlf ?st crlf)
        ;;(printout t crlf (sort > (find-all-facts ((?f state)) (= ?f:Depth ?dp)) crlf))
        ;;(printout t "Fact " ?value1 " is the minimum" crlf)
        ;;(printout t crlf (find-all-facts ((?f state)) (= ?f:Depth ?dp)) crlf)
        (modify ?st
          (flag_last YES) 
        )
        (modify ?penultimate_state
          (flag_last NO) 
        )
        (modify ?fbest
            (f_best 1)
        )
        (
            if (= (nth$ 1 ?nums) 9)
              then
              (modify ?element1 (isUsed NO) (Numeral (nth$ 1 ?nums)))
              else
              (modify ?element1 (isUsed YES) (Numeral (nth$ 1 ?nums)))
          )
          (
            if (= (nth$ 2 ?nums) 9)
              then
              (modify ?element2 (isUsed NO) (Numeral (nth$ 2 ?nums)))
              else
              (modify ?element2 (isUsed YES) (Numeral (nth$ 2 ?nums)))
          )
          (
            if (= (nth$ 3 ?nums) 9)
              then
              (modify ?element3 (isUsed NO) (Numeral (nth$ 3 ?nums)))
              else
              (modify ?element3 (isUsed YES) (Numeral (nth$ 3 ?nums)))
          )
          (
            if (= (nth$ 4 ?nums) 9)
              then
              (modify ?element4 (isUsed NO) (Numeral (nth$ 4 ?nums)))
              else
              (modify ?element4 (isUsed YES) (Numeral (nth$ 4 ?nums)))
          )
          (
            if (= (nth$ 5 ?nums) 9)
              then
              (modify ?element5 (isUsed NO) (Numeral (nth$ 5 ?nums)))
              else
              (modify ?element5 (isUsed YES) (Numeral (nth$ 5 ?nums)))
          )
          (
            if (= (nth$ 6 ?nums) 9)
              then
              (modify ?element6 (isUsed NO) (Numeral (nth$ 6 ?nums)))
              else
              (modify ?element6 (isUsed YES) (Numeral (nth$ 6 ?nums)))
          )
          (
            if (= (nth$ 7 ?nums) 9)
              then
              (modify ?element7 (isUsed NO) (Numeral (nth$ 7 ?nums)))
              else
              (modify ?element7 (isUsed YES) (Numeral (nth$ 7 ?nums)))
          )
          (
            if (= (nth$ 8 ?nums) 9)
              then
              (modify ?element8 (isUsed NO) (Numeral (nth$ 8 ?nums)))
              else
              (modify ?element8 (isUsed YES) (Numeral (nth$ 8 ?nums)))
          )
          (
            if (= (nth$ 9 ?nums) 9)
              then
              (modify ?element9 (isUsed NO) (Numeral (nth$ 9 ?nums)))
              else
              (modify ?element9 (isUsed YES) (Numeral (nth$ 9 ?nums)))
          )
          (modify ?id 
            (icheck 0)
          )
          (modify ?ad 
            (acheck ?len)
          )

)

;;(
;;      defrule find_best_cost_eq
;;        (declare (salience 0))
;;        ?fd<-(final_depth (dpth ?dp))
;;        ?fbest<-(flag (f_best ?fb))
;;        (test (<> ?fb 1))
;;        ?penultimate_state<-(state (flag_last YES))
;;        ?st<-(state (Location ?value1))
;;;        (not (state (Location ?value2&:(find_minimal ?value2 ?value1))))
;;        =>
;;        (printout t "Fact " ?value1 " is the minimum" crlf)
;;        (modify ?st
;;          (flag_last YES) 
;;        )
;;        (modify ?penultimate_state
;;          (flag_last NO) 
;;        )
;;)

;;(
;;      defrule clear
;;      (declare (salience 4))
;;        ?fd<-(final_depth (dpth ?dp))
;;        ?st<-(state (Dead NO) (Depth ?dp) (flag_last NO))
;;        (exists (state (Depth ?dp) (flag_last YES)))
;;        =>
;;        (retract ?st)
;;)

;; replace$ - заменить в, начиная от, до, чем (мб несколько = участку от-до)
(
      defrule move
        (declare (salience 3))
        ?fmove<-(flag (f ?fmeaning))
        ?fd<-(final_depth (dpth ?dp))
        ?id<-(iter_checker (icheck ?ich))
        ?ad<-(array_checker (acheck ?ach))
        ?fbest<-(flag (f_best ?fb))
        ?locat<-(locator_checker (locator ?l))
        ?from<-(Puzzle_8 (Location ?from_location) (isUsed YES) (Numeral ?number))
        ?to<-(Puzzle_8 (Location ?to_location) (isUsed NO) (Numeral ~?number))
        (Step_Of_Puzzle (from ?from_location) (to $?to_array&:(member$ ?to_location ?to_array)))
        ?st<-(state (flag_last YES) (Location ?state_location) (Depth ?dep) (heuristic_cost ?h) (visited_numerals $?some_nums))
        (test (< ?dep 15))
        (test (<> ?fmeaning 2))
        (test (member$ ?to_location $?to_array))
        (test (<> ?ich ?ach))
        (
          forall 
            (state (Location ~?state_location) (visited_numerals $?nums&~$?some_nums))
            (test (neq (replace$ (replace$ $?some_nums ?to_location ?to_location ?number) ?from_location ?from_location 9) $?nums))
        )
        =>
        (modify ?from
          (isUsed NO)  
          (Numeral 9)
        )
        (modify ?to
          (isUsed YES) 
          (Numeral ?number)
        )
        (bind ?c (+ ?ich 1))
        (bind ?new_l (+ ?l 1))
        (bind ?temp (nth$ 1 (find-fact ((?f Step_Of_Puzzle)) (= ?f:from ?to_location))))
        (bind $?from_array (fact-slot-value ?temp to))
        (bind ?len (length$ ?from_array))
        ;;(printout t crlf "From " ?from_location)
        ;;(printout t crlf "To " ?to_location)
        ;;(printout t crlf "Length of 'to' is " ?len)
        ;;(printout t crlf "They are " $?from_array)
        ;;(printout t crlf "Visited "?c crlf)
        (modify ?id 
          (icheck ?c)
        )
        (modify ?ad 
            (acheck ?len)
        )
        (modify ?locat 
            (locator ?new_l)
        )
        (modify ?fbest
            (f_best 0)
        )
        (assert (state (flag_last NO) (Location ?new_l) (Depth (+ ?dep 1))))
)

(
        defrule reint_puzzle
          (declare (salience 7))
          ?element1<-(Puzzle_8 (Location 1))
          ?element2<-(Puzzle_8 (Location 2))
          ?element3<-(Puzzle_8 (Location 3))
          ?element4<-(Puzzle_8 (Location 4))
          ?element5<-(Puzzle_8 (Location 5))
          ?element6<-(Puzzle_8 (Location 6))
          ?element7<-(Puzzle_8 (Location 7))
          ?element8<-(Puzzle_8 (Location 8))
          ?element9<-(Puzzle_8 (Location 9))
          ?last_state<-(state (flag_last YES) (visited_numerals $?nums))
          =>
          (
            if (= (nth$ 1 ?nums) 9)
              then
              (modify ?element1 (isUsed NO) (Numeral (nth$ 1 ?nums)))
              else
              (modify ?element1 (isUsed YES) (Numeral (nth$ 1 ?nums)))
          )
          (
            if (= (nth$ 2 ?nums) 9)
              then
              (modify ?element2 (isUsed NO) (Numeral (nth$ 2 ?nums)))
              else
              (modify ?element2 (isUsed YES) (Numeral (nth$ 2 ?nums)))
          )
          (
            if (= (nth$ 3 ?nums) 9)
              then
              (modify ?element3 (isUsed NO) (Numeral (nth$ 3 ?nums)))
              else
              (modify ?element3 (isUsed YES) (Numeral (nth$ 3 ?nums)))
          )
          (
            if (= (nth$ 4 ?nums) 9)
              then
              (modify ?element4 (isUsed NO) (Numeral (nth$ 4 ?nums)))
              else
              (modify ?element4 (isUsed YES) (Numeral (nth$ 4 ?nums)))
          )
          (
            if (= (nth$ 5 ?nums) 9)
              then
              (modify ?element5 (isUsed NO) (Numeral (nth$ 5 ?nums)))
              else
              (modify ?element5 (isUsed YES) (Numeral (nth$ 5 ?nums)))
          )
          (
            if (= (nth$ 6 ?nums) 9)
              then
              (modify ?element6 (isUsed NO) (Numeral (nth$ 6 ?nums)))
              else
              (modify ?element6 (isUsed YES) (Numeral (nth$ 6 ?nums)))
          )
          (
            if (= (nth$ 7 ?nums) 9)
              then
              (modify ?element7 (isUsed NO) (Numeral (nth$ 7 ?nums)))
              else
              (modify ?element7 (isUsed YES) (Numeral (nth$ 7 ?nums)))
          )
          (
            if (= (nth$ 8 ?nums) 9)
              then
              (modify ?element8 (isUsed NO) (Numeral (nth$ 8 ?nums)))
              else
              (modify ?element8 (isUsed YES) (Numeral (nth$ 8 ?nums)))
          )
          (
            if (= (nth$ 9 ?nums) 9)
              then
              (modify ?element9 (isUsed NO) (Numeral (nth$ 9 ?nums)))
              else
              (modify ?element9 (isUsed YES) (Numeral (nth$ 9 ?nums)))
          )
)

;; Сохраняем состояние
(
        defrule save_first_state_position
          (declare (salience 8))
          ?element<-(Puzzle_8 (Location ?loc) (Numeral ?number))
          ?st<-(state (flag_last YES) (Depth ?dpt) (visited_numerals $?nums))
          ?fd<-(final_depth (dpth ?dp))
          (not (test (member$ ?number ?nums)))
          =>
          (bind ?nums (delete$ ?nums ?loc ?loc))
          (bind ?nums (insert$ ?nums ?loc ?number))
          (modify ?st (visited_numerals ?nums))
          (modify ?fd (dpth ?dpt))
)

;; Сохраняем состояние
(
        defrule save_state_position
          (declare (salience 8))
          ?element<-(Puzzle_8 (Location ?loc) (Numeral ?number))
          ?st<-(state (flag_last NO) (Depth ?dpt) (visited_numerals $?nums))
          ?fd<-(final_depth (dpth ?dp))
          (not (test (member$ ?number ?nums)))
          =>
          (bind ?nums (delete$ ?nums ?loc ?loc))
          (bind ?nums (insert$ ?nums ?loc ?number))
          (modify ?st (visited_numerals ?nums))
          (modify ?fd (dpth ?dpt))
)

;; Эвакуируемся из тупика (если попали)
;; nth$ - возвращает конкретное поле по индексу CLIPS> (nth$ 3 (create$ a b c d e f g)) Return: c
(
        defrule evacuation
          (declare (salience -1))
          (exists (Puzzle_8 (Location ?loc) (Numeral ~?loc)))
          ?element1<-(Puzzle_8 (Location 1))
          ?element2<-(Puzzle_8 (Location 2))
          ?element3<-(Puzzle_8 (Location 3))
          ?element4<-(Puzzle_8 (Location 4))
          ?element5<-(Puzzle_8 (Location 5))
          ?element6<-(Puzzle_8 (Location 6))
          ?element7<-(Puzzle_8 (Location 7))
          ?element8<-(Puzzle_8 (Location 8))
          ?element9<-(Puzzle_8 (Location 9))
          ?last_state<-(state (Location ?x1) (Depth ?d1) (flag_last YES))
          ;; Предпоследнее состояние
          ?penultimate_state<-(state (Location ?x2) (Depth ?d2&:(= ?d2 (- ?d1 1))) (visited_numerals $?nums))
          =>
          (assert (state (Location (+ ?x1 1)) (Depth ?d2) (flag_last YES)))
          ;;(modify ?penultimate_state (flag_last YES))
          (modify ?last_state (Dead YES) (flag_last NO))
          (
            if (= (nth$ 1 ?nums) 9)
              then
              (modify ?element1 (isUsed NO) (Numeral (nth$ 1 ?nums)))
              else
              (modify ?element1 (isUsed YES) (Numeral (nth$ 1 ?nums)))
          )
          (
            if (= (nth$ 2 ?nums) 9)
              then
              (modify ?element2 (isUsed NO) (Numeral (nth$ 2 ?nums)))
              else
              (modify ?element2 (isUsed YES) (Numeral (nth$ 2 ?nums)))
          )
          (
            if (= (nth$ 3 ?nums) 9)
              then
              (modify ?element3 (isUsed NO) (Numeral (nth$ 3 ?nums)))
              else
              (modify ?element3 (isUsed YES) (Numeral (nth$ 3 ?nums)))
          )
          (
            if (= (nth$ 4 ?nums) 9)
              then
              (modify ?element4 (isUsed NO) (Numeral (nth$ 4 ?nums)))
              else
              (modify ?element4 (isUsed YES) (Numeral (nth$ 4 ?nums)))
          )
          (
            if (= (nth$ 5 ?nums) 9)
              then
              (modify ?element5 (isUsed NO) (Numeral (nth$ 5 ?nums)))
              else
              (modify ?element5 (isUsed YES) (Numeral (nth$ 5 ?nums)))
          )
          (
            if (= (nth$ 6 ?nums) 9)
              then
              (modify ?element6 (isUsed NO) (Numeral (nth$ 6 ?nums)))
              else
              (modify ?element6 (isUsed YES) (Numeral (nth$ 6 ?nums)))
          )
          (
            if (= (nth$ 7 ?nums) 9)
              then
              (modify ?element7 (isUsed NO) (Numeral (nth$ 7 ?nums)))
              else
              (modify ?element7 (isUsed YES) (Numeral (nth$ 7 ?nums)))
          )
          (
            if (= (nth$ 8 ?nums) 9)
              then
              (modify ?element8 (isUsed NO) (Numeral (nth$ 8 ?nums)))
              else
              (modify ?element8 (isUsed YES) (Numeral (nth$ 8 ?nums)))
          )
          (
            if (= (nth$ 9 ?nums) 9)
              then
              (modify ?element9 (isUsed NO) (Numeral (nth$ 9 ?nums)))
              else
              (modify ?element9 (isUsed YES) (Numeral (nth$ 9 ?nums)))
          )
          (retract ?penultimate_state)
)