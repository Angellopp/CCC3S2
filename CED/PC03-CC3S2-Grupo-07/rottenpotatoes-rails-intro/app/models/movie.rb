# app/models/movie.rb
class Movie < ActiveRecord::Base
  
  def self.with_ratings(ratings_list)
    return all if ratings_list.nil? || ratings_list.empty?

    where(rating: ratings_list)
  end

  def self.all_ratings
    # Devuelve un array con todas las clasificaciones posibles
    ['G', 'PG', 'PG-13', 'R']
  end
end

