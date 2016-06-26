;;; projectile-window.el --- Automatically save and restore projectile project window states.  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  James Orr

;; Author: James Orr <james@t420>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Use this package to automatically save and restore projectile project window state when switching projects.

;;; Code:

(defvar projectile-window-layouts (ht-create)
  "Maps projectile projects to window configurations.")

;;; Okay honestly this is more like the current project...
;;; the *future* prevoius project
(defvar projectile-window-project (projectile-project-name)
  "Usually, the current projectile project.  While switching projects, it will briefly be the previous project, which is why it exists.  Gotta get the previous project when switching projects in order to set its last window configuration.")

(defvar projectile-window-on nil
  "Is projectile-window-mode on?")

(defun projectile-window-save-layout ()
  "Save the current window layout to the layout map for project."
  (interactive)
  (ht-set! projectile-window-layouts projectile-window-project (current-window-configuration))
  (setq projectile-window-project (projectile-project-name)))

(defun projectile-window-restore-layout ()
  "While switching projects, save the current window state for the previous projectile project and load the new project's previously saved window state.  If there is no saved window state for the current project, run projectile-switch-project-action."
  (interactive)
  (let* ((layout (ht-get projectile-window-layouts (projectile-project-name))))
    (if layout
        (set-window-configuration layout))))

(define-minor-mode projectile-window-mode
  "Automatically save and restore projectile project window states."
  :lighter " projectile-window"
  :global 1
  (if projectile-window-on
      (progn
        (remove-hook 'projectile-after-switch-project-hook
                     #'projectile-window-restore-layout)
        (remove-hook 'projectile-before-switch-project-hook
                     #'projectile-window-save-layout)
        (setq projectile-window-on nil))
    (progn
      (add-hook 'projectile-after-switch-project-hook
                #'projectile-window-restore-layout)
      (add-hook 'projectile-before-switch-project-hook
                #'projectile-window-save-layout)
      (setq projectile-window-on t))))

(provide 'projectile-window)
;;; projectile-window.el ends here
