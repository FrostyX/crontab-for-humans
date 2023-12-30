;; https://crontab.guru/


(defun cfh--is-number (value)
  (string-match-p "^[0-9]+$" value))

(defun cfh--is-range (value)
  (< 1 (length (split-string value "-"))))

(defun cfh--time (minute hour)
  (cond ((and (equal minute "*") (equal hour "*"))
         "every minute")

        ((equal hour "*")
         (let* ((split (split-string minute "-")))
           (if (= (length split) 1)
               (format "minute %s" minute)
             (format "every minute from %s through %s"
                     (elt split 0) (elt split 1)))))

        ((and (cfh--is-number minute) (cfh--is-number hour))
         (format
          "%s:%s"
          (format "%02d" (string-to-number hour))
          (format "%02d" (string-to-number minute))))

        (t
         (let* ((split (split-string hour "-")))
           (if (= (length split) 1)
               (format "every minute past hour %s" (elt split 0))
             (format "every minute past every hour from %s through %s"
                     (elt split 0) (elt split 1)))))))

(defun cfh--day-of-week (value)
  (if (equal value "*")
      nil
    (calendar-day-name
     (if (equal value "7") 0 (string-to-number value)) nil t)))

(defun cfh--day-of-month (value)
  (if (equal value "*")
      nil
    (format "day-of-month %s" value)))

(defun cfh--month (value)
  (if (equal value "*")
      nil
    (calendar-month-name (string-to-number value))))

(defun crontab-human-friendly (entry)
  ;; This should work
  ;; (print (transient-arg-value "--minute=" (transient-args 'crontab)))
  ;; (print (transient-args 'crontab))

  (let* ((split (split-string entry))
         (minute       (elt split 0))
         (hour         (elt split 1))
         (day-of-month (elt split 2))
         (month        (elt split 3))
         (day-of-week  (elt split 4)))

    ;; WIP
    (let* ((time (cfh--time minute hour))
           (day-of-week (cfh--day-of-week day-of-week))
           (month (cfh--month month))
           (day-of-month (cfh--day-of-month day-of-month)))

      ;; (format "At %s on %s." time day-of-week)

      (let* ((result "")
             (result (string-join (list result "At " time)))

             (result
              (if day-of-week
                  (string-join (list result " on " day-of-week))
                result))

             (result
              (if day-of-month
                  (string-join (list result " on " day-of-month))
                result))

             (result
              (if month
                  (string-join (list result " in " month))
                result))


             (result (string-join (list result "."))))

        result))))

(crontab-human-friendly "* * * * *")
(crontab-human-friendly "1 * * * *")
(crontab-human-friendly "5 4 * * 7")
(crontab-human-friendly "5 0 * 8 *")
(crontab-human-friendly "5 0 * 8 1")
(crontab-human-friendly "15 14 1 * *")


(defun cfh--save-to-clipboard (value)
  (with-temp-buffer
    (insert value)
    (clipboard-kill-region (point-min) (point-max))))

(defun cfh--crontab-string ()
  (string-join
   (list
    (cfh--get-value "--minute=")
    (cfh--get-value "--hour=")
    (cfh--get-value "--day-of-month=")
    (cfh--get-value "--month=")
    (cfh--get-value "--day-of-week="))
   " "))
