function Quiz(callback) {
  
  var CANDIDATES_NUM = 5
  var TRACKS_NUM = 10
  var tracks, currentTrack, candidates = new Array()
  
  var sortCandidates = function(a, b) { return a.name > b.name }
  
  $.getJSON('proxy.php?op=3&apikey=4c3131495653414882&format=json&genreCode=26265&step=' + TRACKS_NUM, function(data) {
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
    console.log('Correct answer: ' + currentTrack.name)
    
    var result ='<div class="quiz">'
      result += '<audio controls="controls"><source src="' + currentTrack.previewUrl + '" type="audio/mpeg" /></audio>'
      result += '<div class="candidates">'
        for (var i=0; i<candidates.length; i++) {
          result += '<input type=radio name="quiz" value="' + candidates[i].name + '" /> ' + candidates[i].name + '<br />'
        }
        result += '<div class="buttonContainer"><button onclick="quiz.answer()">Answer</button></div>'
      result += '</div>'
    result += '</div>'
    
    return result
    
  }
  
  this.answer = function() {
    var correctness = $('input:radio:checked').val() == currentTrack.name
    console.log('answer: ' + correctness)
  }
  
}
