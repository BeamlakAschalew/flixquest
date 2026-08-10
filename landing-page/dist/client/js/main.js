(function ($) {
  'use strict';

  var $window = $(window);
  var $header = $('.site-header');
  var $menuButton = $('.menu-toggle');
  var $navLinks = $('.nav-links');

  $('#year').text(new Date().getFullYear());

  function closeMenu() {
    $menuButton.attr('aria-expanded', 'false').removeClass('open');
    $navLinks.removeClass('open');
    $('body').removeClass('menu-open');
  }

  $menuButton.on('click', function () {
    var opening = $(this).attr('aria-expanded') !== 'true';
    $(this).attr('aria-expanded', String(opening)).toggleClass('open', opening);
    $navLinks.toggleClass('open', opening);
    $('body').toggleClass('menu-open', opening);
  });

  $('.nav-links a, .brand').on('click', closeMenu);

  $('a[href^="#"]').on('click', function (event) {
    var target = $(this.getAttribute('href'));
    if (!target.length) return;
    event.preventDefault();
    $('html, body').stop().animate({ scrollTop: target.offset().top - 70 }, 650, 'swing');
  });

  $window.on('scroll', function () {
    $header.toggleClass('scrolled', $window.scrollTop() > 24);
  }).trigger('scroll');

  $('.app-tabs button').on('click', function () {
    var panel = $(this).data('demo');
    $('.app-tabs button').removeClass('active');
    $(this).addClass('active');
    $('.demo-panel').addClass('hidden');
    $('.demo-panel[data-panel="' + panel + '"]').removeClass('hidden');
  });

  $('.swatch').on('click', function () {
    var accent = $(this).data('accent');
    $('.swatch').removeClass('active');
    $(this).addClass('active');
    document.documentElement.style.setProperty('--accent', accent);
    $('.theme-showcase').addClass('pulse');
    window.setTimeout(function () { $('.theme-showcase').removeClass('pulse'); }, 500);
  });

  $('.faq-item button').on('click', function () {
    var $item = $(this).closest('.faq-item');
    var isOpen = $item.hasClass('open');
    $('.faq-item.open').removeClass('open').find('button').attr('aria-expanded', 'false');
    $('.faq-answer').stop().slideUp(250);
    if (!isOpen) {
      $item.addClass('open');
      $(this).attr('aria-expanded', 'true');
      $item.find('.faq-answer').stop().slideDown(250);
    }
  });

  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (reduceMotion || !('IntersectionObserver' in window)) {
    $('.reveal').addClass('visible');
  } else {
    $('html').addClass('js-reveal');
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
    $('.reveal').each(function () { observer.observe(this); });
  }

  if (!reduceMotion) {
    $window.on('mousemove', function (event) {
      if ($window.width() < 900) return;
      var x = (event.clientX / $window.width() - 0.5) * 12;
      var y = (event.clientY / $window.height() - 0.5) * 8;
      $('.device-stage').css('transform', 'translate3d(' + x + 'px,' + y + 'px,0)');
    });
  }
})(jQuery);
