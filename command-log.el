;;; command-log.el --- Save executed command -*- lexical-binding: t -*-

;; Copyright (C) 2022 berquerant

;; Author: berquerant
;; Maintainer: berquerant
;; Created: 2 Apr 2022
;; Version: 0.1.0
;; Keywords: command log
;; URL: https://github.com/berquerant/emacs-command-log

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Please see README.md from the same repository for documentation.

;;; Code:

(defgroup command-log nil
  "Executed command log."
  :prefix "command-log-"
  :group 'command-log)

(defcustom command-log-histfile nil
  "Where the history is saved.
If nil, then the history is not saved.

The log format is:
  timestamp command repeated-count"
  :type 'file
  :version "29.50")

(defun command-log--enable? ()
  "Command log is enabled or not."
  command-log-histfile)

(defun command-log--current-timestamp ()
  "Return the current timestamp."
  (let ((now (current-time)))
    (+ (* (car now) (expt 2 16)) (cadr now))))

(defun command-log--command-repeated? ()
  "Current command is repeated or not."
  (eq last-command this-command))

(defvar command-log--command-repeated-count 1
  "Repeated count of the `last-command'.")

(defun command-log--clear-command-repeated-count ()
  (setq command-log--command-repeated-count 1))

(defun command-log--incr-command-repeated-count ()
  (setq command-log--command-repeated-count (+ 1 command-log--command-repeated-count)))

(defun command-log--update-command-repeated-count ()
  "Update `command-log--command-repeated-count'.
If return nil, then the current command is not repeated,
the count is not updated.
If return number, then the current command is repeated, the count is updated."
  (cond ((not last-command) -1)
        ((command-log--command-repeated?) (command-log--incr-command-repeated-count))
        (t nil)))

(defun command-log--append-history ()
  "Append the executed command to `command-log-histfile'.
The format of the histfile is:
  timestamp command repeated-count"
  (unless (command-log--update-command-repeated-count)
    (let ((msg (format "%d %s %d\n"
                       (command-log--current-timestamp)
                       last-command
                       command-log--command-repeated-count)))
      (write-region msg nil command-log-histfile t)
      (command-log--clear-command-repeated-count))))

(defun command-log--append-history-hook ()
  (when (command-log--enable?)
    (command-log--append-history)))

;;;###autoload
(defun command-log-setup ()
  "Setup command-log."
  (add-hook 'pre-command-hook 'command-log--append-history-hook))

(provide 'command-log)
;;; command-log.el ends here
