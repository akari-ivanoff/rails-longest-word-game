require 'open-uri'
require 'json'

class GamesController < ApplicationController
  @@grid = []

  def new
    # @letters = Array.new(grid_size) { ('A'..'Z').to_a.sample }.join(" | ")
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @@grid = @letters
    @@start_time = Time.now
  end

  def score
    @attempt = params[:word]
    @end_time = Time.now
    @result = run_game(@attempt, @@grid, @@start_time, @end_time)
  end
end

def validate_api(attempt)
  url = 'https://wagon-dictionary.herokuapp.com/'
  api_validation = JSON.parse(open(url + attempt).read)
  return api_validation['found']
end

def validate_grid(attempt, grid)
  return attempt.chars.all? { |char| attempt.count(char) <= grid.count(char) }
end

def compute_score(attempt, grid, time)
  char_result = attempt.size.fdiv(grid.size) * 50
  time_result = (60 - time) * 1
  return char_result + time_result
end

def generate_results(attempt, grid, time)
  return [0, "word is not in the grid"] unless validate_grid(attempt, grid)
  if validate_api(attempt)
    return [compute_score(attempt, grid, time), "well done"]
  else
    return [0, "this is not an english word"]
  end
end

def run_game(attempt, grid, start_time, end_time)
  attempt.upcase!

  time = end_time - start_time
  results_hash = { time: time }
  results = generate_results(attempt, grid, time)
  results_hash[:score] = results.first
  results_hash[:message] = results.last
  return results_hash
end