var request;
var request_running = false;

$(document).ready(function() {
    request_running = true;
    request = $.getJSON('cgi-bin/get-artists.pl', function(data) {
            replace_artists(data);
            request_running = false;
            $('#artists').hide();
            });

  replace_playlist_with_album(427);
  get_playlists();
});

function replace_artists(data) {
    $('#artists').remove();
    var items = [];

    $.each(data, function(key, val) {
            items.push('<li class="selectable" id="artist' + key + '"><a href="javascript:replace_albums_for_artist(' + val[0] + ')">' + val[1] + '</a></li>');
            });

    $('<ul/>', {
            'id': 'artists',
            html: items.join('')
            }).appendTo('#artistsbox');
}

function replace_playlist(data) {
      var items = [];

      $.each(data, function(song_id, val) {
          items.push('<li id="' + song_id + '"><a href="cgi-bin/get-song.pl?id=' + val[0] + '" class="playable">' + val[1] + '</a></li>');
          });

      $('.playlist').remove();
      $('<ul/>', {
          'class': 'playlist',
          html: items.join('')
          }).appendTo('#playlistcontainer');
}

function get_playlists() {
  $.getJSON('cgi-bin/get-playlists.pl', function(data) {
      var items = [];

      $.each(data, function(listId, album) {
          items.push('<li class="selectable" id="playlist' + listId + '"><a href="javascript:replace_playlist_with_playlist(' + album[0] + ')">' + album[1] + '</a></li>');
          });

      $('#playlists').remove();
      $('<ul/>', {
          'id': 'playlists',
          html: items.join('')
          }).appendTo('#playlistsbox');
      });
}

function replace_albums_for_artist(artist) {
  $.getJSON('cgi-bin/get-albums.pl?artist=' + artist, function(data) {
      var items = [];

      $.each(data, function(listId, album) {
          items.push('<li class="selectable" id="artist' + listId + '"><a href="javascript:replace_playlist_with_album(' + album[0] + ')">' + album[1] + '</a></li>');
          });

      $('#albums').remove();
      $('<ul/>', {
          'id': 'albums',
          html: items.join('')
          }).appendTo('#albumsbox');
      });
}

function replace_playlist_with_playlist(playlist) {
  $.getJSON('cgi-bin/get-songs.pl?playlist=' + playlist, function(data) {
          replace_playlist(data);
      });
}

function replace_playlist_with_album(album) {
  $.getJSON('cgi-bin/get-songs.pl?album=' + album, function(data) {
          replace_playlist(data);
      });
}

function artist_search(event, form) {
    if (request_running) {
        request.abort();
    }

    request_running = true;
    var artist_string = $('#artistsearchinput').val();
    request = $.getJSON('cgi-bin/get-artists.pl?artist=' + artist_string, function(data) {
            replace_artists(data);
            request_running = false;
            });
}

