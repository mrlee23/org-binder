(defun org-binder:snippet:gen-id ()
  (let ((years '(("2017") ("2018") ("2019")))
		(selected '(:year nil :category nil :section nil :project nil))
		)
	(plist-put selected :year (funcall org-binder:completing-read-function "Select years " years))
	(plist-put selected :category (org-binder:completing-read "Select category " org-binder:id))
	(plist-put selected :section (org-binder:completing-read "Select section " (org-binder:get-sub-data org-binder:id (plist-get selected :category))))
	(plist-put selected :project (funcall org-binder:completing-read-function "Insert project number " '()))
	(format "%sc%ss%sp%s"
			(plist-get selected :year)
			(plist-get selected :category)
			(plist-get selected :section)
			(plist-get selected :project))
	))

(defun org-binder:snippet:select-id ()
  (let* (c-read result gen-collection)
	(setq gen-collection
		  (lambda ()
			(mapcar (lambda (plist)
					  (let* ((id (plist-get plist :id))
							 (name (plist-get plist :name))
							 (names (org-binder:parse-to-name id))
							 ret-plist)
						(setq ret-plist
							  (plist-put ret-plist
										 :name (concat
												(propertize (format "%s>" (plist-get names :category)) 'face 'font-lock-comment-delimiter-face)
												(propertize (format "%s> " (plist-get names :section)) 'face 'font-lock-comment-face)
												(propertize (format "%s" name) 'face 'font-lock-keyword-face)
												(propertize (format " <%s>" id) 'face 'font-lock-comment-face)
												)))
						(setq ret-plist (plist-put ret-plist :id id))
						ret-plist))
					org-binder:full-id)))
	(setq c-read (lambda ()
				   (org-binder:completing-read "Select ID: "
											  (append (funcall gen-collection) `((:name ,(propertize "[Update ID]" 'face 'font-lock-builtin-face) :id 1))))))
	(setq result (funcall c-read))
	(cond
	 ((eq result 1)
	  (when (eq org-binder:completing-read-function 'my-yas:completing-read)
		(my-ext:yas:init-completing-read))
	  (setq org-binder:full-id (org-binder:gen-full-id))
	  (setq result (funcall c-read))))
	result))
