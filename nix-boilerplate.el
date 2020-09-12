;;; nix-boilerplate.el --- Scaffold Nix projects -*- lexical-binding: t -*-

;; Copyright (C) 2020 Akira Komamura

;; Author: Akira Komamura <akira.komamura@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "26.1") (dash "2.17") (dash-functional "1.2") (nix-mode "1.4") (async "1.9"))
;; Keywords: processes files tools
;; URL: https://github.com/akirak/nix-boilerplate

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This library provides a function for initializing a Nix project
;; from inside Emacs.

;; `nix-boilerplate-init' is the main entry point.

;;; Code:

(require 'nix)
(require 'dash)
(require 'async)
(require 'dash-functional)

(defgroup nix-boilerplate nil
  "Scaffold Nix projects."
  :group 'processes
  :group 'files
  :group 'tools)

(defcustom nix-boilerplate-source-repository
  "https://github.com/akirak/nix-boilerplate/archive/master.tar.gz"
  "URL of the source repository."
  :type 'string)

(defcustom nix-boilerplate-parent-directory nil
  "Parent directory selected when you run `nix-boilerplate-init'."
  :type 'directory)

(defcustom nix-boilerplate-init-hook
  '(nix-boilerplate-git-init
    nix-boilerplate-shell-with-immediate-exit
    nix-boilerplate-dired)
  "Hooks run after successfully scaffolding a project."
  :type 'hook)

(defcustom nix-boilerplate-rsync-options
  (list "-avl"
        "--ignore-existing"
        "--chmod=u+w")
  "List of options passed to rsync when copying source files."
  :type '(repeat string))

(defun nix-boilerplate-git-init ()
  "Initialize a Git repository.

To be used in `nix-boilerplate-init-hook'."
  (shell-command "git init"))

(defun nix-boilerplate-shell-with-immediate-exit ()
  "Run the Nix shell and immediately exit.

To be used in `nix-boilerplate-init-hook'."
  (shell-command "nix-shell --run exit"))

(defun nix-boilerplate-dired ()
  "Run dired after a certain delay.

To be used in `nix-boilerplate-init-hook'."
  (run-with-idle-timer 0.5 nil (-partial #'dired default-directory)))

(defun nix-boilerplate--copy-directory-contents (source dest)
  "Copy files in SOURCE to DEST."
  (cl-labels ((as-directory (dir)
                            (file-name-as-directory (expand-file-name dir)))
              (shell-command-line (args)
                                  (mapconcat #'shell-quote-argument
                                             args " "))
              (on-finish (dir _process)
                         (message "nix-boilerplate: Copied to %s" dir)
                         (run-hooks 'nix-boilerplate-init-hook)))
    (let ((rsync-command-line (shell-command-line
                               `("rsync"
                                 ,@nix-boilerplate-rsync-options
                                 ,(as-directory source)
                                 ,(as-directory dest)))))
      (async-start-process "nix-boilerplate-rsync"
                           nix-shell-executable
                           (-partial #'on-finish dest)
                           "-p" "rsync" "--run" rsync-command-line))))

;;;###autoload
(defun nix-boilerplate-init (directory)
  "Initialize a Nix project in DIRECTORY."
  (interactive (list (read-directory-name "Directory: "
                                          nix-boilerplate-parent-directory)))
  (cl-labels ((on-build (directory process)
                        (with-current-buffer (process-buffer process)
                          (goto-char (point-max))
                          (beginning-of-line)
                          (unless (looking-at "^/nix/store/")
                            (beginning-of-line 0))
                          (unless (looking-at "^/nix/store/")
                            (error "Cannot find the Nix store path"))
                          (let ((src (buffer-substring (point) (line-end-position))))
                            (nix-boilerplate--copy-directory-contents
                             src directory))))
              (empty-directory-p (dir)
                                 (null (cl-set-difference (directory-files dir)
                                                          '("." "..")))))
    (cond
     ((file-directory-p directory)
      (unless (or (empty-directory-p directory)
                  (yes-or-no-p "%s already exists. Import files anyway?"))
        (user-error "Aborted")))
     ((file-exists-p directory)
      (user-error "Already exists and not a directory: %s" directory))
     (t
      (make-directory directory t)))
    ;; nix-build fails if it is run inside a Nix store, so override
    ;; the default directory to prevent the error.
    (let ((default-directory directory))
      (async-start-process "nix-boilerplate"
                           nix-build-executable
                           (-partial #'on-build directory)
                           "--no-out-link"
                           nix-boilerplate-source-repository))))

(provide 'nix-boilerplate)
;;; nix-boilerplate.el ends here

