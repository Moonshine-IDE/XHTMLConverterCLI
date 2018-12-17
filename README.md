# XHTMLConverterCLI
Desktop application to convert nsf-xml file to PrimeFaces xHTML over CLI

## CLI Arguments
Standard commands for both Unix and Windows platforms
- `--publish-to-primefaces`: Followed by source .xml file path and destination .xhtml file path

### Example On Windows
Sending command to convert nsf-xml to xhtml

```
"c:\Program Files (x86)\XHTMLConverterCLI\XHTMLConverterCLI.exe" --publish-to-primefaces "path-to-source-nsf-file.xml" "path-to-destination-nsf-file.xhtml"
```

### Example On Unix
Sending command to convert nsf-xml to xhtml

```
open -a '\Applications\XHTMLConverterCLI.app' --args --publish-to-primefaces 'path-to-source-nsf-file.xml' 'path-to-destination-nsf-file.xhtml'
```
Another option on Unix is as follows, this shall work as long as we keep the executable non-sandbox:
```
'\Applications\XHTMLConverterCLI.app\Contents\MacOS\XHTMLConverterCLI' --publish-to-primefaces 'path-to-source-nsf-file.xml' 'path-to-destination-nsf-file.xhtml'
```