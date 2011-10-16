$(document).ready(function() {
  $.getJSON('cgi-bin/get-artists.pl', function(data) {
      var items = [];

      $.each(data, function(key, val) {
          items.push('<li id="' + key + '"><a href="javascript:getAlbums(' + val[0] + ')">' + val[1] + '</a></li>');
          });

      $('<ul/>', {
          'class': 'my-new-list',
          html: items.join('')
          }).appendTo('#artists');
      });
  getSongsForAlbum(427);
});

function getAlbums(artist) {
  $.getJSON('cgi-bin/get-albums.pl?artist=' + artist, function(data) {
      var items = [];

      $.each(data, function(key, val) {
          items.push('<li id="' + key + '"><a href="javascript:getSongsForAlbum(' + val[0] + ')">' + val[1] + '</a></li>');
          });

      $('#albums li').remove();
      $('<ul/>', {
          'class': 'my-new-list',
          html: items.join('')
          }).appendTo('#albums');
      });
}

function getSongsForAlbum(album) {
  $.getJSON('cgi-bin/get-songs.pl?album=' + album, function(data) {
      var items = [];

      $.each(data, function(key, val) {
          items.push('<li id="' + key + '"><a href="cgi-bin/get-song.pl?id=' + val[0] + '" class="playable">' + val[1] + '</a></li>');
          });

      $('.playlist li').remove();
      $('<ul/>', {
          'class': 'my-new-list',
          html: items.join('')
          }).appendTo('.playlist');
      });
}

function artist_search(event, form) {
    var key = event.keyCode || event.which;
//    if (key == 13) {
        var artist_string = $('#artistsearchinput').val();
        $('#artists li').remove();
        $.getJSON('cgi-bin/get-artists.pl?artist=' + artist_string, function(data) {
                var items = [];

                $.each(data, function(key, val) {
                    items.push('<li id="' + key + '"><a href="javascript:getAlbums(' + val[0] + ')">' + val[1] + '</a></li>');
                    });

                $('<ul/>', {
                    'class': 'my-new-list',
                    html: items.join('')
                    }).appendTo('#artists');
                });
  //  }

}
