import React from "react"
import { ${1:`(file-name-sans-extension (file-name-base))`}, $1Props } from "./$1"

export default {
  title: "${6:`(file-name-nondirectory (directory-file-name (file-name-directory (directory-file-name (file-name-directory (buffer-file-name))))))`}/$1",
  component: $1,
}

export const WithArgs = (props: $1Props) => <$1 {...props} />
WithArgs.args = { $2 } as $1Props
