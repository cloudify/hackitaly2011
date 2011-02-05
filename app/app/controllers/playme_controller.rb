class PlaymeController < ApplicationController
  @@tracks_num = 5

  GENRES = [
    {"genreCode"=>"26265", "name"=>"Alternative Pop" },
    {"genreCode"=>"26341", "name"=>"Heavy Metal"},
    {"genreCode"=>"26345", "name"=>"Hip Hop"},
    {"genreCode"=>"26360","name"=>"Italian"},
    {"genreCode"=>"26373", "name"=>"Latin-American"},
    {"genreCode"=>"26401", "name"=>"Pop"},
    {"genreCode"=>"26407", "name"=>"Punk" }
  ]

  def index
    tracks = Typhoeus::Request.get("http://api.playme.com/genre.getTracks",
                                :method => :get,
                                :params => {
      :apikey => $playme_apikey,
      :step => 100,
      :format => "json",
      :genreCode => GENRES.sample['genreCode']
    })

    arr_tracks = ActiveSupport::JSON.decode(tracks.body)
    samples = arr_tracks['response']['tracks'].sample(@@tracks_num)
    selected = samples.sample

    session[:right] = selected['trackCode']
    @mp3 = selected['previewUrl']
    @data = samples.map {|s| {:name => s['name'], :artist => s['artist']['name'], :image => s['images']['img_96']} }
  end


  def submitresult
    @guess = params[:result].to_i == session[:right]
    req = Typhoeus::Request.get("http://api.beintoo.com/api/rest/player/submitscore",
      :method        => :get,
      :headers       => {
        :apikey => $beintoo_apikey,
        :guid => session[:guid]
      },
      :params => {
        :lastScore => @guess ? 1 : -1
      })
    req = Typhoeus::Request.get("http://api.beintoo.com/api/rest/player/byguid/" + session[:guid].to_s,
      :method        => :get,
      :headers       => {
        :apikey => $beintoo_apikey
      })
      render :text => req.body
  end
end
