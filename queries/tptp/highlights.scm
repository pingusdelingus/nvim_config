

; Annotated Formula Wrappers 
(fof_annotated) @function.call
(cnf_annotated) @function.call
(annotated_formula) @function.call
; Names and Roles 
(name (atomic_word)) @variable.builtin
(formula_role) @keyword.type

; Connectives
(nonassoc_connective) @operator

; Atomic Elements 
(atomic_word) @variable

; Punctuation and Delimiters 
["(" ")"] @punctuation.bracket
["[" "]"] @punctuation.bracket
["," "."] @punctuation.delimiter

(comment) @comment
