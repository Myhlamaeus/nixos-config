# -*- mode: snippet -*-
#name : FormattedMessage
#key : FormattedMessage
#contributor :
# --
<FormattedMessage
  id="`(string-inflection-camelcase-function (file-name-base (directory-file-name (file-name-directory (directory-file-name (file-name-directory (directory-file-name (file-name-directory (directory-file-name (file-name-directory (buffer-file-name)))))))))))`.`(file-name-base (directory-file-name (file-name-directory (directory-file-name (file-name-directory (buffer-file-name))))))`.`(file-name-base)`.$1"
  defaultMessage="$2"
/>
