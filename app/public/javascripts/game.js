function Quiz(callback) {
  
  var GENRES = [
         {
            "genreCode":"26265",
            "name":"Alternative Pop"
         },
         {
            "genreCode":"26341",
            "name":"Heavy Metal"
         },
         {
            "genreCode":"26345",
            "name":"Hip Hop"
         },
         {
            "genreCode":"26360",
            "name":"Italian"
         },
         {
            "genreCode":"26373",
            "name":"Latin-American"
         },
         {
            "genreCode":"26401",
            "name":"Pop"
         },
         {
            "genreCode":"26407",
            "name":"Punk"
         }
      ]
  
  var CANDIDATES_NUM = 5
  var TRACKS_NUM = 10
  var tracks, currentTrack, candidates = new Array()
  var genre = GENRES[Math.floor(Math.random()*GENRES.length)]
  
  var sortCandidates = function(a, b) { return a.name > b.name }
  
  $.getJSON('/home/tracks?genreCode=' + genre.genreCode + '&step=' + TRACKS_NUM, function(data) {
    tracks = data.response.tracks
    callback()
  })
  
  this.generate = function() {
    
    for (var i=0; i<CANDIDATES_NUM; i++) {
      var index = Math.floor(Math.random()*tracks.length)
      candidates.push(tracks[index])
      tracks.splice(index, 1)
    }
    
    currentTrack = candidates[Math.floor(Math.random()*candidates.length)]
    // console.log('Correct answer: ' + currentTrack.name)
    
    var result ='<div class="quiz">'
      result += '<div class="player">'
        result += '<h2>Guess the song in the genre: ' + genre.name + '</h2>'
        result += '<audio controls="controls" autoplay="autoplay"><source src="' + currentTrack.previewUrl + '" type="audio/mpeg" /></audio>'
      result += '</div>'
      result += '<div class="candidates">'
        for (var i=0; i<candidates.length; i++) {
          result += '<input type=radio onclick="quiz.answer()" name="quiz" value="' + candidates[i].name + '" /> ' + candidates[i].name + '<br />'
        }
      result += '</div>'
    result += '</div>'
    
    return result
    
  }
  
  this.answer = function() {
    var correctness = $('input:radio:checked').val() == currentTrack.name
	$('body').css('background-color', correctness ? '#0f0' : '#f00');
    var url = '/home/submitresult?result=' + (correctness ? 1 : 0)
	// console.log(url)
	$.getJSON(url, function(data) {
		document.location.reload()
    })
  }
}
