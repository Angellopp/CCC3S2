class MoviesController < ApplicationController
  
  class TitleEmptyError < ArgumentError
  end

  class TitleFormatError < ArgumentError
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # Obtener todas las películas o filtrar por calificaciones seleccionadas
    @movies = Movie.all

    # Configurar las clasificaciones seleccionadas para que las casillas de verificación se muestren como marcadas
    @ratings_to_show = params[:ratings] || session[:ratings] || []

    # Obtenemos todas las clasificaciones posibles para construir las casillas de verificación
    @all_ratings = Movie.all_ratings

    # Verifica si queremos ver sin restricciones
    if params[:order].nil? && params[:ratings].nil?
      session[:ratings] = nil
      session[:order] = nil
    end

    # Verifica si se proporciona un orden y configura las variables de control
    if params[:order].nil? && !session[:order].nil?
        params[:order] = session[:order]
    elsif !params[:order].nil?
      @order_column = params[:order][:column]
      @order_direction = params[:order][:direction]
      @movies = @movies.order("#{@order_column} #{@order_direction}")
      session[:order] = params[:order]
    end
    
    # Filtramos las películas por clasificaciones seleccionadas
    if params[:ratings].nil? && !session[:ratings].nil?
        params[:ratings] = session[:ratings]
    elsif !params[:ratings].nil?
      selected_ratings = params[:ratings].keys
      @movies = @movies.with_ratings(selected_ratings)
      session[:ratings] = params[:ratings]
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    begin
      raise TitleEmptyError, "El titulo no puede estar vacío" if movie_params[:title].blank?
      raise TitleFormatError, "EL titulo no puede contener el caracter #" if movie_params[:title].include?("#")
      if (@movie = Movie.create!(movie_params))
        flash[:notice] = "#{@movie.title} was successfully created."
        redirect_to movies_path and return
      end
    rescue TitleEmptyError => e
      flash.now[:alert] = "EL titulo no puede estar vacío: #{e.message}"
      render :new and return
    rescue TitleFormatError => e
      flash.now[:alert] = "Formato incorrecto del titulo: #{e.message}"
      render :new and return
    rescue => e
      flash.now[:alert] = "La película no ha podido ser creada: #{e.message}"
      render :new and return
    end
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end


end
