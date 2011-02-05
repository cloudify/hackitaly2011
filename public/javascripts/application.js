jQuery.fn.identify = function() {
  var i = 0;
  return this.each(function() {
    do { i++; var id = $(this).attr('id').replace(/\d/, i); } while($("#" + id).length > 0);
    $(this).attr("id", id);
    if ( name = $(this).attr("name") ) { $(this).attr("name", name.replace(/\d/, i)); }
  });
};

$('div').live('pageshow', function( ) {
  $('play').identify();
});