var request;
var request_running = false;
var current_playlist;
var current_song;

$(document).ready(function() {
    request_running = true;

    request = $.getJSON('cgi-bin/get-songs.pl', function(data) {
            replace_playlist(data);
            request_running = false;
            });
  get_playlists();
});

function replace_artists(data) {
    $('#artists').remove();
    var items = [];

    $.each(data, function(key, val) {
            items.push('<li class="selectable"><a href="#artist=' + val[0] + '">' + val[1] + '</a></li>');
            });

    $('<ul/>', {
            'id': 'artists',
            html: items.join('')
            }).appendTo('#artistsbox');
}

function replace_playlist(data) {
    var items = [];

    $('.playlist').remove();
    current_playlist = [];
    $.each(data, function(song_id, val) {
            current_playlist.push(val['id']);
            var star_checked = "";
            if (val['starred'] == 1) {
                star_checked = "checked";
            }

            items.push('<tr class="selectable">' +
                '<td><input type="checkbox" onclick="javascript:star_song(' + val['id'] + ')" ' + star_checked + ' id="star_' + val['id'] + '" />' +
                '<a href="cgi-bin/get-song.pl?id=' + val['id'] + '" class="playable">' + val['title'] + '</a></td>' + 
                '<td><a href="#artist=' + val['artistid'] + '">' + val['artist'] + '</a></td>' +
                '<td><a href="#album=' + val['albumid'] + '">' + val['album'] + '</a></td>' +
                '</td>');
            });

    $('<table/>', {
            'class': 'playlist',
            html: items.join('')
            }).appendTo('#playlistcontainer');

    $('.playlist tr').draggable({
        appendTo: 'body',
        helper: 'clone'
    });
}

function star_song(song) {
    if ($('#star_' + song).is(":checked")) {
        request = $.getJSON('cgi-bin/star-song.pl?star=' + song, function(data) {
                $('#star_' + song).attr("checked", true);
                });
    } else {
        request = $.getJSON('cgi-bin/star-song.pl?unstar=' + song, function(data) {
                $('#star_' + song).attr("checked", false);
                });
    }
}

function get_playlists() {
  $.getJSON('cgi-bin/get-playlists.pl', function(data) {
      var items = [];

      $.each(data, function(listId, album) {
          items.push('<li class="selectable"><a href="#playlist=' + album[0] + '">' + album[1] + '</a></li>');
          });

      $('#playlists').remove();
      $('<ul/>', {
          'id': 'playlists',
          html: items.join('')
          }).appendTo('#playlistsbox');
      $('#playlists li').droppable({
        hoverClass: 'selectable-active',
        drop: function(event, ui) { 
                var song = ui.draggable.attr('song');
                var playlist = $(this).attr('playlist');
                $.get('cgi-bin/add-song-to-playlist.pl', {'song': song, 'playlist': playlist});
           }
      });
  });
}

function add_playlist() {
    $('#newplaylistinput').toggle();
}

function create_playlist() {
    $('#newplaylistinput').hide();
    var name = $('#newplaylistinput').val();
    $.get('cgi-bin/create-playlist.pl', 'name=' + name, function() {
            get_playlists();
    });
}

function do_search() {
    var query = $('#searchinput').val();
    location.hash = "#search=" + query;
}

$(function(){
        // Bind an event to window.onhashchange that, when the hash changes, gets the
        // hash and adds the class "selected" to any matching nav link.
        $(window).hashchange(function() {
            var query = location.hash.replace(/^#/, '');
            if (query == "") {
                request = $.getJSON('cgi-bin/get-songs.pl', function(data) {
                    replace_playlist(data);
                });
            }
            $.getJSON('cgi-bin/get-songs.pl?' + query, function(data) {
                replace_playlist(data);
                });

            // Iterate over all nav links, setting the "selected" class as-appropriate.
            $('#nav a').each(function(){
                var that = $(this);
                that[ that.attr( 'href' ) === hash ? 'addClass' : 'removeClass' ]( 'selected' );
                });
            })

        // Since the event is only triggered when the hash changes, we need to trigger
        // the event now, to handle the hash the page may have loaded with.
        $(window).hashchange();
});

