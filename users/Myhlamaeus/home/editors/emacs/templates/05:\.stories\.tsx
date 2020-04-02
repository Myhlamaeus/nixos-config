import { h } from "preact"
import { $3 } from "@storybook/addon-knobs"

import { ${1:`(file-name-sans-extension (file-name-base))`} } from "./$1"

export default { title: "${6:`(file-name-nondirectory (directory-file-name (file-name-directory (directory-file-name (file-name-directory (buffer-file-name))))))`}/$1" }

export const ${2:`(string-inflection-camelcase-function (file-name-sans-extension (file-name-base)))`} = () => (
  <$1 $4>
    $5
  </$1>
)
