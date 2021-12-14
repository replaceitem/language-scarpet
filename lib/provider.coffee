fs = require 'fs'

completions = []

module.exports =
  selector: '.source.scarpet, .source.scarpet'
  disableForSelector: '.source.scarpet .comment'
  filterSuggestions: true

  load: () ->
    completions = @scanFactories()
    @bindEvents()
  bindEvents: ->
    atom.workspace.observeTextEditors (editor) =>
      editor.onDidSave (event) =>
        if event.path.includes @suggestionDirectory()
          completions = @scanFactories()

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    ret = []
    if completions == undefined
        console.error('Could not find autocompletions')
    else
      for suggestion in completions
        if(prefix == '' || !firstCharsEqual(suggestion.displayText, prefix))
          continue
        ret.push(suggestion)
    ret

  scanFactories: () ->
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
    typeString = keyword[0]
    name = keyword[1]
    if typeString == 'function' || typeString == 'method'
      snippetString = "#{name}(${1:})"
    else
      snippetString = name
    sug =
      displayText: name
      snippet: snippetString
      type: typeString
      description: 'For help, see the scarpet documentation:'
      descriptionMoreURL: 'https://github.com/gnembon/fabric-carpet/blob/master/docs/scarpet/Full.md'
    sug

firstCharsEqual = (str1, str2) ->
  str1[0].toLowerCase() is str2[0].toLowerCase()
