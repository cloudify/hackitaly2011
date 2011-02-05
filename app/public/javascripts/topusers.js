$('div').live('pageshow', function(event,ui){
    $.getJSON('/home/gettopscores', function(data) {
      $('#top-users').html('');
      for(var i = 0; i < data.length; i++) {
        $('#top-users').append('<li>(' + data[i]['score'] +  ' points) ' + data[i]['entry']['guid']);
      }
    })
})