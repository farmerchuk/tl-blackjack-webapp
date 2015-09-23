$(document).ready(function() {

  $('div[class="container"]').hide(0);
  $('div[class="container"]').fadeIn();

  player_hit();
  player_stand();
  dealer_hit();

});

function player_hit() {
  $(document).on('click', 'form input[value="Hit"]', function() {
    $.ajax({
      type: 'post',
      url: '/game/player/hit'
    }).done(function(msg) {
      $('#game-panel').replaceWith(msg);
    });
    return false;
  });
};

function player_stand() {
  $(document).on('click', 'form input[value="Stay"]', function() {
    $.ajax({
      type: 'get',
      url: '/game/dealer'
    }).done(function(msg) {
      $('#game-panel').replaceWith(msg);
    });
    return false;
  });
};

function dealer_hit() {
  $(document).on('click', 'form input[value="Click to see the dealer\'s next card..."]', function() {
    $.ajax({
      type: 'post',
      url: '/game/dealer/hit'
    }).done(function(msg) {
      $('#game-panel').replaceWith(msg);
    });
    return false;
  });
};
