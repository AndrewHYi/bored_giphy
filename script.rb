require_relative "lib/meat"



# Giphy.rando('cat', 'man', 'do')
# Giphy.search('cat', 'man', 'do')
# Giphy.rando(word_groups)
s = StoryMaker.new(filepath: "./test.txt")
s.compile!