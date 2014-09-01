require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'


# User views a list of recipies:
# Visiting /recipies will show a list of recipies sorted alphbetically by name.
# Each recipie name is a link to the details page for the recipie

# User views a recipie page:
# Visiting /recipie/:id will show the details for the given recipie.
# This page should contain the recipie title, ingredients, description, and instructions

#####################################
              # METHODS
#####################################

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)

  ensure
    connection.close
  end
end


#####################################
              # ROUTES
#####################################
get '/recipes' do
  query = 'SELECT * FROM recipes
  ORDER BY name;'
  db_connection do |conn|
    @recipes = conn.exec(query).to_a
  end
erb :'recipes/index'
end


get '/recipes/:id' do
  id = params[:id]
  query = 'SELECT recipes.id, recipes.name as recipes, recipes.instructions, recipes.description, ingredients.name as ingredients
  FROM recipes
  JOIN ingredients ON recipes.id = ingredients.recipe_id
  WHERE recipes.id = $1;'
  db_connection do |conn|
    @details = conn.exec_params(query, [id]).to_a
  end
erb :'recipes/show'
end




