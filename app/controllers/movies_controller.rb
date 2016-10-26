class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date, :sorting_by)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
redirect = false
    redirect_options = {}
    if params.has_key?('ratings')
      session.delete(:ratings)
      session[:ratings] = params[:ratings]
    else
      redirect = true if session.has_key?(:ratings)
      redirect_options.store(:ratings, session[:ratings]) if session.has_key?(:ratings)
    end
    if params.has_key?('sorting_by')
      session.delete(:sorting_by)
      session[:sorting_by] = params[:sorting_by] 
    end
    flash.keep if redirect
    redirect_to movies_path(redirect_options) if redirect

    movie_ratings = Movie.get_ratings 
    @all_ratings, selection = ApplicationHelper.get_selection(movie_ratings, session)
    if session.has_key?(:sorting_by)
      @css_class = ApplicationHelper.get_index_th_css_class(session)
      @movies = Movie.where(rating: selection).order(session[:sorting_by])
    else
      @css_class = ApplicationHelper.get_index_th_css_class({})
      @movies = Movie.where(rating: selection)
    end
    end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
