(function () {
  var modal = document.getElementById('search-modal');
  var input = document.getElementById('search-input');
  var results = document.getElementById('search-results');
  var openBtn = document.getElementById('search-toggle');
  if (!modal || !input || !results) return;

  var data = null;
  var loading = false;

  function open() {
    modal.hidden = false;
    document.body.style.overflow = 'hidden';
    setTimeout(function () { input.focus(); }, 30);
    if (!data && !loading) loadIndex();
  }
  function close() {
    modal.hidden = true;
    document.body.style.overflow = '';
    input.value = '';
    results.innerHTML = '<p class="search-modal__hint">输入关键词开始搜索 · 按 ESC 关闭</p>';
  }

  function loadIndex() {
    loading = true;
    fetch((document.querySelector('base') ? document.querySelector('base').href : '/') + 'search.json')
      .then(function (r) { return r.json(); })
      .then(function (d) { data = d; loading = false; if (input.value) run(); })
      .catch(function () {
        results.innerHTML = '<p class="search-modal__hint">索引加载失败</p>';
        loading = false;
      });
  }

  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c];
    });
  }

  function highlight(text, q) {
    if (!q) return escapeHtml(text);
    var safe = escapeHtml(text);
    var pattern = q.split(/\s+/).filter(Boolean).map(function (w) {
      return w.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }).join('|');
    if (!pattern) return safe;
    return safe.replace(new RegExp('(' + pattern + ')', 'gi'), '<mark>$1</mark>');
  }

  function run() {
    var q = input.value.trim().toLowerCase();
    if (!q) {
      results.innerHTML = '<p class="search-modal__hint">输入关键词开始搜索 · 按 ESC 关闭</p>';
      return;
    }
    if (!data) {
      results.innerHTML = '<p class="search-modal__hint">索引加载中…</p>';
      return;
    }
    var terms = q.split(/\s+/).filter(Boolean);
    var matches = data.filter(function (p) {
      var hay = (p.title + ' ' + (p.tags || '') + ' ' + (p.categories || '') + ' ' + (p.content || '')).toLowerCase();
      return terms.every(function (t) { return hay.indexOf(t) !== -1; });
    }).slice(0, 30);

    if (matches.length === 0) {
      results.innerHTML = '<p class="search-modal__hint">未找到相关结果</p>';
      return;
    }

    results.innerHTML = matches.map(function (p) {
      var snippet = '';
      var lc = (p.content || '').toLowerCase();
      var idx = lc.indexOf(terms[0]);
      if (idx !== -1) {
        var start = Math.max(0, idx - 30);
        snippet = (start > 0 ? '…' : '') + p.content.substr(start, 120) + '…';
      } else if (p.content) {
        snippet = p.content.substr(0, 120) + '…';
      }
      return '<a class="search-result" href="' + p.url + '">'
        + '<div class="search-result__title">' + highlight(p.title, q) + '</div>'
        + (snippet ? '<div class="search-result__meta">' + highlight(snippet, q) + '</div>' : '')
        + (p.date ? '<div class="search-result__meta">' + p.date + (p.categories ? ' · ' + p.categories : '') + '</div>' : '')
        + '</a>';
    }).join('');
  }

  input.addEventListener('input', run);
  if (openBtn) openBtn.addEventListener('click', open);

  modal.querySelectorAll('[data-close]').forEach(function (el) {
    el.addEventListener('click', close);
  });

  document.addEventListener('keydown', function (e) {
    if (e.key === '/' && !modal.hidden === false && document.activeElement.tagName !== 'INPUT' && document.activeElement.tagName !== 'TEXTAREA') {
      e.preventDefault(); open();
    }
    if (e.key === 'Escape' && !modal.hidden) {
      close();
    }
  });
})();
