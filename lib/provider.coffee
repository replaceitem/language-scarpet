fs = require 'fs'

completions = []

module.exports =
  selector: '.source.scarpet, .source.scarpet'
  disableForSelector: '.source.scarpet .comment'
  filterSuggestions: true

  load: () ->
    completions = @scanFactories()
  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    ret = []
    for suggestion in completions
      if(prefix == '' || !firstCharsEqual(suggestion.displayText, prefix))
        continue
      ret.push(suggestion)
    ret

  scanFactories: () ->
    try
      results = []
      for factory_file in fs.readdirSync("#{@getRootDirectory()}\\spec\\suggestions")
        data = fs.readFileSync "#{@getRootDirectory()}\\spec\\suggestions\\#{factory_file}", 'utf8'
        data = data.split('\n')
        for keyword in data
          if keyword != ''
            results.push @buildFunctionSuggestion(keyword.replace(/(?:\r\n|\r|\n)/g, '');)
      results
    catch e

  getRootDirectory: () ->
    atom.project.rootDirectories[0].path;

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
