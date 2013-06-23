require 'set'

class WordChains

  def initialize(dictionary)
    @dictionary = dictionary
  end

  def get_dictionary
    @dictionary = File.readlines(@dictionary).map(&:chomp)

  end

  def refine_dictionary(word_length)
    @dictionary.select! {|word| word.length == word_length}
  end

  def find_chain(start_word, end_word, dictionary=@dictionary)
    get_dictionary


    word_length = start_word.length
    smaller_dict = refine_dictionary(word_length)
    smaller_dict.delete(start_word)
    smaller_dict = Set.new(smaller_dict)

    current_words = Set.new([start_word])

    word_pairs = {start_word => nil}

    until (word_pairs.has_key?(end_word)) || (current_words.empty?)
      new_words, new_words_path = find_new_words(current_words, smaller_dict)

      current_words = new_words
      word_pairs.merge!(new_words_path)

      smaller_dict -= new_words
    end

    build_chain(word_pairs, end_word)


  end

  def adjacent_words(word, dictionary=@dictionary)
    adjacent_words = []
    regexes = []
    word.length.times do |index|
      regex = word.dup

      regex.length.times do |i|
        if i == index
          regex[i] = '.'
        end
      end
      regexes << regex
    end

    regexes.each do |reg|
      dictionary.each do |new_word|
        if /#{reg}/ === new_word
          adjacent_words << new_word
        end
      end
    end

    adjacent_words
  end

  def find_new_words(initial_words, smaller_dict)
    new_words = Set.new
    new_words_path = {}

    initial_words.each do |word|
      adj_words = adjacent_words(word, smaller_dict)
      new_words += adj_words

      adj_words.each do |x|
        new_words_path[x] = word
      end

    end

    [new_words, new_words_path]


  end

  def build_chain(visited_words, word)
    return nil unless visited_words.has_key?(word)

    path = [word]

    until visited_words[path.last].nil?
      path << visited_words[path.last]
    end

    path.reverse

  end

end