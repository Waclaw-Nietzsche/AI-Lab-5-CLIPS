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
)

(
      deftemplate final_depth
        (slot dpth (type INTEGER) (default 0))
)

(
      deffacts flagtemp
        (flag (f 0))
        (flag (ff 0))
        (final_depth (dpth 0))
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
      (Puzzle_8 (Location 1) (isUsed YES) (Numeral 4))
      (Puzzle_8 (Location 2) (isUsed YES) (Numeral 3))
      (Puzzle_8 (Location 3) (isUsed YES) (Numeral 1))
      (Puzzle_8 (Location 4) (isUsed YES) (Numeral 8))
      (Puzzle_8 (Location 5) (isUsed YES) (Numeral 2))
      (Puzzle_8 (Location 6) (isUsed YES) (Numeral 5))
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


(
      defrule backtracking
        (declare (salience 3))
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
        (declare (salience 4))
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
          ?fmove<-(flag (f ?fmeaning))
          ?from<-(Puzzle_8 (Location ?from_location) (isUsed YES) (Numeral ?number))
          ?to<-(Puzzle_8 (Location ?to_location) (isUsed NO) (Numeral ~?number))
          (Step_Of_Puzzle (from ?from_location) (to $?to_array&:(member$ ?to_location ?to_array)))
          ?st<-(state (flag_last YES) (Location ?state_location) (Depth ?dep) (visited_numerals $?some_nums))
          (test (= ?fmeaning 0))
          (
            forall 
              (state (Location 0) (Depth 0) (visited_numerals $?nums))
              (state (Location 0) (Depth 0) (visited_numerals $?some_nums)) 
          )
          =>
          (modify ?st 
            (flag_last NO)
          )
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
          (assert (state (flag_last YES) (Location (+ ?state_location 1)) (Depth (+ ?dep 1))))
)

;; Вычисляем эвристическую стоимость по критерию (количество фишек не на своих местах)
(
      defrule get_h_cost
        (declare (salience 2))
        ?st<-(state (flag_last YES) (visited_numerals $?nums))
        =>
        (bind ?temp (misplaced ?nums))
        (modify ?st (heuristic_cost ?temp))
)

(
      defrule find_best_cost
        (declare (salience 1))
        ?fd<-(final_depth (dpth ?dp))
        =>
        ;;printout((sort (find-all-facts ((?f Depth)) (eq ?f ?dp))))
)

;; replace$ - заменить в, начиная от, до, чем (мб несколько = участку от-до)
(
      defrule move
        ?fmove<-(flag (f ?fmeaning))
        ?from<-(Puzzle_8 (Location ?from_location) (isUsed YES) (Numeral ?number))
        ?to<-(Puzzle_8 (Location ?to_location) (isUsed NO) (Numeral ~?number))
        (Step_Of_Puzzle (from ?from_location) (to $?to_array&:(member$ ?to_location ?to_array)))
        ?st<-(state (flag_last YES) (Location ?state_location) (Depth ?dep) (heuristic_cost ?h) (visited_numerals $?some_nums))
        ;;(not (state (heuristic_cost ?hvalue&:(< ?hvalue ?h))))
        (test (< ?dep 50))
        (test (<> ?fmeaning 2))
        (test (member$ ?to_location $?to_array))
        (
          forall 
            (state (Location ~?state_location) (visited_numerals $?nums&~$?some_nums))
            (test (neq (replace$ (replace$ $?some_nums ?to_location ?to_location ?number) ?from_location ?from_location 9) $?nums))
        )
        =>
        (modify ?st 
          (flag_last NO)
        )
        (assert (state (flag_last YES) (Location (+ ?state_location 1)) (Depth (+ ?dep 1))))
        (modify ?from
          (isUsed NO)  
          (Numeral 9)
        )
        (modify ?to
          (isUsed YES) 
          (Numeral ?number)
        )
)

;; Сохраняем состояние
(
        defrule save_state_position
          (declare (salience 5))
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
          (modify ?last_state (flag_last NO))
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














































