(defvar org-binder:name "OrgBinder")
(defvar org-binder:base-dir
  (expand-file-name
   "../" (file-name-directory load-file-name)))

(defvar org-binder:current-dir
  (file-name-directory load-file-name))

(defvar org-binder:completing-read-function (if (fboundp 'my-yas:completing-read)
											   'my-yas:completing-read
											 'completing-read))
(defvar org-binder:id nil)

(setq org-binder:id
	  '((:id "0"
			 :name "Contents"
			 :path "contents"
			 :sub
			 ((:id "1" :name "Book" :path "Book")))
		(:id "1"
			 :name "Years Plan"
			 :path "years"
			 :sub
			 ((:id "1" :name "Evaluation" :path "Evaluation")
			  (:id "2" :name "Plan" :path "Plan")
			  (:id "3" :name "Project" :path "Project")
			  (:id "4" :name "Business" :path "Business")
			  (:id "5" :name "Study" :path "Study")
			  (:id "6" :name "Travel" :path "Travel")
			  (:id "7" :name "Things" :path "Things")
			  (:id "8" :name "People" :path "People")
			  (:id "9" :name "Place" :path "Place")
			  (:id "10" :name "Finance" :path "Finance")
			  (:id "11" :name "Self-Care" :path "Self-Care")
			  (:id "12" :name "Training" :path "Training")
			  ))
		(:id "2"
			 :name "Theme Plan"
			 :path "theme"
			 :sub
			 ((:id "1" :name "Home" :path "Home")
			  (:id "2" :name "Office" :path "Office")))
		(:id "3"
			 :name "Journal"
			 :path "theme"
			 :gen-path (lambda (data)
						 (expand-file-name
						  "README.org"
						  (expand-file-name
						   (plist-get data :section)
						   (expand-file-name
							(plist-get data :category)
							org-binder:base-dir))))
			 :sub
			 ((:id "1" :name "Diary" :path "Diary")
			  (:id "2" :name "Dream" :path "Dream")
			  (:id "3" :name "Feeling" :path "Feeling")
			  (:id "4" :name "Future" :path "Future")
			  (:id "5" :name "Idea" :path "Idea")
			  (:id "6" :name "Project" :path "Project")
			  (:id "7" :name "Medical" :path "Medical")
			  (:id "8" :name "Money" :path "Money")))
		))

(defvar org-binder:full-id nil)

(defun org-binder:gen-collection (plist-seq &optional key plain reverse)
  (unless key
	(setq key :name))
  (mapcar (lambda (arg)
			(let* ((id (plist-get arg :id))
				   (name (plist-get arg key))
				   (id-prop-p (text-properties-at 0 (format "%s" id)))
				   (name-prop-p (text-properties-at 0 (format "%s" name)))
				  tmp)
			  (when reverse
				(setq tmp id
					  id name
					  name tmp))
			  (if plain
				  `(,name . ,id)
				(if (eq org-binder:completing-read-function
						'my-yas:completing-read)
					`(,(if name-prop-p (format "%s " name) (propertize (format "<%s> " name) 'face 'font-lock-keyword-face)) . ,id)
				  `(,(concat
					  (if name-prop-p name (propertize (format "%s" name) 'face 'font-lock-keyword-face))
					  " "
					  (if id-prop-p id (propertize (format "<%s>" id) 'face 'font-lock-comment-face)))
					. ,id)))
			))
		  plist-seq))

(defun org-binder:completing-read (prompt plist-seq)
  (let ((collection (org-binder:gen-collection plist-seq))
		)
	(if (eq org-binder:completing-read-function 'my-yas:completing-read)
		(cdr (assoc (funcall org-binder:completing-read-function prompt (mapcar '(lambda (arg) `(,(car arg))) collection)) collection))
	  (cdr (assoc (funcall org-binder:completing-read-function prompt collection) collection)))
	))

(defun org-binder:get-sub-data (plist-seq id)
  (car (remove nil
			   (mapcar (lambda (arg)
						 (when (equal (plist-get arg :id) id)
						   (plist-get arg :sub)))
					   plist-seq))))

(defun org-binder:gen-full-id ()
  (let ((data '())
		(files (directory-files-recursively org-binder:base-dir "[^\\(setup\\)].*\\.org$"))
		)
	(mapcar (lambda (filepath)
			  (with-temp-buffer
				(let (sp
					  (extract (lambda ()
								 (let (sp ep custom-id name)
								   (setq sp (search-forward "CUSTOM_ID:"))
								   (end-of-line)
								   (setq ep (point) p (point))
								   (setq custom-id (string-trim (buffer-substring-no-properties sp ep)))
								   (setq name (or (cdr (assoc "NAME" (org-entry-properties)))
												  (nth 4 (org-heading-components))))
								   ;; (setq sp (search-backward-regexp "^[*]+ "))
								   `(:name ,name :id ,custom-id :path ,(file-relative-name filepath org-binder:base-dir))
								   ))
							   ))
				  (unless (string-match "\\.#" (file-name-base filepath))
					(insert-file-contents filepath))
				  (org-mode)
				  (ignore-errors
					(while t
					  (push (funcall extract) data))
					)
				  )
				))
			files)
	data))
(setq org-binder:full-id (org-binder:gen-full-id))

(defun org-binder:parse-id (id)
  (let* ((data)
		 (stage 0)
		 key
		 )
	(unless (stringp id)
	  (error "ID is not a string type."))
	(setq data (plist-put data :year (substring id 0 4)))
	(setq id (substring id 4))
	(setq stage (1+ stage))
	(mapcar (lambda (char)
			  (cond
			   ((eq char 99) ; c for category
				(setq key :category)
				(setq stage (1+ stage))
				)
			   ((eq char 115) ;s for section, subproject
				(if (eq stage 2)
					(setq key :section)
				  (setq key :subproject))
				(setq stage (1+ stage))
				)
			   ((eq char 112) ;p for project
				(setq key :project)
				(setq stage (1+ stage))
				)
			   (t
				(setq data (plist-put data key (concat (plist-get data key) (char-to-string char))))
				))
			  )
			id)
	data
	))

(defun org-binder:parse-to-name (id)
  (let ((data (org-binder:parse-id id))
		)
	(plist-put data :section
			   (cdr (assoc (plist-get data :section)
						   (org-binder:gen-collection (org-binder:get-sub-data org-binder:id (plist-get data :category)) nil t t))))
	(plist-put data :category
			   (cdr (assoc (plist-get data :category)
						   (org-binder:gen-collection org-binder:id nil t t))))
	
	data
	))

(defun org-binder:parse-to-path (id)
  (let ((data (org-binder:parse-id id))
		)
	(plist-put data :section
			   (cdr (assoc (plist-get data :section)
						   (org-binder:gen-collection (org-binder:get-sub-data org-binder:id (plist-get data :category)) :path t t))))
	(plist-put data :generator
			   (cdr (assoc (plist-get data :category)
						   (org-binder:gen-collection org-binder:id :gen-path t t))))
	(plist-put data :category
			   (cdr (assoc (plist-get data :category)
						   (org-binder:gen-collection org-binder:id :path t t))))
	(plist-put data :path
			   (cdr (assoc id
						   (org-binder:gen-collection org-binder:full-id :path t t))))
	data
	))

(defun org-binder:get-base-path (id)
  (let ((data (org-binder:parse-to-path id))
		func path
		)
	(setq func (plist-get data :generator))
	(setq path (if (functionp func)
				   (funcall func data)
				 (plist-get data :path)))
	(expand-file-name path org-binder:base-dir)
	))

(defun org-binder:get-full-name (id)
  (cdr (assoc id (org-binder:gen-collection org-binder:full-id nil t t))))
