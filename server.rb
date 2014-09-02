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

def all_recipes
  query = 'SELECT * FROM recipes
  ORDER BY name;'

  recipes = db_connection do |conn|
    conn.exec(query)
  end

  recipes.to_a
end

def get_recipe_by(id)
  query = 'SELECT recipes.id, recipes.name as recipes, recipes.instructions, recipes.description, ingredients.name as ingredients
  FROM recipes
  JOIN ingredients ON recipes.id = ingredients.recipe_id
  WHERE recipes.id = $1;'

  recipe = db_connection do |conn|
    conn.exec_params(query, [id])
  end

  recipe.to_a
end

#####################################
              # ROUTES
#####################################
get '/recipes' do
  @recipes = all_recipes

  erb :'recipes/index'
end

get '/recipes/:id' do
  @details = get_recipe_by(params[:id])

  erb :'recipes/show'
end
