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

(transient-define-suffix cfh--explain (&optional args)
  :transient t
  (interactive)
  (message (crontab-human-friendly (cfh--crontab-string))))

(transient-define-suffix cfh--clipboard (&optional args)
  (interactive)
  (cfh--save-to-clipboard (cfh--crontab-string)))

(transient-define-suffix cfh--insert ()
  (interactive)
  (insert (cfh--crontab-string)))

(defun cfh--get-value (arg)
  (or (transient-arg-value arg (transient-args 'crontab)) "*"))

(defun cfh--set-value (arg value)
  (error "Not implemented"))

(transient-define-suffix cfh--random ()
  :transient t
  (interactive)
  (progn
    (cfh--set-value "--minute=" "1")
    (cfh--set-value "--hour=" "2")
    (cfh--set-value "--day-of-month=" "3")
    (cfh--set-value "--month=" "4")
    (cfh--set-value "--day-of-week=" "5")))

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
     ("c" "Copy to clipboard" cfh--clipboard)
     ("i" "Insert to buffer" cfh--insert)
     ("R" "Generate random values" cfh--random)]])
