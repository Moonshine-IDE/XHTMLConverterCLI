# XHTMLConverterCLI
Desktop application to convert nsf file to PrimeFaces xHTML over CLI

## CLI Arguments
Standard commands for both Unix and Windows platforms
- `--publish-to-primefaces`: Followed by source .nsf file path and destination .xhtml file path

### Example On Windows
Sending command to convert nsf to xhtml

```
"c:\Program Files (x86)\XHTMLConverterCLI\XHTMLConverterCLI.exe" --publish-to-primefaces "path-to-source-nsf-file" "path-to-destination-nsf-file"
```

### Example On Unix
Sending command to convert nsf to xhtml

```
open -a '\Applications\XHTMLConverterCLI.app' --args --publish-to-primefaces 'path-to-source-nsf-file' 'path-to-destination-nsf-file'
```

#### Notes
On Unix, following usage is not suggested however this will work - once:
```
'\Applications\XHTMLConverterCLI.app' --publish-to-primefaces 'path-to-source-nsf-file' 'path-to-destination-nsf-file'
```
Above usage will not quit the application by itself when conversion is done.