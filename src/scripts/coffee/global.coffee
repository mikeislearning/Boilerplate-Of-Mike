# Browserify entry point for the global.js bundle (yay CoffeeScript!)
View =  require './view'
Test =  require './test'
view = new View(el: '#content')
console.log 'global.js loaded!'

