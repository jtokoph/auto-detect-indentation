# Auto Detect Indentation for atom

Automatically detect indentation of opened files. It looks at each opened file and sets file specific tab settings (hard/soft tabs, tab length) based on the content of the file instead of always using the editor defaults.

You might have atom configured to use 4 spaces for tabs but open a rails project which defaults to 2 spaces. Without this package, you would have to change your tabstop settings globally or risk having inconsistent lead spacing in your files.

## Keymap

To add a keyboard shortcut for the indentation selector menu, use the `indentation-seletor:show` command. Here's an example:

**keymaps.cson**

```cson
'atom-text-editor':
  'ctrl-I': 'indentation-selector:show'
```

## Configuring indentation

You can add `auto-detect-indentation.indentationTypes` to your `config.cson` file to change the types of indentation available in the indent selector menu. Here's an example:

**config.cson**

```cson
"auto-detect-indentation":
  indentationTypes: [
    {
      name: "Best Indent"
      softTabs: true
      tabLength: 16
    }
  ]
```

## TODO

* Use some sort of calculation (frequency, average, gcd) to figure out the most frequent tab setting in a file (currently gets smallest tab in first 100 lines)
* Waiting on event to listen for when a newly opened file has been parsed so we can depend on `editor.isBufferRowCommented`

[![Build Status](https://travis-ci.org/jtokoph/auto-detect-indentation.svg?branch=master)](https://travis-ci.org/jtokoph/auto-detect-indentation)

# Special Thanks To Contributors

[François Galea](https://github.com/fgalea)
