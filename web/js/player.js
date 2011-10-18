$(document).ready(function() {
  $.getJSON('cgi-bin/get-artists.pl', function(data) {
      var items = [];

      $.each(data, function(listId, artist) {
          items.push('<li class="selectable" id="' + listId + '"><a href="javascript:getAlbums(' + artist[0] + ')">' + artist[1] + '</a></li>');
          });

      $('<ul/>', {
          'id': 'artists',
          html: items.join('')
          }).appendTo('#artistsbox');
      });
  getSongsForAlbum(427);
});

function getAlbums(artist) {
  $.getJSON('cgi-bin/get-albums.pl?artist=' + artist, function(data) {
      var items = [];

      $.each(data, function(listId, album) {
          items.push('<li class="selectable" id="' + listId + '"><a href="javascript:getSongsForAlbum(' + album[0] + ')">' + album[1] + '</a></li>');
          });

      $('#albums').remove();
      $('<ul/>', {
          'id': 'albums',
          html: items.join('')
          }).appendTo('#albumsbox');
      });
}

function getSongsForAlbum(album) {
  $.getJSON('cgi-bin/get-songs.pl?album=' + album, function(data) {
      var items = [];

      $.each(data, function(song_id, val) {
          items.push('<li id="' + song_id + '"><a href="cgi-bin/get-song.pl?id=' + val[0] + '" class="playable">' + val[1] + '</a></li>');
          });

      $('.playlist').remove();
      $('<ul/>', {
          'class': 'playlist',
          html: items.join('')
          }).appendTo('#playlistcontainer');
      });
}

function artist_search(event, form) {
    var key = event.keyCode || event.which;
//    if (key == 13) {
        var artist_string = $('#artistsearchinput').val();
        $('#artists').remove();
        $.getJSON('cgi-bin/get-artists.pl?artist=' + artist_string, function(data) {
                var items = [];

                $.each(data, function(key, val) {
                    items.push('<li class="selectable" id="' + key + '"><a href="javascript:getAlbums(' + val[0] + ')">' + val[1] + '</a></li>');
                    });

                $('<ul/>', {
                    'id': 'artists',
                    html: items.join('')
                    }).appendTo('#artistsbox');
                });
  //  }

}
