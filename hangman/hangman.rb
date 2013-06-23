class Hangman

  MAX_TURNS = 10
  
  def initialize(guesser, referee)
    @guesser = guesser
    @referee = referee
  end

  def self.play_against_computer(dictionary)
  	Hangman.new(HumanPlayer.new, ComputerPlayer.new(dictionary))
  end

  def self.play_against_human(dictionary)
  	Hangman.new(ComputerPlayer.new(dictionary), HumanPlayer.new)
  end

  def play
  	@turn = 0

  	word_length = @referee.choose_word #choose word gives the secret word length

  	@guesser.register_word_length(word_length)

  	@board = [nil] * word_length
  	p @board
  	while @turn < MAX_TURNS

  	  take_turn

  	  if won?
  	  	p @board
  	  	puts "guesser wins!"
  	  	return
  	  end

  	  @turn += 1

  	end

  	puts "the secret word was #{@referee.reveal_word}"

  	puts "guesser loses!"

  	nil

  end

  def take_turn

  	guess = @guesser.guess_letter(@board.dup)

  	response = @referee.check_letter(guess)

  	update_board(guess, response)

  	@guesser.get_ready_for_next_guess(guess, response)

  end

  def update_board(guess, indices)
    indices.each do |index|
      @board[index] = guess
    end
  end

  def won?
    @board.all?
  end


end



class HumanPlayer

	def choose_word
		puts "how long is the secret word?"
		word_length = gets.chomp.to_i
	end

	def register_word_length(length)
		puts "the secret word is #{length} letters long"
	end

	def guess_letter(board)
		p board
		puts "guess a letter"
		letter = gets.chomp
	end

	def check_letter(letter)
		puts "the computer guessed #{letter}"
		puts "please enter the indices of that letter in your secret word"
		indices = gets.chomp.split(",").map(&:to_i)
	end

	def get_ready_for_next_guess(guess, response)
	end

	def reveal_word
		puts "what is the secret word?"
		word = gets.chomp
	end



end

class ComputerPlayer

	def initialize(dictionary)
		@possible_words = File.readlines(dictionary).map(&:chomp)
	end

	def choose_word
		@word = @possible_words.sample
		@word.length
	end

	def register_word_length(length)
		@possible_words.select! {|word| word.length == length}
	end

	def guess_letter(board)
		common_letters = find_common_letters(board)
		most_common_letters = common_letters.sort_by {|letter, freq| freq}
		letter, count = most_common_letters.last
		letter

	end

	def check_letter(letter)
    indices = []

    @word.split(//).each_with_index do |char, i|
      indices << i if char == letter
    end

    indices

	end


	def get_ready_for_next_guess(guess, response)
		@possible_words.delete_if do |word|
			should_delete = false
			word.split(//).each_with_index do |letter, index|
				if (letter == guess) && (!response.include?(index))
					should_delete = true
					break
				elsif (letter != guess) && (response.include?(index))
					should_delete = true
					break
				end
			end
			should_delete
		end

	end


	def find_common_letters(board)
		letter_frequencies = Hash.new(0)
		@possible_words.each do |word|
			board.each_with_index do |letter, index|
				letter_frequencies[word[index]] += 1 if letter.nil?
			end
		end
		letter_frequencies

	end

	def reveal_word
		@word
	end


end




