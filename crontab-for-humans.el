;; https://crontab.guru/

;; Great demo for transient
;; https://github.com/positron-solutions/transient-showcase/blob/master/transient-showcase.el
;;
;; (use-package transient-showcase
;;   :quelpa (transient-showcase
;;            :fetcher github
;;            :repo "positron-solutions/transient-showcase"))


;; TODO Theese need custom reader. It needs to allow *, -, /, and comma.

(transient-define-argument crontab:--minute ()
  :description "Minute"
  :class 'transient-option
  :key "-m"
  :argument "--minute="
  :reader #'transient-read-number-N0)

(transient-define-argument crontab:--hour ()
  :description "Hour"
  :class 'transient-option
  :key "-h"
  :argument "--hour="
  :reader #'transient-read-number-N0)

(transient-define-argument crontab:--day-of-month ()
  :description "Day of month"
  :class 'transient-option
  :key "-d"
  :argument "--day-of-month="
  :reader #'transient-read-number-N0)

(transient-define-argument crontab:--month ()
  :description "Month"
  :class 'transient-option
  :key "-M"
  :argument "--month="
  :reader #'transient-read-number-N0)

(transient-define-argument crontab:--day-of-week ()
  :description "Day of week"
  :class 'transient-option
  :key "-D"
  :argument "--day-of-week="
  :reader #'transient-read-number-N0)

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


(transient-define-suffix cfh--explain (&optional args)
  :transient t
  (interactive)
  (message
   (crontab-human-friendly
    (string-join (list
                  (cfh--value "--minute=" )
                  (cfh--value "--hour=" )
                  (cfh--value "--day-of-month=" )
                  (cfh--value "--month=" )
                  (cfh--value "--day-of-week=" ))
                 " "))))

(defun cfh--value (arg)
  (or (transient-arg-value arg (transient-args 'crontab)) "*"))

(transient-define-prefix crontab ()
  [ :description
    "Crontab For Humans"

    ["Custom"
     (crontab:--minute)
     (crontab:--hour)
     (crontab:--day-of-month)
     (crontab:--month)
     (crontab:--day-of-week)]
    ["Preconfigured (non-standard)"
     ("@y" "Yearly" customize-group)
     ("@a" "Annually" customize-option)
     ("@m" "Monthly" customize-option)
     ("@w" "Weekly" customize-face)
     ("@d" "Daily" customize-face)
     ("@h" "Hourly" customize-face)
     ("@r" "Reboot" customize-face)]

    ["Actions"
     ("e" "Explain" cfh--explain)
     ;; TODO Generate random values
     ;; TODO Copy the string to clipboard
     ;; TODO Write to buffer
     ]])
