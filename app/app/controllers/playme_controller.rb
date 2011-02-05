class PlaymeController < ApplicationController
  @@playme_apikey = "4c3131495653414882"
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

  def tracks
    tracks = Typhoeus::Request.get("http://api.playme.com/genre.getTracks",
                                :method => :get,
                                :params => {
      :apikey => @@playme_apikey,
      :step => 100,
      :format => "json",
      :genreCode => GENRES.sample['genreCode']
    })

    arr_tracks = ActiveSupport::JSON.decode(tracks.body) #['tracks'].sample(@@tracks_num)
    samples = arr_tracks['response']['tracks'].sample(@@tracks_num)
    selected = samples.sample

    resp = []
    resp.push(samples.map {|s| s['name']})
    resp.push(selected)

    render :json => resp.to_json
  end
end
