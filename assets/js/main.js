(function () {
  // ---------- Mobile nav toggle ----------
  var toggle = document.getElementById('nav-toggle');
  var nav = document.getElementById('site-nav');
  if (toggle && nav) {
    toggle.addEventListener('click', function () {
      var open = nav.classList.toggle('is-open');
      toggle.classList.toggle('is-open', open);
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
    nav.querySelectorAll('a').forEach(function (a) {
      a.addEventListener('click', function () {
        if (window.innerWidth <= 768) {
          nav.classList.remove('is-open');
          toggle.classList.remove('is-open');
          toggle.setAttribute('aria-expanded', 'false');
        }
      });
    });
  }

  // ---------- Theme toggle ----------
  var themeBtn = document.getElementById('theme-toggle');
  if (themeBtn) {
    themeBtn.addEventListener('click', function () {
      var cur = document.documentElement.getAttribute('data-theme') || 'light';
      var next = cur === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', next);
      try { localStorage.setItem('theme', next); } catch (e) {}
    });
  }

  // ---------- Sticky header scroll state ----------
  var header = document.getElementById('site-header');
  if (header) {
    var onScroll = function () {
      header.classList.toggle('is-scrolled', window.scrollY > 8);
    };
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
  }

  // ---------- Reading progress (post pages) ----------
  var progress = document.getElementById('reading-progress');
  var article = document.querySelector('.post__content');
  if (progress && article) {
    var updateProgress = function () {
      var rect = article.getBoundingClientRect();
      var total = rect.height - window.innerHeight;
      var scrolled = window.scrollY - (article.offsetTop - 80);
      var pct = total > 0 ? Math.max(0, Math.min(100, (scrolled / total) * 100)) : 0;
      progress.style.width = pct + '%';
    };
    updateProgress();
    window.addEventListener('scroll', updateProgress, { passive: true });
    window.addEventListener('resize', updateProgress);
  }

  // ---------- TOC (post pages) ----------
  var tocHost = document.getElementById('toc');
  var tocAside = document.querySelector('.post__toc');
  if (tocHost && article) {
    var heads = article.querySelectorAll('h2, h3, h4');
    if (heads.length === 0) {
      if (tocAside) tocAside.style.display = 'none';
    } else {
      var ul = document.createElement('ul');
      heads.forEach(function (h) {
        if (!h.id) {
          h.id = h.textContent.trim().toLowerCase()
            .replace(/\s+/g, '-')
            .replace(/[^\w\u4e00-\u9fa5-]/g, '');
        }
        var li = document.createElement('li');
        li.className = 'lvl-' + h.tagName.charAt(1);
        var a = document.createElement('a');
        a.href = '#' + h.id;
        a.textContent = h.textContent;
        li.appendChild(a);
        ul.appendChild(li);
      });
      tocHost.appendChild(ul);

      var links = ul.querySelectorAll('a');
      var idMap = {};
      links.forEach(function (a) { idMap[a.getAttribute('href').slice(1)] = a; });
      if ('IntersectionObserver' in window) {
        var observer = new IntersectionObserver(function (entries) {
          entries.forEach(function (e) {
            var a = idMap[e.target.id];
            if (!a) return;
            if (e.isIntersecting) {
              links.forEach(function (l) { l.classList.remove('is-active'); });
              a.classList.add('is-active');
            }
          });
        }, { rootMargin: '-15% 0px -70% 0px', threshold: 0 });
        heads.forEach(function (h) { observer.observe(h); });
      }
    }
  }

  // ---------- External links open in new tab ----------
  document.querySelectorAll('.prose a[href^="http"]').forEach(function (a) {
    if (a.hostname !== location.hostname) {
      a.setAttribute('target', '_blank');
      a.setAttribute('rel', 'noopener noreferrer');
    }
  });
})();
