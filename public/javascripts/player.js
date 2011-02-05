$(document).ready(function() {
  $('div').live('pageshow', function( ) {
    $(".player:last").jPlayer({
      ready: function( ) {
        $(this).jPlayer('setMedia', {
          mp3: $(".player:visible").data('mp3')
        }).jPlayer('play');
      },
      swfPath: '/flash',
      preload: 'auto',
      supplied: 'mp3'
    });
  });
});