(defun org-binder:macro:arg-trim (arg)
  (when (stringp arg)
	(setq arg (string-trim arg))
	(when (equal arg "t")
	  (setq arg t))
	(when (equal arg "")
	  (setq arg nil)))
  arg
  )
(defun org-binder:macro:link-id (id &optional name)
  (setq id (org-binder:macro:arg-trim id)
		name (org-binder:macro:arg-trim name))
  (let ((cur-path (file-name-directory buffer-file-name))
		(path (org-binder:get-base-path id))
		(full-name (org-binder:get-full-name id))
		)
	(setq path (file-relative-name path cur-path))
	(when (or (eq name t) (equal name "t"))
	  (setq name full-name))
	(unless (stringp name)
	  (setq name (format "<%s>" id)))
	(while (string-match "[\\[\\]]*" name)
	  (setq name (replace-regexp-in-string "[\\[\\]]*" (lambda (s)
														 "") name)))
	(setq name (string-trim name))
	(format "[[./%s::#%s][%s]]" path id name)
	))

(defun org-binder:macro:html (filename)
  (setq filename (org-binder:macro:arg-trim filename))
  (let ((basedir org-binder:base-dir)
        html-path
		html-data)
    (setq html-path (file-relative-name (expand-file-name filename basedir) (file-name-directory buffer-file-name)))
	(with-temp-buffer
	  (insert-file-contents html-path)
	  (setq html-data (buffer-substring-no-properties 1 (point-max))))
	(format "\n#+BEGIN_EXPORT html
%s
\n#+END_EXPORT" html-data))
  )

(defun org-binder:macro:css (filename)
  (setq filename (org-binder:macro:arg-trim filename))
  (let ((basedir org-binder:base-dir)
        css-path)
    (setq css-path (file-relative-name (expand-file-name filename basedir) (file-name-directory buffer-file-name)))
    (format "\n#+HTML_HEAD: <link href=\"%s\" rel=\"stylesheet\" type=\"text/css\" />" css-path)
    ))
(defun org-binder:macro:css-stack (name filename)
  (setq name (org-binder:macro:arg-trim name)
		filename (org-binder:macro:arg-trim filename))
  (let ((basedir org-binder:base-dir)
        css-path)
    (setq css-path (file-relative-name (expand-file-name filename basedir) (file-name-directory buffer-file-name)))
    (concat "\n#+HTML_HEAD: " (replace-regexp-in-string "\n" " " (format "<script type=\"text/javascript\">
if (window['%s'] === undefined) {
 window['%s'] = {};
}
if (window['%s'].css === undefined) {
 window['%s']['css'] = {};
}
if (!Array.isArray(window['%s'].css['%s'])) {
 window['%s'].css['%s'] = [];
}
window['%s'].css['%s'].push('%s');
</script>" org-binder:name
org-binder:name
org-binder:name
org-binder:name
org-binder:name name
org-binder:name name
org-binder:name name css-path)))
    ))

(defun org-binder:macro:js (filename)
  (setq filename (org-binder:macro:arg-trim filename))
  (let ((basedir org-binder:base-dir)
        js-path)
    (setq js-path (file-relative-name (expand-file-name filename basedir) (file-name-directory buffer-file-name)))
    (format "\n#+HTML_HEAD: <script type=\"text/javascript\" src=\"%s\"></script>" js-path)
    ))
(defun org-binder:macro:js-stack (name filename)
  (setq name (org-binder:macro:arg-trim name)
		filename (org-binder:macro:arg-trim filename))
  (let ((basedir org-binder:base-dir)
        js-path)
    (setq js-path (file-relative-name (expand-file-name filename basedir) (file-name-directory buffer-file-name)))
    (concat "\n#+HTML_HEAD: " (replace-regexp-in-string "\n" " " (format "<script type=\"text/javascript\">
if (window['%s'] === undefined) {
 window['%s'] = {};
}
if (window['%s'].js === undefined) {
 window['%s']['js'] = {};
}
if (!Array.isArray(window['%s'].js['%s'])) {
 window['%s'].js['%s'] = [];
}
window['%s'].js['%s'].push('%s');
</script>" org-binder:name
org-binder:name
org-binder:name
org-binder:name
org-binder:name name
org-binder:name name
org-binder:name name js-path)))
    ))
