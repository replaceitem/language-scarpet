fs = require 'fs'

completions = []

module.exports =
  selector: '.source.scarpet, .source.scarpet'
  disableForSelector: '.source.scarpet .comment'
  filterSuggestions: true

  load: () ->
    console.log('loading')
    completions = @scanFactories()
    console.log(completions)
    @bindEvents()
    console.log('loaded')
  bindEvents: ->
    console.log('bind')
    atom.workspace.observeTextEditors (editor) =>
      console.log('observe')
      editor.onDidSave (event) =>
        console.log("save")
        if event.path.includes @suggestionDirectory()
          completions = @scanFactories()

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    ret = []
    if completions == undefined
      console.log('Undefined!')
    else
      for suggestion in completions
        if(prefix == '' || !firstCharsEqual(suggestion.displayText, prefix))
          continue
        ret.push(suggestion)
    ret

  scanFactories: () ->
    console.log("ScanFactories in #{@getRootDirectory()}#{@suggestionDirectory()}")
    try
      results = []
      for factory_file in fs.readdirSync("#{@getRootDirectory()}#{@suggestionDirectory()}")
        data = fs.readFileSync "#{@getRootDirectory()}#{@suggestionDirectory()}/#{factory_file}", 'utf8'
        data = data.split('\n')
        for keyword in data
          if keyword != ''
            results.push @buildFunctionSuggestion(keyword.replace(/(?:\r\n|\r|\n)/g, '');)
      results
    catch e
      console.error e

  getRootDirectory: () ->
    atom.packages.resolvePackagePath('language-scarpet')

  suggestionDirectory: ->
    "/spec/suggestions"

  buildFunctionSuggestion: (line) ->
    keyword = line.split(':')
    typeChar = keyword[0]
    name = keyword[1]
    if typeChar == 'f'
      typeString = 'function'
      snippetString = "#{name}(${1:})"
    if typeChar == 'v'
      typeString = 'variable'
      snippetString = name
    sug =
      displayText: name
      snippet: snippetString
      type: typeString
    sug

firstCharsEqual = (str1, str2) ->
  str1[0].toLowerCase() is str2[0].toLowerCase()
