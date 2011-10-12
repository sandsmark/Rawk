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
});

function getAlbums(artist) {
  $.getJSON('cgi-bin/get-albums.pl?artist=' + artist, function(data) {
      var items = [];

      $.each(data, function(key, val) {
          items.push('<li id="' + key + '"><a href="javascript:getSongsForAlbum(' + val[0] + ')">' + val[1] + '</a></li>');
          });

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
          items.push('<li id="' + key + '"><a href="javascript:play(' + val[0] + ')">' + val[1] + '</a></li>');
          });

      $('<ul/>', {
          'class': 'my-new-list',
          html: items.join('')
          }).appendTo('#playlist');
      });
}
