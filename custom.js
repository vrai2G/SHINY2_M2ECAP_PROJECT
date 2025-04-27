// custom.js - Scripts JavaScript personnalisés pour l'application Shiny

$(document).ready(function() {
  // Gestion des erreurs API
  Shiny.addCustomMessageHandler('api_error', function(message) {
    $('#api-error-modal').modal('show');
    $('#error-message').text(message);
  });

  // Animation lors du chargement
  Shiny.addCustomMessageHandler('toggle_loading', function(show) {
    if (show) $('#loading-overlay').fadeIn(200);
    else $('#loading-overlay').fadeOut(200);
  });

  // Tooltips personnalisés
  $('[data-toggle="tooltip"]').tooltip({
    delay: {show: 300, hide: 100},
    container: 'body'
  });

  // Redimensionnement des graphiques
  $(window).on('resize', function() {
    if ($('#tendance_economique').length) Plotly.Plots.resize(document.getElementById('tendance_economique'));
    if ($('#comparaison_pays').length) Plotly.Plots.resize(document.getElementById('comparaison_pays'));
  });

  // Confirmation avant export
  $('#export_data').on('click', function() {
    return confirm('Confirmez-vous l\'export des données ?');
  });
});

// Overlay de chargement personnalisé
(function() {
  var loadingHTML = `
    <div id="loading-overlay" style="
      position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background-color: rgba(255,255,255,0.8); z-index: 9999; display: none;
      justify-content: center; align-items: center;">
      <div style="text-align: center; background: white; padding: 30px; border-radius: 5px; box-shadow: 0 0 20px rgba(0,0,0,0.2);">
        <div class="spinner-border text-primary" style="width: 3rem; height: 3rem;"></div>
        <h4 style="margin-top: 20px;">Chargement en cours...</h4>
      </div>
    </div>`;
  $('body').append(loadingHTML);
})();