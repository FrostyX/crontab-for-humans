;; Run the tests via `M-x ert' in Emacs
;;;
;; Or run them in the commandline:
;;     emacs -batch -l ert -l test-crontab.el -f  ert-run-tests-batch-and-exit


(let* ((parent (file-name-directory
               (directory-file-name
                (file-name-directory (buffer-file-name)))))
       (file "crontab-for-humans.el")
       (path (expand-file-name file parent)))
  (load-file path))


(ert-deftest test-time ()
  (should (equal (cfh--time "*" "*") "every minute"))
  (should (equal (cfh--time "1" "*") "minute 1"))
  (should (equal (cfh--time "5" "4") "04:05"))
  (should (equal (cfh--time "*" "3") "every minute past hour 3"))
  (should (equal (cfh--time "1-5" "*") "every minute from 1 through 5"))
  (should (equal (cfh--time "*" "3-4")
                 "every minute past every hour from 3 through 4"))
  (should (equal (cfh--time "1-5" "3-4")
                 "every minute from 1 through 5 past every hour from 3 through 4")))

(ert-deftest test-day-of-week ()
  (should (equal (cfh--day-of-week "*") nil))
  (should (equal (cfh--day-of-week "2") "Tuesday"))
  (should (equal (cfh--day-of-week "7") "Sunday")))

(ert-deftest test-day-of-month ()
  (should (equal (cfh--day-of-month "*") nil))
  (should (equal (cfh--day-of-month "5") "day-of-month 5")))

(ert-deftest test-month ()
  (should (equal (cfh--month "*") nil))
  (should (equal (cfh--month "8") "August")))

(ert-deftest test-human-friendly-simple ()
  (should (equal (crontab-human-friendly "* * * * *")
                 "At every minute."))

  (should (equal (crontab-human-friendly "1 * * * *")
                 "At minute 1."))

  (should (equal (crontab-human-friendly "5 4 * * 7")
                 "At 04:05 on Sunday."))

  (should (equal (crontab-human-friendly "5 0 * 8 *")
                 "At 00:05 in August."))

  (should (equal (crontab-human-friendly "5 0 * 8 1")
                 "At 00:05 on Monday in August."))

  (should (equal (crontab-human-friendly "15 14 1 * *")
                 "At 14:15 on day-of-month 1.")))


(ert-deftest test-human-friendly-advanced ()
  (should (equal (crontab-human-friendly "0 22 * * 1-5")
                 "At 22:00 on every day-of-week from Monday through Friday."))

  (should (equal (crontab-human-friendly "23 0-20/2 * * *")
                 "At minute 23 past every 2nd hour from 0 through 20."))

  (should (equal (crontab-human-friendly "0 0,12 1 */2 *")
                 "At minute 0 past hour 0 and 12 on day-of-month 1 in every 2nd month."))

  (should (equal (crontab-human-friendly "0 4 8-14 * *")
                 "At 04:00 on every day-of-month from 8 through 14."))

  (should (equal (crontab-human-friendly "0 0 1,15 * 3")
                 "At 00:00 on day-of-month 1 and 15 and on Wednesday."))

  (should (equal (crontab-human-friendly "@weekly")
                 "At 00:00 on Sunday."))

  (should (equal (crontab-human-friendly "0 22 * * 1-5")
                 "At 22:00 on every day-of-week from Monday through Friday."))

  (should (equal (crontab-human-friendly "23 0-20/2 * * *")
                 "At minute 23 past every 2nd hour from 0 through 20.")))
